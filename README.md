# advcpmv — Enhanced cp & mv with progress bar

`advcpmv` 为 Linux 系统提供增强版的 `cp` 和 `mv` 命令，支持进度条显示、速度统计等高级功能，非常适合处理大型文件复制与移动任务。

本仓库提供：
- 改进版 `advcp`
- 改进版 `advmv`
- 一键安装脚本 `install.sh`
- 一键卸载脚本 `uninstall.sh`

---

## 🚀 功能特性

- 完全替代系统 `cp` / `mv`
- 显示进度条与实时传输速度
- 操作行为与原生 cp/mv 一致（加入 `-g` 参数自动显示进度）

---

## 📥 安装方法（推荐）

你可以通过 GitHub 仓库提供的安装脚本进行安装：

```bash
git clone https://github.com/a23506/advcpmv.git
cd advcpmv
chmod +x install.sh
./install.sh
