<template>
  <div class="dashboard-container">
    <header class="header">
      <div class="header-left">
        <h1 class="title">
          <i class="el-icon-monitor"></i>
          进程内存监控系统
        </h1>
      </div>
      <div class="header-right">
        <span class="refresh-info">
          <i class="el-icon-time"></i>
          上次刷新: {{ lastRefreshTime }}
        </span>
        <el-button type="primary" icon="el-icon-refresh" @click="refreshData" :loading="loading">
          立即刷新
        </el-button>
      </div>
    </header>

    <main class="main-content">
      <section class="stats-section">
        <el-row :gutter="20">
          <el-col :span="6">
            <div class="stat-card memory-total">
              <div class="stat-icon">
                <i class="el-icon-s-data"></i>
              </div>
              <div class="stat-info">
                <p class="stat-label">系统总内存</p>
                <p class="stat-value">{{ systemMemory.totalMemoryGb }} GB</p>
              </div>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="stat-card memory-used">
              <div class="stat-icon">
                <i class="el-icon-s-marketing"></i>
              </div>
              <div class="stat-info">
                <p class="stat-label">已用内存</p>
                <p class="stat-value">{{ systemMemory.usedMemoryGb }} GB</p>
                <p class="stat-percent">{{ systemMemory.usedPercent }}%</p>
              </div>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="stat-card process-count">
              <div class="stat-icon">
                <i class="el-icon-s-grid"></i>
              </div>
              <div class="stat-info">
                <p class="stat-label">运行进程数</p>
                <p class="stat-value">{{ systemMemory.processCount }}</p>
              </div>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="stat-card alert-count" :class="{ 'has-alert': systemMemory.alertProcessCount > 0 }">
              <div class="stat-icon">
                <i class="el-icon-warning"></i>
              </div>
              <div class="stat-info">
                <p class="stat-label">告警进程数</p>
                <p class="stat-value">{{ systemMemory.alertProcessCount }}</p>
                <p class="stat-percent">阈值: {{ systemMemory.alertThresholdPercent }}%</p>
              </div>
            </div>
          </el-col>
        </el-row>
      </section>

      <section class="chart-section">
        <el-card class="chart-card">
          <div slot="header" class="card-header">
            <span class="card-title">
              <i class="el-icon-data-line"></i>
              Top 15 进程内存占用
            </span>
            <span class="card-subtitle">按内存占用降序排列</span>
          </div>
          <div ref="processChart" class="chart-container"></div>
        </el-card>
      </section>

      <section class="table-section">
        <el-card class="table-card">
          <div slot="header" class="card-header">
            <span class="card-title">
              <i class="el-icon-s-platform"></i>
              进程列表
            </span>
            <div class="header-tools">
              <el-input
                v-model="searchKeyword"
                placeholder="搜索进程名称..."
                prefix-icon="el-icon-search"
                size="small"
                class="search-input"
                clearable
              />
              <el-switch
                v-model="showAlertOnly"
                active-text="仅告警"
                inactive-text="全部"
                size="small"
              />
            </div>
          </div>
          <el-table
            :data="filteredProcesses"
            style="width: 100%"
            max-height="400"
            stripe
            v-loading="loading"
          >
            <el-table-column
              prop="processId"
              label="PID"
              width="100"
              align="center"
            />
            <el-table-column
              prop="processName"
              label="进程名称"
              min-width="200"
              show-overflow-tooltip
            />
            <el-table-column
              prop="memoryUsageMb"
              label="内存占用 (MB)"
              width="160"
              align="right"
              :formatter="formatMemoryMb"
            />
            <el-table-column
              prop="memoryPercent"
              label="内存占比 (%)"
              width="160"
              align="center"
            >
              <template slot-scope="scope">
                <el-progress
                  :percentage="scope.row.memoryPercent"
                  :status="getProgressStatus(scope.row)"
                  :stroke-width="12"
                  :format="(percent) => percent.toFixed(2) + '%'"
                />
              </template>
            </el-table-column>
            <el-table-column
              prop="isAlert"
              label="状态"
              width="120"
              align="center"
            >
              <template slot-scope="scope">
                <el-tag
                  :type="scope.row.isAlert ? 'danger' : 'success'"
                  size="small"
                  effect="dark"
                >
                  {{ scope.row.isAlert ? '超阈值' : '正常' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-info">
            共 {{ filteredProcesses.length }} 个进程
          </div>
        </el-card>
      </section>
    </main>

    <el-dialog
      title="内存告警"
      :visible.sync="alertDialogVisible"
      width="600px"
      :close-on-click-modal="false"
      :before-close="handleAlertClose"
      custom-class="alert-dialog"
    >
      <div class="alert-content">
        <div class="alert-icon-wrapper">
          <i class="el-icon-warning alert-icon"></i>
        </div>
        <div class="alert-message">
          <p class="alert-title">检测到 <strong>{{ alertProcesses.length }}</strong> 个进程内存占用超过阈值！</p>
          <p class="alert-subtitle">阈值: {{ systemMemory.alertThresholdPercent }}%</p>
        </div>
      </div>
      <el-table
        :data="alertProcesses"
        size="small"
        style="width: 100%"
        max-height="300"
        stripe
      >
        <el-table-column
          prop="processName"
          label="进程名称"
          min-width="150"
          show-overflow-tooltip
        />
        <el-table-column
          prop="processId"
          label="PID"
          width="80"
          align="center"
        />
        <el-table-column
          prop="memoryUsageMb"
          label="内存 (MB)"
          width="120"
          align="right"
          :formatter="formatMemoryMb"
        />
        <el-table-column
          prop="memoryPercent"
          label="占比 (%)"
          width="120"
          align="center"
          :formatter="formatPercent"
        />
      </el-table>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="handleAlertClose">
          我知道了
        </el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { getAllProcesses, getSystemMemoryInfo, getAlertProcesses } from '../api/monitor'

export default {
  name: 'Dashboard',
  data() {
    return {
      loading: false,
      processes: [],
      alertProcesses: [],
      systemMemory: {
        totalMemoryGb: 0,
        usedMemoryGb: 0,
        usedPercent: 0,
        processCount: 0,
        alertProcessCount: 0,
        alertThresholdPercent: 5
      },
      lastRefreshTime: '-',
      searchKeyword: '',
      showAlertOnly: false,
      alertDialogVisible: false,
      alertShownMap: {},
      chart: null,
      refreshTimer: null
    }
  },
  computed: {
    filteredProcesses() {
      let result = this.processes
      if (this.showAlertOnly) {
        result = result.filter(p => p.isAlert)
      }
      if (this.searchKeyword && this.searchKeyword.trim()) {
        const keyword = this.searchKeyword.toLowerCase()
        result = result.filter(p =>
          p.processName.toLowerCase().includes(keyword) ||
          String(p.processId).includes(keyword)
        )
      }
      return result
    }
  },
  mounted() {
    this.initChart()
    this.loadData()
    this.startAutoRefresh()
  },
  beforeDestroy() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
    }
    if (this.chart) {
      this.chart.dispose()
    }
  },
  methods: {
    async loadData() {
      this.loading = true
      try {
        const [processes, memoryInfo, alertProcesses] = await Promise.all([
          getAllProcesses(),
          getSystemMemoryInfo(),
          getAlertProcesses()
        ])

        this.processes = processes || []
        this.systemMemory = memoryInfo || this.systemMemory
        this.alertProcesses = alertProcesses || []
        this.lastRefreshTime = this.getCurrentTime()

        this.updateChart()
        this.checkAlerts()
      } catch (error) {
        console.error('加载数据失败:', error)
      } finally {
        this.loading = false
      }
    },
    refreshData() {
      this.loadData()
    },
    startAutoRefresh() {
      this.refreshTimer = setInterval(() => {
        this.loadData()
      }, 30000)
    },
    initChart() {
      this.chart = echarts.init(this.$refs.processChart)
      window.addEventListener('resize', this.handleResize)
    },
    handleResize() {
      if (this.chart) {
        this.chart.resize()
      }
    },
    updateChart() {
      if (!this.chart) return

      const topProcesses = this.processes.slice(0, 15)
      const names = topProcesses.map(p => p.processName.length > 15
        ? p.processName.substring(0, 15) + '...'
        : p.processName)
      const values = topProcesses.map(p => p.memoryUsageMb)
      const alertFlags = topProcesses.map(p => p.isAlert)

      const barColors = values.map((_, index) =>
        alertFlags[index] ? '#f56c6c' : '#409eff'
      )

      const option = {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          },
          formatter: function(params) {
            const data = topProcesses[params[0].dataIndex]
            return `
              <div style="padding: 8px;">
                <div style="font-weight: bold; margin-bottom: 4px;">${data.processName}</div>
                <div>PID: ${data.processId}</div>
                <div>内存: ${data.memoryUsageMb.toFixed(2)} MB</div>
                <div>占比: ${data.memoryPercent.toFixed(2)}%</div>
                <div style="color: ${data.isAlert ? '#f56c6c' : '#67c23a'};">
                  状态: ${data.isAlert ? '超阈值' : '正常'}
                </div>
              </div>
            `
          }
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          top: '10%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: names,
          axisLabel: {
            rotate: 30,
            interval: 0,
            fontSize: 11
          },
          axisTick: {
            alignWithLabel: true
          }
        },
        yAxis: {
          type: 'value',
          name: '内存 (MB)',
          axisLabel: {
            formatter: '{value}'
          }
        },
        series: [
          {
            name: '内存占用',
            type: 'bar',
            barWidth: '60%',
            data: values.map((value, index) => ({
              value: value,
              itemStyle: {
                color: barColors[index]
              }
            })),
            label: {
              show: true,
              position: 'top',
              formatter: function(params) {
                return params.value.toFixed(0)
              },
              fontSize: 10
            }
          }
        ]
      }

      this.chart.setOption(option, true)
    },
    checkAlerts() {
      if (this.alertProcesses && this.alertProcesses.length > 0) {
        const currentAlertIds = this.alertProcesses.map(p => p.processId).sort().join(',')

        if (!this.alertShownMap[currentAlertIds]) {
          this.alertDialogVisible = true
          this.alertShownMap[currentAlertIds] = true
        }
      }
    },
    handleAlertClose() {
      this.alertDialogVisible = false
    },
    formatMemoryMb(row, column, value) {
      if (value === undefined || value === null) return '-'
      return value.toFixed(2)
    },
    formatPercent(row, column, value) {
      if (value === undefined || value === null) return '-'
      return value.toFixed(2) + '%'
    },
    getProgressStatus(row) {
      if (row.isAlert) {
        return 'exception'
      }
      if (row.memoryPercent > 3) {
        return 'warning'
      }
      return 'success'
    },
    getCurrentTime() {
      const now = new Date()
      const pad = n => n.toString().padStart(2, '0')
      return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`
    }
  }
}
</script>

<style scoped>
.dashboard-container {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f0f2f5;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.header-left .title {
  font-size: 22px;
  font-weight: 600;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-left .title i {
  font-size: 28px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.refresh-info {
  font-size: 13px;
  opacity: 0.9;
  display: flex;
  align-items: center;
  gap: 5px;
}

.main-content {
  flex: 1;
  padding: 20px 30px;
  overflow-y: auto;
}

.stats-section {
  margin-bottom: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
  margin-right: 15px;
  color: white;
}

.memory-total .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.memory-used .stat-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.process-count .stat-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.alert-count .stat-icon {
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
}

.alert-count.has-alert .stat-icon {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.stat-info {
  flex: 1;
}

.stat-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 6px;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.stat-percent {
  font-size: 12px;
  color: #909399;
}

.chart-section {
  margin-bottom: 20px;
}

.chart-card {
  border-radius: 8px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-title i {
  color: #409eff;
}

.card-subtitle {
  font-size: 12px;
  color: #909399;
}

.chart-container {
  width: 100%;
  height: 350px;
}

.table-section {
  margin-bottom: 20px;
}

.table-card {
  border-radius: 8px;
}

.header-tools {
  display: flex;
  align-items: center;
  gap: 15px;
}

.search-input {
  width: 200px;
}

.pagination-info {
  text-align: right;
  padding: 10px 0 0;
  font-size: 13px;
  color: #909399;
}

.alert-dialog .el-dialog__header {
  background-color: #fef0f0;
  border-bottom: 1px solid #fbc4c4;
}

.alert-dialog .el-dialog__title {
  color: #f56c6c;
  font-size: 18px;
  font-weight: 600;
}

.alert-content {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  padding: 15px;
  background-color: #fef0f0;
  border-radius: 8px;
  border-left: 4px solid #f56c6c;
}

.alert-icon-wrapper {
  margin-right: 15px;
}

.alert-icon {
  font-size: 40px;
  color: #f56c6c;
}

.alert-title {
  font-size: 16px;
  color: #303133;
  margin-bottom: 5px;
}

.alert-title strong {
  color: #f56c6c;
  font-size: 20px;
}

.alert-subtitle {
  font-size: 13px;
  color: #909399;
}

.dialog-footer {
  text-align: center;
}
</style>
