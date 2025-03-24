# 容器化应用部署指南

## 系统要求
- Docker 20.10+
- Docker Compose 2.20+
- 4核CPU / 8GB内存 / 50GB磁盘空间

## 快速开始

### 1. 初始化配置



复制示例环境文件

cp .env.example .env


编辑配置 (按需修改)

nano .env


设置执行权限

chmod +x deploy.sh

text

### 2. 启动服务


./deploy.sh

text

### 3. 访问服务
| 服务       | 访问地址                  | 默认凭证           |
|------------|--------------------------|--------------------|
| PostgreSQL | postgres://localhost:5432 | 见.env文件         |
| pgAdmin    | http://localhost:8081     | PGADMIN_EMAIL/PASSWORD |
| NocoDB     | http://localhost:8080     | JWT_SECRET配置     |
| n8n        | http://localhost:5678     | 首次访问需设置     |
| Qdrant     | http://localhost:6333     | -                  |

## 进阶配置

### 网络架构


[外部访问] --> [反向代理] --> [Docker网络]
|
+--> PostgreSQL
+--> Redis
+--> NocoDB
+--> n8n
+--> Qdrant

text

### 数据持久化
- PostgreSQL数据卷: `postgres_data`
- Redis数据卷: `redis_data`
- 备份建议：



每日备份

0 2 * * * docker exec postgres pg_dump -U youruser -d yourdb > backup.sql

text

### 监控检查



检查服务状态

docker compose ps


查看实时日志

docker compose logs -f


健康端点

curl http://localhost:6333/readyz [http://localhost:6333/readyz] # Qdrant
curl http://localhost:8080/health [http://localhost:8080/health] # NocoDB

text

## 故障排查

### 常见问题
**Q1: 端口冲突怎么办？**  
修改`.env`中的`EXTERNAL_PORT`系列变量

**Q2: 如何升级版本？**  
1. 停止服务：`docker compose down`  
2. 修改`docker-compose.yml`中的镜像版本  
3. 重新部署：`./deploy.sh`

**Q3: 数据如何迁移？**  
复制对应数据卷目录：


rsync -av /var/lib/docker/volumes/project_postgres_data /backup/

text

### 日志分析



查看最后100行日志

tail -n 100 deploy.log


筛选错误信息

grep -i 'error|fail' deploy.log

text

## 安全建议
1. 生产环境必须修改以下配置：
   - `JWT_SECRET`
   - `ENCRYPTION_KEY`
   - `PGADMIN_PASSWORD`
2. 启用防火墙规则
3. 建议配置HTTPS反向代理

## 扩展组件
可在`docker-compose.yml`中添加以下服务：


traefik:
image: traefik:v2.10


...反向代理配置...

prometheus:
image: prom/prometheus:latest


...监控配置...

text

---
**维护提示**：定期执行`docker system prune`清理无效镜像



使用说明

 1. 首次部署：

bash
# 初始化环境
cp .env.example .env
nano .env  # 修改必要配置

# 执行部署
./deploy.sh


 2. 日常维护：

bash
# 查看服务状态
docker compose ps

# 停止服务
docker compose down

# 更新服务
git pull origin main && ./deploy.sh


 3. 日志监控：

bash
# 实时查看日志
tail -f deploy.log

# 过滤特定服务日志
docker compose logs -f postgres