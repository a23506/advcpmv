#!/usr/bin/env bash

# ===============================
#   颜色定义
# ===============================
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BLUE}>>> advcpmv 一键安装脚本开始运行...${RESET}"

set -e

# 仓库地址（你现在用的是 master 分支，就按你这个来）
REPO_URL="https://raw.githubusercontent.com/a23506/advcpmv/master"
BIN_DIR="/usr/local/bin"
CUR_DIR=$(pwd)

# ===============================
# 选择要写入的 shell 配置文件
# ===============================
if [ "$EUID" -eq 0 ]; then
    PROFILE="/root/.bashrc"
else
    PROFILE="$HOME/.bashrc"
fi

echo -e "${YELLOW}>>> 使用的 shell 配置文件：${PROFILE}${RESET}"

# ===============================
# 下载 advcp 和 advmv
# ===============================
echo -e "${YELLOW}>>> 下载 advcp 和 advmv ...${RESET}"

curl -fsSL "$REPO_URL/advcp" -o "$CUR_DIR/advcp"
curl -fsSL "$REPO_URL/advmv" -o "$CUR_DIR/advmv"

chmod +x "$CUR_DIR/advcp" "$CUR_DIR/advmv"

# ===============================
# 安装到 /usr/local/bin
# ===============================
echo -e "${YELLOW}>>> 安装到 ${BIN_DIR} ...${RESET}"

sudo cp "$CUR_DIR/advcp" "$BIN_DIR/"
sudo cp "$CUR_DIR/advmv" "$BIN_DIR/"

echo -e "${GREEN}>>> 安装成功！${RESET}"

# ===============================
# 写入 alias
# ===============================
echo -e "${YELLOW}>>> 写入 alias 到 ${PROFILE} ...${RESET}"

if ! grep -q "alias cp='/usr/local/bin/advcp -g'" "$PROFILE"; then
    echo "alias cp='/usr/local/bin/advcp -g'" >> "$PROFILE"
fi

if ! grep -q "alias mv='/usr/local/bin/advmv -g'" "$PROFILE"; then
    echo "alias mv='/usr/local/bin/advmv -g'" >> "$PROFILE"
fi

echo -e "${GREEN}>>> alias 设置完成${RESET}"

# ===============================
# 尝试重新加载配置（能生效就生效一下）
# ===============================
echo -e "${YELLOW}>>> 尝试重新加载 shell 配置 ...${RESET}"
# 有些环境 source 会失败，这里不影响后续逻辑，所以 2>/dev/null || true
source "$PROFILE" 2>/dev/null || true

# ===============================
# 用 cp -h 来检测是否已切换为 advcp
# ===============================
echo -e "${YELLOW}>>> 检测 cp 是否已切换为 advcp ...${RESET}"

CP_HELP_OUTPUT=$(cp -h 2>&1 || true)

# Debug 输出一行（如果你不想看可以删掉这一行）
# echo "DEBUG: cp -h output is: $CP_HELP_OUTPUT"

# 规则 1：如果包含 “Try '/usr/local/bin/advcp” —— 判定为成功
if echo "$CP_HELP_OUTPUT" | grep -q "Try '/usr/local/bin/advcp"; then
    echo -e "${GREEN}>>> SUCCESS：cp 已成功切换为 advcp（带进度条版本）${RESET}"
    SHELL_RELOAD_REQUIRED=0

# 规则 2：如果包含 “Try 'cp” —— 判定为系统原生 cp
elif echo "$CP_HELP_OUTPUT" | grep -q "Try 'cp"; then
    echo -e "${RED}>>> WARNING：当前 cp 仍为系统默认版本${RESET}"
    echo -e "${YELLOW}>>> 请退出 SSH / 终端重新登录使 alias 生效${RESET}"
    SHELL_RELOAD_REQUIRED=1

# 规则 3：其他情况（比如 cp -h 报错、不认识的格式等）
else
    echo -e "${RED}>>> WARNING：无法准确判断 cp 状态${RESET}"
    echo -e "${YELLOW}>>> 请手动执行： type cp${RESET}"
    SHELL_RELOAD_REQUIRED=1
fi

# ===============================
# 复制功能测试
# ===============================
echo -e "${YELLOW}>>> 测试文件复制功能 ...${RESET}"

cp /etc/passwd /tmp/passwd_test 2>/dev/null || true

if [ -f /tmp/passwd_test ]; then
    echo -e "${GREEN}>>> 文件复制测试成功！（/tmp/passwd_test）${RESET}"
else
    echo -e "${RED}>>> 文件复制失败，请检查 advcp 是否正常运行${RESET}"
fi

rm -f /tmp/passwd_test

# ===============================
# 总结输出
# ===============================
echo -e "${BLUE}====================================================${RESET}"
echo -e "${GREEN}>>> advcpmv 安装已完成${RESET}"

if [ "$SHELL_RELOAD_REQUIRED" -eq 1 ]; then
    echo -e "${YELLOW}>>> 当前检测结果：cp 可能还未切换或无法确定${RESET}"
    echo -e "${YELLOW}>>> 建议：退出终端重新登录，或手动执行： type cp${RESET}"
else
    echo -e "${GREEN}>>> 当前检测结果：cp/mv 已成功替换为 advcp/advmv${RESET}"
fi

echo -e "${BLUE}====================================================${RESET}"
