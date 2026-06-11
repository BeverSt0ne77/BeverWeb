#!/bin/sh
set -e

echo "================================================"
echo "  BeverWeb Deploy"
echo "================================================"
echo "  Target:  $VPS_USER@$VPS_HOST${VPS_PORT:+:$VPS_PORT}"
echo "================================================"
echo ""

# 校验必填参数
: "${VPS_HOST:?❌ VPS_HOST 未设置}"
: "${VPS_USER:?❌ VPS_USER 未设置}"
VPS_PORT="${VPS_PORT:-22}"

# ---- SSH 连接准备 ----
echo "[1/3] 🔑 配置 SSH 连接..."
# 只读挂载的 key 无法 chmod，复制到可写位置
cp /root/.ssh/id_rsa /tmp/deploy_key.orig
# 去除 Windows CRLF (\r) 和 base64 中间可能混入的空格（换行被误替换为空格）
sed 's/\r//g' /tmp/deploy_key.orig > /tmp/deploy_key
rm /tmp/deploy_key.orig
chmod 600 /tmp/deploy_key
SSH_KEY="/tmp/deploy_key"
echo "  Key file: $(wc -c < $SSH_KEY) bytes"

# 验证密钥是否有效
if ! ssh-keygen -y -f $SSH_KEY > /dev/null 2>&1; then
  # 如果失败，尝试去除 base64 正文中的空格再试
  echo "  ⚠️ 原始密钥验证失败，尝试修复空格问题..."
  awk 'NR==1{print;next} NR==2{gsub(/ /,"");print;next} {print}' /tmp/deploy_key > /tmp/deploy_key.clean
  chmod 600 /tmp/deploy_key.clean
  if ssh-keygen -y -f /tmp/deploy_key.clean > /dev/null 2>&1; then
    echo "  ✅ 修复成功（移除了 base64 中的空格）"
    SSH_KEY="/tmp/deploy_key.clean"
  else
    echo "  ❌ 密钥验证失败: $(ssh-keygen -y -f $SSH_KEY 2>&1)"
    exit 1
  fi
fi
ssh-keyscan -p $VPS_PORT $VPS_HOST >> /root/.ssh/known_hosts 2>/dev/null
echo "  ✅ SSH 就绪"
echo ""

# ---- SCP 上传 ----
echo "[2/3] 📋 上传文件到 $VPS_USER@$VPS_HOST ..."
ssh -p $VPS_PORT -i $SSH_KEY \
    $VPS_USER@$VPS_HOST "mkdir -p /var/www/bever"
scp -P $VPS_PORT -i $SSH_KEY -r \
    /app/index /app/nginx \
    $VPS_USER@$VPS_HOST:/var/www/bever/
echo "  ✅ 上传完成"
echo ""

# ---- 重启 Nginx ----
echo "[3/3] 🔄 重启 Nginx..."
ssh -p $VPS_PORT -i $SSH_KEY \
    $VPS_USER@$VPS_HOST "nginx -s reload"
echo "  ✅ Nginx 已重启"
echo ""

echo "================================================"
echo "  ✅ 部署完成"
echo "  https://bever.cn"
echo "================================================"
