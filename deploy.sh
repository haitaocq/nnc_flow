#!/bin/bash

# 配置参数
COMPOSE_FILE="2c4g-compose.yml"
LOG_FILE="deploy.log"
MAX_RETRIES=3
RETRY_DELAY=15

# 初始化日志
timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}
echo "[$(timestamp)] 开始部署..." | tee -a $LOG_FILE

# 启动函数
start_services() {
  echo "启动容器..."
  docker compose -f $COMPOSE_FILE up -d
}

# 健康检查函数
check_services() {
  healthy=true
  
  # 检查所有容器状态
  if docker compose -f $COMPOSE_FILE ps | grep -E '(exit|unhealthy)'; then
    healthy=false
  fi

  # 额外检查PostgreSQL连接
  pg_container=$(docker compose -f $COMPOSE_FILE ps -q postgres)
  if ! docker exec $pg_container pg_isready -U ${DB_USER:-root} > /dev/null; then
    echo "PostgreSQL连接检查失败" | tee -a $LOG_FILE
    healthy=false
  fi

  $healthy
}

# 主流程
for ((i=1; i<=$MAX_RETRIES; i++)); do
  start_services
  echo "等待服务初始化(${RETRY_DELAY}s)..."
  sleep $RETRY_DELAY

  if check_services; then
    echo "[$(timestamp)] 所有服务启动成功" | tee -a $LOG_FILE
    docker compose -f $COMPOSE_FILE ps
    exit 0
  else
    echo "[$(timestamp)] 第${i}次重试..." | tee -a $LOG_FILE
    docker compose -f $COMPOSE_FILE down
    sleep 5
  fi
done

echo "[$(timestamp)] 部署失败，请检查日志" | tee -a $LOG_FILE
exit 1
