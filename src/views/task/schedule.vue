<template>
  <div class="app-container">
    <div class="filter-container">
      <el-button v-waves class="filter-item" type="primary" icon="el-icon-plus" @click="handleEdit(null)">新增</el-button>
    </div>
    <i style="color: red;"><b>当前项目中存在两个jobHandler方法，testHandler（定时打印日志）与testCurlHandler（定时调用接口，参数为必填，必须为json字符串格式）</b></i>
    <el-table v-loading="listLoading" :data="list" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="job_id" label="任务ID" />
      <el-table-column prop="jobName" label="任务名" />
      <el-table-column prop="cron" label="Cron" />
      <el-table-column prop="runMode" label="运行模式">
        <template slot-scope="{row}">
          {{ row.runMode | runModeFilter }}<template v-if="row.runMode==0">:{{ row.jobHandler }}</template>
        </template>
      </el-table-column>
      <el-table-column prop="description" label="任务描述" />
      <el-table-column align="center" prop="status" label="状态">
        <template slot-scope="{row}">
          <el-tag v-if="row.status==0" type="success">run</el-tag>
          <el-tag v-else type="info">stop</el-tag>
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作">
        <template slot-scope="{row}">
          <el-dropdown @command="handleCommand">
            <el-button type="primary">
              操作<i class="el-icon-arrow-down el-icon--right" />
            </el-button>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item :command="beforeHandleCommand('run', row.job_id)">执行一次</el-dropdown-item>
              <el-dropdown-item :command="beforeHandleCommand('showLog', row.job_id, row.runMode)">查询日志</el-dropdown-item>
              <el-dropdown-item v-if="row.runMode==1" divided :command="beforeHandleCommand('handleEditShell', row)">编辑Shell</el-dropdown-item>
              <el-dropdown-item v-if="row.status==-1" divided :command="beforeHandleCommand('updateStatus', row.job_id, 0)">启动</el-dropdown-item>
              <el-dropdown-item v-else :command="beforeHandleCommand('updateStatus', row.job_id, -1)">停止</el-dropdown-item>
              <el-dropdown-item :command="beforeHandleCommand('handleEdit', row)" :disabled="row.status==0">编辑</el-dropdown-item>
              <el-dropdown-item :command="beforeHandleCommand('del', row)" :disabled="row.status==0">删除</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="listQuery.page" :limit.sync="listQuery.size" @pagination="getList" />
    <el-dialog :visible.sync="dialogVisible" :title="dialogType==='edit'?'编辑任务':'新增任务'" width="400px">
      <el-form ref="editForm" :rules="rules" :model="fromData" label-width="100px" label-position="right">
        <el-form-item label="Cron" prop="cron">
          <el-input v-model="fromData.cron" placeholder="请输入Cron" />
        </el-form-item>
        <el-form-item label="任务名" prop="jobName">
          <el-input v-model="fromData.jobName" placeholder="请输入任务名" />
        </el-form-item>
        <el-form-item label="运行模式" prop="runMode">
          <el-select v-model="fromData.runMode" placeholder="请选择">
            <el-option label="BEAN模式" :value="0" />
            <el-option label="SHELL模式" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="fromData.runMode==0" label="jobHandler" prop="jobHandler">
          <el-input v-model="fromData.jobHandler" placeholder="请输入jobHandler" />
        </el-form-item>
        <el-form-item label="参数" prop="params">
          <template v-if="fromData.runMode==1" slot="label">
            参数
            <el-tooltip class="item" effect="dark" content="多个参数请用英文逗号隔开" placement="bottom">
              <i class="el-icon-question" />
            </el-tooltip>
          </template>
          <el-input v-model="fromData.params" type="textarea" placeholder="请输入参数" />
        </el-form-item>
        <el-form-item label="任务描述" prop="description">
          <el-input v-model="fromData.description" type="textarea" placeholder="请输入任务描述" />
        </el-form-item>
      </el-form>
      <div style="text-align:right;">
        <el-button type="danger" @click="dialogVisible=false">取消</el-button>
        <el-button type="primary" @click="confirm">提交</el-button>
      </div>
    </el-dialog>
    <el-dialog :visible.sync="logDialogVisible" fullscreen title="执行记录">
      <el-table :data="logList" border fit highlight-current-row style="width: 100%">
        <el-table-column align="center" prop="id" label="ID" />
        <el-table-column align="center" prop="jobName" label="任务名" />
        <el-table-column v-if="logListQuery.runMode==0" align="center" prop="jobHandler" label="处理方法" />
        <el-table-column align="center" prop="jobParam" label="参数" show-overflow-tooltip />
        <el-table-column align="center" prop="handleTime" label="执行时间">
          <template slot-scope="{row}">
            {{ row.handleTime | dateTimeFilter('yyyy-MM-dd hh:mm:ss') }}
          </template>
        </el-table-column>
        <el-table-column align="center" prop="jobStatus" label="执行状态">
          <template slot-scope="{row}">
            <el-tag v-if="row.jobStatus==0" type="success">成功</el-tag>
            <el-tag v-else type="info">失败</el-tag>
          </template>
        </el-table-column>
        <el-table-column align="center" prop="triggerType" label="触发类型">
          <template slot-scope="{row}">
            {{ row.triggerType | triggerTypeFilter }}
          </template>
        </el-table-column>
        <el-table-column align="center" prop="executionStatus" label="任务状态">
          <template slot-scope="{row}">
            {{ row.executionStatus | executionStatusFilter }}
          </template>
        </el-table-column>
        <el-table-column align="center" label="操作">
          <template slot-scope="{row}">
            <el-button v-if="row.jobStatus==0" type="text" @click="showDetail(row.id)">执行日志</el-button>
            <el-button v-else type="text" @click="showDetail(row.id, true)">异常日志</el-button>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="logTotal>0" :total="logTotal" :page.sync="logListQuery.page" :limit.sync="logListQuery.size" @pagination="getLogList" />
    </el-dialog>

    <el-dialog :visible.sync="logDetailDialogVisible" title="执行日志">
      <div v-html="logDetail" />
      <!-- isShowExecutionAnimation -->
    </el-dialog>

    <!-- 配置脚本 -->
    <el-dialog :visible.sync="shellDialogVisible" title="编辑shell">
      <i>*由于当前实现原因，接受参数应从第二位开始*</i>
      <codemirror v-model="sourceFromData.runSource" :options="cmOptions" />
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="confirmShell">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import Pagination from '@/components/Pagination'
import waves from '@/directive/waves'
import { codemirror } from 'vue-codemirror'
import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/liquibyte.css'
import 'codemirror/addon/hint/show-hint.css'

