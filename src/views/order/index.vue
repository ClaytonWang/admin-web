<template>
  <div class="app-container">
    <el-table
      v-loading="listLoading"
      :data="list"
      border
      fit
      highlight-current-row
      style="width: 100%"
    >
      <el-table-column prop="num_id" label="订单ID" />
      <el-table-column prop="phone_num" label="购买号码" />
      <el-table-column align="center" prop="status" label="状态">
        <template slot-scope="{ row }">
          <el-tag v-if="row.is_release == 1" type="success">完成</el-tag>
          <el-tag v-else-if="row.is_release == -1" type="success">锁号中</el-tag>
          <el-tag v-else type="warning">已下单</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="detail_json" label="客户姓名" :formatter="(row)=>customFormatter(row.detail_json,'username')" />
      <el-table-column prop="detail_json" label="联系方式" :formatter="(row)=>customFormatter(row.detail_json,'mobile')" />
      <el-table-column prop="detail_json" label="联系地址" :formatter="(row)=>customFormatter(row.detail_json,'address')" />
      <el-table-column prop="detail_json" label="客户备注" :formatter="(row)=>customFormatter(row.detail_json,'beizhu')" />
      <el-table-column prop="create_time" label="创建时间" :formatter="(row)=>formatter(row.create_time)" />
      <el-table-column prop="update_time" label="更新时间" :formatter="(row)=>formatter(row.update_time)" />
      <el-table-column prop="num_id" align="center" label="操作">
        <template slot-scope="{ row }">
          <el-button
            link
            type="primary"
            size="small"
            @click="handleDelete(row)"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>

import {
  orderList,
  orderDelete
} from '@/api/order'

export default {

  data() {
    return {
      listLoading: false,
      list: []
    }
  },

  mounted() {
    this.getList()
  },

  methods: {
    async getList() {
      this.listLoading = true
      const { code, data } = await orderList()
      this.listLoading = false
      console.log(data)

      if (code === 0) {
        this.list = data
      }
    },
    formatter(value) {
      if (!value) return

      return (new Date(value)).toLocaleString()
    },
    customFormatter(strJson, filed) {
      if (!strJson) return ''
      const data = JSON.parse(strJson)
      return data[filed]
    },
    async handleDelete(row) {
      const { code } = await orderDelete({ num_id: row.num_id })
      if (code === 0) {
        this.$message({
          message: '删除成功',
          type: 'success'
        })
        await this.getList()
      }
    }
  }
}
</script>
