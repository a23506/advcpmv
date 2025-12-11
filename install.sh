#!/usr/bin/env bash

# =====================
#  彩色定义
# =====================
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BLUE}>>> advcpmv 一键安装脚本开始运行...${RESET}"

set -e

REPO_URL="https://raw.githubusercontent.com/a23506/advcpmv/master"
BIN_DIR="/usr/local/bin"
CUR_DIR=$(pwd)

# =====================
# 下载文件
# =====================
echo -e "${YELLOW}>>> 下载 advcp 和 advmv ...${RESET}"

curl -L "$REPO_URL/advcp" -o "$CUR_DIR/advcp"
curl -L "$REPO_URL/advmv" -o "$CUR_DIR/advmv"

chmod +x "$CUR_DIR/advcp" "$CUR_DIR/advmv"

# =====================
# 拷贝文件
# =====================
echo -e "${YELLOW}>>> 安装到 ${BIN_DIR} ...${RESET}"

sudo cp "$CUR_DIR/advcp" "$BIN_DIR/"
sudo cp "$CUR_DIR/advmv" "$BIN_DIR/"

echo -e "${GREEN}>>> 安装成功！${RESET}"

# =====================
# 设置 alias
# =====================
echo -e "${YELLOW}>>> 写入 ~/.bashrc ...${RESET}"

if ! grep -q "alias cp='/usr/local/bin/advcp -g'" ~/.bashrc; then
    echo "alias cp='/usr/local/bin/advcp -g'" >> ~/.bashrc
fi

if ! grep -q "alias mv='/usr/local/bin/advmv -g'" ~/.bashrc; then
    echo "alias mv='/usr/local/bin/advmv -g'" >> ~/.bashrc
fi

echo -e "${GREEN}>>> alias 设置完成${RESET}"

# reload bashrc
source ~/.bashrc

# =====================
# 测试
# =====================
echo -e "${YELLOW}>>> 测试 advcp 是否可用 ...${RESET}"

cp /etc/passwd /tmp/passwd_test

if [ -f /tmp/passwd_test ]; then
    echo -e "${GREEN}>>> 测试复制成功！（/tmp/passwd_test）${RESET}"
else
    echo -e "${RED}>>> 测试失败，请检查 advcp 是否正常运行${RESET}"
    exit 1
fi

rm -f /tmp/passwd_test

echo -e "${GREEN}>>> 安装完成！ advcp/advmv 已替换系统 cp/mv${RESET}"
