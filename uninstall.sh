#!/usr/bin/env bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BLUE}>>> 开始卸载 advcpmv ...${RESET}"

BIN_DIR="/usr/local/bin"

# ----------------------
# 删除安装的文件
# ----------------------
if [ -f "$BIN_DIR/advcp" ]; then
    sudo rm -f "$BIN_DIR/advcp"
    echo -e "${GREEN}>>> 已删除 $BIN_DIR/advcp${RESET}"
else
    echo -e "${YELLOW}>>> advcp 未安装，跳过${RESET}"
fi

if [ -f "$BIN_DIR/advmv" ]; then
    sudo rm -f "$BIN_DIR/advmv"
    echo -e "${GREEN}>>> 已删除 $BIN_DIR/advmv${RESET}"
else
    echo -e "${YELLOW}>>> advmv 未安装，跳过${RESET}"
fi

# ----------------------
# 移除 alias
# ----------------------
echo -e "${YELLOW}>>> 清理 ~/.bashrc 中的 alias ...${RESET}"

sed -i "/alias cp='\/usr\/local\/bin\/advcp -g'/d" ~/.bashrc
sed -i "/alias mv='\/usr\/local\/bin\/advmv -g'/d" ~/.bashrc

echo -e "${GREEN}>>> alias 已清理${RESET}"

# 重新加载 bashrc
source ~/.bashrc

echo -e "${GREEN}>>> 卸载完成，系统 cp/mv 已恢复默认。${RESET}"
