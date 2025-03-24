# nFlow自动化ai云台 部署指南

视频教程：【[介绍及教程](https://www.bilibili.com/video/BV1Q792YxEaW/)】
项目首页：【[看这里](https://nflow.duu.men)】

## 系统要求
腾讯云cloudstudio 

## 快速开始

### 1. 初始化配置

编辑配置 (按需修改)

.env

设置执行权限
```
chmod +x deploy.sh
```

### 2. 启动服务

```
./deploy.sh
```

### 3. 访问服务
| 服务       | 访问地址                  | 默认凭证           |
|------------|--------------------------|--------------------|
| PostgreSQL | postgres://localhost:5432 | 见.env文件         |
| pgAdmin    | http://localhost:8081     | PGADMIN_EMAIL/PASSWORD |
| NocoDB     | http://localhost:8080     | JWT_SECRET配置     |
| n8n        | http://localhost:5678     | 首次访问需设置     |

视频教程：【[介绍及教程](https://www.bilibili.com/video/BV1Q792YxEaW/)】
项目首页：【[看这里](https://nflow.duu.men)】

## 进阶配置

### 网络架构


[外部访问] --> [反向代理] --> [Docker网络]
|
+--> PostgreSQL
+--> Redis
+--> NocoDB
+--> n8n

text

### 数据持久化
- PostgreSQL数据卷: `postgres_data`
- Redis数据卷: `redis_data`


### 监控检查

检查服务状态

docker ps


查看实时日志

docker compose logs -f
