#!/usr/bin/env bash

# ===============================
#   Color Definitions
# ===============================
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BLUE}>>> advcpmv 一键安装脚本开始运行...${RESET}"

set -e

REPO_URL="https://raw.githubusercontent.com/a23506/advcpmv/main"
BIN_DIR="/usr/local/bin"
CUR_DIR=$(pwd)

# Detect correct bash profile (root uses /root)
if [ "$EUID" -eq 0 ]; then
    PROFILE="/root/.bashrc"
else
    PROFILE="$HOME/.bashrc"
fi

echo -e "${YELLOW}>>> 使用的 shell 配置文件：${PROFILE}${RESET}"

# ===============================
# Download binaries
# ===============================
echo -e "${YELLOW}>>> 下载 advcp 和 advmv ...${RESET}"

curl -fsSL "$REPO_URL/advcp" -o "$CUR_DIR/advcp"
curl -fsSL "$REPO_URL/advmv" -o "$CUR_DIR/advmv"

chmod +x "$CUR_DIR/advcp" "$CUR_DIR/advmv"

# ===============================
# Install binaries
# ===============================
echo -e "${YELLOW}>>> 安装到 ${BIN_DIR} ...${RESET}"

sudo cp "$CUR_DIR/advcp" "$BIN_DIR/"
sudo cp "$CUR_DIR/advmv" "$BIN_DIR/"

echo -e "${GREEN}>>> 安装成功！${RESET}"

# ===============================
# Write alias to shell profile
# ===============================
echo -e "${YELLOW}>>> 写入 alias 到 ${PROFILE} ...${RESET}"

if ! grep -q "alias cp='/usr/local/bin/advcp -g'" "$PROFILE"; then
    echo "alias cp='/usr/local/bin/advcp -g'" >> "$PROFILE"
fi

if ! grep -q "alias mv='/usr/local/bin/advmv -g'" "$PROFILE"; then
    echo "alias mv='/usr/local/bin/advmv -g'" >> "$PROFILE"
fi

echo -e "${GREEN}>>> alias 设置完成${RESET}"

# Try to reload shell config
echo -e "${YELLOW}>>> 尝试重新加载 shell 配置 ...${RESET}"
source "$PROFILE" 2>/dev/null || true

# ===============================
# Check if cp is switched
# ===============================
echo -e "${YELLOW}>>> 检测 cp 是否已切换为 advcp ...${RESET}"

CP_HELP_OUTPUT=$(cp -h 2>&1)

if echo "$CP_HELP_OUTPUT" | grep -q "Try '/usr/local/bin/advcp"; then
    echo -e "${GREEN}>>> SUCCESS：cp 已成功替换为 advcp${RESET}"
    SHELL_RELOAD_REQUIRED=0
else
    echo -e "${RED}>>> WARNING：当前 cp 仍然是系统默认版本${RESET}"
    echo -e "${YELLOW}>>> 需要退出当前终端并重新登录后，cp 才会切换为 advcp${RESET}"
    echo -e "${YELLOW}>>> 或手动执行： source ${PROFILE}${RESET}"
    SHELL_RELOAD_REQUIRED=1
fi

# ===============================
# Test copying functionality
# ===============================
echo -e "${YELLOW}>>> 测试文件复制 ...${RESET}"

cp /etc/passwd /tmp/passwd_test 2>/dev/null || true

if [ -f /tmp/passwd_test ]; then
    echo -e "${GREEN}>>> 文件复制测试成功！（/tmp/passwd_test）${RESET}"
else
    echo -e "${RED}>>> 文件复制失败，请检查 advcp 是否正常运行${RESET}"
fi

rm -f /tmp/passwd_test

# ===============================
# Summary
# ===============================

echo -e "${BLUE}====================================================${RESET}"
echo -e "${GREEN}>>> advcpmv 安装步骤已完成${RESET}"

if [ "$SHELL_RELOAD_REQUIRED" -eq 1 ]; then
    echo -e "${YELLOW}>>> 但 alias 尚未生效：需要重新登录当前终端！${RESET}"
    echo -e "${YELLOW}>>> 或执行： source ${PROFILE}${RESET}"
else
    echo -e "${GREEN}>>> cp/mv 已替换为 advcp/advmv（带进度条版本）${RESET}"
fi

echo -e "${BLUE}====================================================${RESET}"
