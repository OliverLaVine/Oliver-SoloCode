# 进程内存监控系统

Windows 环境下的本地进程内存占用检测应用，前后端分离架构。

## 项目结构

```
process-memory-monitor/
├── backend/        # Spring Boot 后端
├── frontend/       # Vue2 前端
├── scripts/        # 启动脚本
└── sql/            # 数据库脚本
```

## 技术栈

### 后端
- Spring Boot 2.7.18
- Spring Data JPA
- Spring Data Redis
- OSHI (获取系统/进程信息)
- MySQL 8.0
- Lombok

### 前端
- Vue 2.7.14
- Element UI 2.15
- ECharts 5.4
- Axios

## 功能特性

1. **实时进程监控**：获取当前主机所有运行进程的内存占用
2. **图表可视化**：Top 15 进程内存占用柱状图展示
3. **智能告警机制**：进程内存超过系统总内存 5% 时自动弹窗告警
4. **定时检测**：每隔 1 分钟执行一次检测
5. **数据持久化**：检测日志和告警记录存入 MySQL
6. **Redis 缓存**：可选使用 Redis 提升查询效率
7. **一键启动**：Windows 批处理脚本一键启动前后端

## 环境要求

- JDK 1.8+
- Maven 3.6+
- Node.js 14+
- MySQL 8.0+
- Redis 5.0+ (可选)

## 快速开始

### 方式一：一键启动（推荐）

1. 确保 MySQL 服务已启动
2. 进入 `scripts` 目录
3. 双击运行 `start-all.bat`
4. 等待启动完成后，浏览器访问 http://localhost:8081

### 方式二：分别启动

#### 启动后端

```bash
cd backend
mvn clean package -DskipTests
java -jar target/process-memory-monitor-1.0.0.jar
```

或直接运行脚本：
```
scripts/start-backend.bat
```

#### 启动前端

```bash
cd frontend
npm install
npm run serve
```

或直接运行脚本：
```
scripts/start-frontend.bat
```

### 数据库初始化

首次使用前，请先执行数据库初始化脚本：

```bash
mysql -u root -p < sql/init.sql
```

## 配置说明

### 后端配置 (backend/src/main/resources/application.yml)

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/process_monitor
    username: root
    password: root

  redis:
    host: localhost
    port: 6379

monitor:
  alert:
    memory-percent-threshold: 5    # 告警阈值（%）
  schedule:
    cron: "0 */1 * * * ?"         # 检测周期（每分钟）
  redis:
    enabled: true                  # 是否启用 Redis 缓存
```

### 前端配置 (frontend/vue.config.js)

```javascript
devServer: {
  port: 8081,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

## API 接口

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/monitor/processes | GET | 获取所有进程列表 |
| /api/monitor/processes/alert | GET | 获取告警进程列表 |
| /api/monitor/memory | GET | 获取系统内存信息 |
| /api/monitor/logs/latest | GET | 获取最新日志 |
| /api/monitor/logs | GET | 按时间范围查询日志 |
| /api/monitor/alerts/recent | GET | 获取最近告警记录 |

## 停止服务

运行停止脚本：
```
scripts/stop-all.bat
```

或直接关闭对应的命令行窗口。
