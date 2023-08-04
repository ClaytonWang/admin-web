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
          <el-tag v-else type="warning">锁号中</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="detail_json" label="客户姓名" :formatter="(row)=>customFormatter(row.detail_json,'username')" />
      <el-table-column prop="detail_json" label="联系方式" :formatter="(row)=>customFormatter(row.detail_json,'mobile')" />
      <el-table-column prop="detail_json" label="联系地址" :formatter="(row)=>customFormatter(row.detail_json,'address')" />
      <el-table-column prop="detail_json" label="客户备注" :formatter="(row)=>customFormatter(row.detail_json,'beizhu')" />
      <el-table-column prop="create_time" label="创建时间" :formatter="(row)=>formatter(row.create_time)" />
      <el-table-column prop="update_time" label="更新时间" :formatter="(row)=>formatter(row.update_time)" />
    </el-table>
  </div>
</template>

<script>

import {
  orderList
} from '@/api/order'

export default {

  data() {
    return {
      listLoading: false,
      list: [
        {
          'num_id': 305,
          'phone_num': '15021732111',
          'busi_type': 'order',
          'detail_json': '{"username":"1111","mobile":"13816671456","address":"12323","beizhu":"asfasf","batch_id":"0","done_code":"0","done_date":"","ext1":"","ext2":"1048","ext3":"20000","icc_id":"","imsi":"","m_DepositAmount":"20000","m_DepositMonth":"120","m_PresentMonth":"0","m_ResLevel":"D","m_ReserveFee":"20000","manage_status":"2","number_mode":"","op_id":"0","op_phone":"","org_id":"0","plan_id":"-1","res_code":"100001","res_id":"15021732111","res_number_hlr":"1502173","res_status":"0","select_price_mode":"1048","use_type":"0","rule":"","id":"15021732111","title":"15021732111","desc":"","price":"0"}',
          'create_by': 'custom',
          'update_by': 'custom',
          'create_time': '2023-08-02T04:13:22.000Z',
          'update_time': '2023-08-02T04:13:22.000Z',
          'is_delete': 0
        },
        {
          'num_id': 306,
          'phone_num': '15021732111',
          'busi_type': 'order',
          'detail_json': '{"username":"1111","mobile":"13816671456","address":"12323","beizhu":"asfasf","batch_id":"0","done_code":"0","done_date":"","ext1":"","ext2":"1048","ext3":"20000","icc_id":"","imsi":"","m_DepositAmount":"20000","m_DepositMonth":"120","m_PresentMonth":"0","m_ResLevel":"D","m_ReserveFee":"20000","manage_status":"2","number_mode":"","op_id":"0","op_phone":"","org_id":"0","plan_id":"-1","res_code":"100001","res_id":"15021732111","res_number_hlr":"1502173","res_status":"0","select_price_mode":"1048","use_type":"0","rule":"","id":"15021732111","title":"15021732111","desc":"","price":"0"}',
          'create_by': 'custom',
          'update_by': 'custom',
          'create_time': '2023-08-02T04:13:40.000Z',
          'update_time': '2023-08-02T04:13:40.000Z',
          'is_delete': 0
        },
        {
          'num_id': 307,
          'phone_num': '15026507111',
          'busi_type': 'order',
          'detail_json': '{"username":"1122","mobile":"13816671456","address":"123123","beizhu":"123232","batch_id":"0","done_code":"0","done_date":"","ext1":"","ext2":"1048","ext3":"20000","icc_id":"","imsi":"","m_DepositAmount":"20000","m_DepositMonth":"120","m_PresentMonth":"0","m_ResLevel":"D","m_ReserveFee":"20000","manage_status":"2","number_mode":"","op_id":"0","op_phone":"","org_id":"0","plan_id":"-1","res_code":"100001","res_id":"15026507111","res_number_hlr":"1502650","res_status":"0","select_price_mode":"1048","use_type":"0","rule":"","id":"15026507111","title":"15026507111","desc":"","price":"0"}',
          'create_by': 'custom',
          'update_by': 'custom',
          'create_time': '2023-08-02T04:25:21.000Z',
          'update_time': '2023-08-02T04:25:21.000Z',
          'is_delete': 0
        },
        {
          'num_id': 308,
          'phone_num': '15021057111',
          'busi_type': 'order',
          'detail_json': '{"username":"企鹅肉","mobile":"去问13816801870","address":"轻揉人头","beizhu":"","batch_id":"0","done_code":"0","done_date":"","ext1":"","ext2":"1048","ext3":"20000","icc_id":"","imsi":"","m_DepositAmount":"20000","m_DepositMonth":"120","m_PresentMonth":"0","m_ResLevel":"D","m_ReserveFee":"20000","manage_status":"2","number_mode":"","op_id":"0","op_phone":"","org_id":"0","plan_id":"-1","res_code":"100001","res_id":"15021057111","res_number_hlr":"1502105","res_status":"0","select_price_mode":"1048","use_type":"0","rule":"","id":"15021057111","title":"15021057111","desc":"","price":"0"}',
          'create_by': 'custom',
          'update_by': 'custom',
          'create_time': '2023-08-02T11:36:32.000Z',
          'update_time': '2023-08-02T11:36:32.000Z',
          'is_delete': 0
        }
      ]
    }
  },

  mounted() {
    // this.getList()
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
    }
  }
}
</script>
