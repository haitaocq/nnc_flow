#!/bin/bash

echo "开始安装n8n"

# 设置环境变量
export N8N_METRICS=true
export QUEUE_HEALTH_CHECK_ACTIVE=true
export GENERIC_TIMEZONE=Asia/Shanghai
export N8N_DEFAULT_LOCALE=zh
export N8N_USER_FOLDER=/workspace/cs_n8n/n8n_data

# 检查npm是否安装
if ! command -v npm &> /dev/null; then
    echo "错误：npm未安装，请先安装Node.js和npm"
    exit 1
fi

# 使用npm list检查n8n是否已安装
if npm list -g n8n &> /dev/null; then
    echo "n8n已经安装，检查是否需要更新"
    # 检测日期是1号，11号，21号则运行更新安装
    if [ $(date +%d) == "01" ] || [ $(date +%d) == "11" ] || [ $(date +%d) == "21" ]; then
        echo "开始更新n8n"
        npm update -g n8n
    fi
else
    echo "开始安装n8n"
    npm install -g n8n
fi
    
# 创建n8n_data目录（如果不存在）
mkdir -p "$(pwd)/n8n_data"

# 在后台启动n8n并将输出重定向到日志文件
nohup n8n start > "$(pwd)/n8n_data/n8n.log" 2>&1 &

echo "n8n已在后台启动，日志将保存在n8n_data/n8n.log文件中"

# 创建nocodb数据目录（如果不存在）
mkdir -p "$(pwd)/nocodb"

# 启动NocoDB容器
echo "开始启动NocoDB容器"
docker run -d \
  --name noco \
  -v "$(pwd)"/nocodb:/usr/app/data/ \
  -p 8080:8080 \
  nocodb/nocodb:latest

echo "NocoDB已在后台启动，端口号8080"