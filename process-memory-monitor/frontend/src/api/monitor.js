import request from '../utils/request'

export function getAllProcesses() {
  return request({
    url: '/monitor/processes',
    method: 'get'
  })
}

export function getAlertProcesses() {
  return request({
    url: '/monitor/processes/alert',
    method: 'get'
  })
}

export function getSystemMemoryInfo() {
  return request({
    url: '/monitor/memory',
    method: 'get'
  })
}

export function getLatestLogs() {
  return request({
    url: '/monitor/logs/latest',
    method: 'get'
  })
}

export function getRecentAlerts(limit = 20) {
  return request({
    url: '/monitor/alerts/recent',
    method: 'get',
    params: { limit }
  })
}

export function getRecentAlertLogs(limit = 50) {
  return request({
    url: '/monitor/alerts/logs',
    method: 'get',
    params: { limit }
  })
}
