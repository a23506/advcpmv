#!/usr/bin/env bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e "${BLUE}>>> 开始卸载 advcpmv ...${RESET}"

BIN_DIR="/usr/local/bin"

# Detect correct profile
if [ "$EUID" -eq 0 ]; then
    PROFILE="/root/.bashrc"
else
    PROFILE="$HOME/.bashrc"
fi

# ----------------------
# Remove binaries
# ----------------------
sudo rm -f "$BIN_DIR/advcp" 2>/dev/null && \
echo -e "${GREEN}>>> 已删除 $BIN_DIR/advcp${RESET}"

sudo rm -f "$BIN_DIR/advmv" 2>/dev/null && \
echo -e "${GREEN}>>> 已删除 $BIN_DIR/advmv${RESET}"

# ----------------------
# Remove alias
# ----------------------
echo -e "${YELLOW}>>> 清理 ${PROFILE} 中的 alias ...${RESET}"

sed -i "/alias cp='\/usr\/local\/bin\/advcp -g'/d" "$PROFILE"
sed -i "/alias mv='\/usr\/local\/bin\/advmv -g'/d" "$PROFILE"

echo -e "${GREEN}>>> alias 已清理${RESET}"

echo -e "${YELLOW}>>> 如需立即生效，请执行： source ${PROFILE}${RESET}"

echo -e "${GREEN}>>> 卸载完成，系统 cp/mv 已恢复默认${RESET}"
