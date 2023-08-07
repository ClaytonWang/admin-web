import request from '@/utils/request'

/**
 * 定时任务列表
 * @param {*} params
 */
export function orderList(params) {
  return request({
    url: '/order/mystore',
    method: 'GET',
    params
  })
}

export function orderDelete(data) {
  return request({
    url: '/order/delete',
    method: 'post',
    data
  })
}
