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

# 仓库地址（你仓库里 advcp/advmv 在 main 分支）
REPO_URL="https://raw.githubusercontent.com/a23506/advcpmv/main"
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
# 如果本地已有 advcp/advmv，则跳过下载
# ===============================
if [ -x "$CUR_DIR/advcp" ] && [ -x "$CUR_DIR/advmv" ]; then
    echo -e "${YELLOW}>>> 检测到当前目录已存在 advcp 和 advmv，跳过下载步骤${RESET}"
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

# 尽量在当前 shell 内加载一下（对当前脚本其实用处不大，但留着无害）
echo -e "${YELLOW}>>> 尝试重新加载 shell 配置 ...${RESET}"
# 非交互 shell 默认不展开 alias，这里只是为了后续你自己在这个 shell 里手动用
source "$PROFILE" 2>/dev/null || true

# ===============================
# 用你指定的“cp -h 回显”规则来检测
# 但！！！在一个新的交互式 bash 里跑，保证 alias 生效
# ===============================
echo -e "${YELLOW}>>> 检测 cp 是否已切换为 advcp ...${RESET}"

CP_HELP_OUTPUT="$(bash -ic 'cp -h 2>&1' 2>/dev/null || true)"

# DEBUG 输出来看一下实际字符串（如果你不想看就注释掉这一行）
# echo "DEBUG: cp -h output: $CP_HELP_OUTPUT"

# 规则 1：如果 cp -h 回显包含 “Try '/usr/local/bin/advcp” => 配置成功
if echo "$CP_HELP_OUTPUT" | grep -q "Try '/usr/local/bin/advcp"; then
    echo -e "${GREEN}>>> SUCCESS：cp 已成功切换为 advcp${RESET}"
    SHELL_RELOAD_REQUIRED=0

# 规则 2：如果 cp -h 回显包含 “Try 'cp” => 提示需要重新登录
elif echo "$CP_HELP_OUTPUT" | grep -q "Try 'cp"; then
    echo -e "${RED}>>> WARNING：当前 cp 仍然是系统默认版本${RESET}"
    echo -e "${YELLOW}>>> 请退出 SSH / 终端重新登录后，再执行 cp -h 检查${RESET}"
    SHELL_RELOAD_REQUIRED=1

# 规则 3：其它情况（cp -h 不支持 / 输出异常）
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
echo -e "${GREEN}>>> advcpmv 安装步骤执行完毕${RESET}"

if [ "$SHELL_RELOAD_REQUIRED" -eq 1 ]; then
    echo -e "${YELLOW}>>> 根据检测结果：可能还需要重新登录终端才能完全生效${RESET}"
else
    echo -e "${GREEN}>>> 根据检测结果：cp/mv 已成功切换为 advcp/advmv${RESET}"
fi

echo -e "${BLUE}====================================================${RESET}"