import 'codemirror/addon/hint/show-hint.js'
import { scheduleList, editSchedule, deleteSchedule, updateStatusSchedule, runSchedule, scheduleLogList, scheduleLogDetail } from '@/api/task'
export default {
  components: { Pagination, codemirror },
  directives: { waves },
  filters: {
    triggerTypeFilter(val) {
      return val === 0 ? '任务触发' : '手动触发'
    },
    executionStatusFilter(val) {
      return val === 0 ? '执行中' : '执行完成'
    },
    runModeFilter(val) {
      return val === 0 ? 'BEAN' : 'SHELL'
    }
  },
  data() {
    return {
      listLoading: false,
      list: [],
      total: 0,
      listQuery: {
        page: 1,
        size: 20
      },

      dialogVisible: false,
      dialogType: 'new',
      fromData: {
        runMode: 0
      },
      rules: {
        cron: { required: true, message: '请输入Cron', trigger: 'blur' },
        jobName: { required: true, message: '请输入任务名', trigger: 'blur' },
        jobHandler: { required: true, message: '请输入jobHandler', trigger: 'blur' }
      },

      sourceFromData: {
        runSource: '#!/bin/bash\necho "hello shell"\nexit 0'
      },

      // 日志浮窗
      logDialogVisible: false,
      logListQuery: {
        page: 1,
        size: 20,
        job_id: '',
        runMode: 0
      },
      logList: [],
      logTotal: 0,

      // 日志详情
      logDetailDialogVisible: false,
      logDetail: '',
      timer: null,
      // 是否展示执行中动画
      isShowExecutionAnimation: false,

      shellDialogVisible: false,

      cmOptions: {
        value: '',
        mode: 'text/x-sh',
        theme: 'liquibyte',
        indentWithTabs: true,
        smartIndent: true,
        lineNumbers: true,
        matchBrackets: true,
        autofocus: true,
        extraKeys: { 'Ctrl-Space': 'autocomplete' },
        hintOptions: { tables: {
          users: ['name', 'score', 'birthDate'],
          countries: ['name', 'population', 'size']
        }}
      }
    }
  },
  mounted() {
    this.getList()
  },
  beforeDestroy() {
    this.timer && clearInterval(this.timer)
  },
  methods: {
    async getList() {
      this.listLoading = true
      const { code, data } = await scheduleList(this.listQuery)
      this.listLoading = false
      if (code === 0) {
        this.list = data.list
        this.total = data.total
      }
    },
    beforeHandleCommand(method, ...params) {
      return { params, method }
    },
    handleCommand(command) {
      this[command.method](...command.params)
    },
    handleEdit(row) {
      this.fromData = { runMode: 0 }
      if (row) {
        this.fromData = JSON.parse(JSON.stringify(row))
        this.dialogType = 'edit'
      } else {
        this.dialogType = 'new'
      }
      this.dialogVisible = true
    },
    async confirm() {
      this.$refs.editForm.validate(async valid => {
        if (!valid) return false
        const { code } = await editSchedule(this.fromData)
        if (code === 0) {
          this.$message({
            message: this.dialogType === 'edit' ? '编辑成功' : '新增成功',
            type: 'success'
          })
          this.dialogVisible = false
          this.getList()
        }
      })
    },
    handleEditShell(row) {
      this.sourceFromData = {
        ...row
      }
      if (!row.runSource) {
        this.sourceFromData.runSource = '#!/bin/bash\n\n# 由于当前实现原因，接受参数应从第二位开始\n\necho "hello shell"\n\nexit 0'
      }
      this.shellDialogVisible = true
    },
    async confirmShell() {
      const { code } = await editSchedule(this.sourceFromData)
      if (code === 0) {
        this.$message({
          message: '编辑成功',
          type: 'success'
        })
        this.shellDialogVisible = false
        this.getList()
      }
    },
    del(row) {
      this.$confirm('确定要删除该任务吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async() => {
        const { code } = await deleteSchedule({ job_id: row.job_id })
        if (code === 0) {
          this.$message({
            message: '删除成功',
            type: 'success'
          })
          this.getList()
        }
      })
    },
    async updateStatus(job_id, status) {
      const { code } = await updateStatusSchedule({ job_id, status })
      if (code === 0) {
        this.$message({
          message: status === 0 ? '任务启动成功' : '任务停止成功',
          type: 'success'
        })
        this.getList()
      }
    },
    async run(job_id) {
      const { code } = await runSchedule({ job_id })
      if (code === 0) {
        this.$message({
          message: '执行成功',
          type: 'success'
        })
      }
    },
    showLog(job_id, runMode) {
      this.logListQuery = {
        page: 1,
        size: 20,
        job_id,
        runMode
      }
      this.getLogList()
      this.logDialogVisible = true
    },
    async getLogList() {
      const { code, data } = await scheduleLogList(this.logListQuery)
      if (code === 0) {
        this.logList = data.list
        this.logTotal = data.total
      }
    },
    showDetail(id, error) {
      this.isShowExecutionAnimation = true
      this.logDetail = ''
      this.getLogDetail(id, error)
      this.timer = setInterval(() => {
        this.getLogDetail(id, error)
      }, 1000)
      this.logDetailDialogVisible = true
    },
    async getLogDetail(id, error) {
      this.logDetail = ''
      const { code, data } = await scheduleLogDetail({ id, error })
      if (code === 0) {
        this.logDetail = data.detail
        if (data.executionStatus === 1) {
          this.isShowExecutionAnimation = false
          clearInterval(this.timer)
        }
      }
    }
  }
}
</script>
