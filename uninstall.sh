#!/usr/bin/env bash

# ===============================
#  颜色定义
# ===============================
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BLUE}>>> advcpmv 一键安装脚本开始运行...${RESET}"

set -e

# 这里用你自己的加速代理作为前缀，如果你想直接访问 GitHub，改回 raw.githubusercontent.com 也行
REPO_URL="https://docker.chenxinxin.me/https://raw.githubusercontent.com/a23506/advcpmv/main"
BIN_DIR="/usr/local/bin"
CUR_DIR="$(pwd)"

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
# 本地存在 advcp/advmv 则跳过下载
# ===============================
if [ -x "$CUR_DIR/advcp" ] && [ -x "$CUR_DIR/advmv" ]; then
    echo -e "${YELLOW}>>> 检测到当前目录已存在 advcp 和 advmv，跳过下载${RESET}"
else
    echo -e "${YELLOW}>>> 下载 advcp 和 advmv ...${RESET}"
    curl -fsSL "$REPO_URL/advcp" -o "$CUR_DIR/advcp"
    curl -fsSL "$REPO_URL/advmv" -o "$CUR_DIR/advmv"
    chmod +x "$CUR_DIR/advcp" "$CUR_DIR/advmv"
fi

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

# 尝试在当前 shell 里 reload 一下（对检测没啥用，只是顺手）
echo -e "${YELLOW}>>> 尝试重新加载 shell 配置 ...${RESET}"
source "$PROFILE" 2>/dev/null || true

# ===============================
# 关键点：在“交互式 shell”里跑 cp -h 来检测
# ===============================
echo -e "${YELLOW}>>> 检测 cp 是否已切换为 advcp ...${RESET}"

# 在一个新的交互式 bash 里执行 cp -h，保证 alias 生效
CP_HELP_OUTPUT="$(bash -ic 'cp -h 2>&1' 2>/dev/null || true)"

# 如果你想看真实输出，可以暂时打开这行：
# echo "DEBUG cp -h 输出: $CP_HELP_OUTPUT"

# 规则 1：包含 "Try '/usr/local/bin/advcp" -> 配置成功
if echo "$CP_HELP_OUTPUT" | grep -q "Try '/usr/local/bin/advcp"; then
    echo -e "${GREEN}>>> SUCCESS：cp 已成功切换为 advcp${RESET}"
    SHELL_RELOAD_REQUIRED=0

# 规则 2：包含 "Try 'cp" -> 系统原生 cp，提示需要重新登录
elif echo "$CP_HELP_OUTPUT" | grep -q "Try 'cp"; then
    echo -e "${RED}>>> WARNING：当前 cp 仍然是系统默认版本${RESET}"
    echo -e "${YELLOW}>>> 请退出 SSH / 终端重新登录后，再执行 cp -h 检查${RESET}"
    SHELL_RELOAD_REQUIRED=1

# 规则 3：其它情况（cp -h 报错、不支持、奇怪输出）
else
    echo -e "${RED}>>> WARNING：无法根据 cp -h 的输出判断当前状态${RESET}"
    echo -e "${YELLOW}>>> 建议你自己执行：cp -h 和 type cp 看看${RESET}"
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
echo -e "${GREEN}>>> advcpmv 安装流程执行完毕${RESET}"

if [ "$SHELL_RELOAD_REQUIRED" -eq 1 ]; then
    echo -e "${YELLOW}>>> 根据检测：cp 可能尚未切换，建议重新登录终端${RESET}"
else
    echo -e "${GREEN}>>> 根据检测：cp/mv 已成功切换为 advcp/advmv${RESET}"
fi

echo -e "${BLUE}====================================================${RESET}"
