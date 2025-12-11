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
- 操作行为与原生 cp/mv 一致
- `-g` 参数强制显示进度条（安装脚本自动设置 alias）

---

## 🚀 一键安装（推荐）

无需手动下载，只需执行下面一条命令：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/a23506/advcpmv/master/install.sh)
````


通过仓库自带脚本一键安装：

```bash
git clone https://github.com/a23506/advcpmv.git
cd advcpmv
chmod +x install.sh
./install.sh
```

安装脚本会自动：

1. 下载 `advcp` 和 `advmv`
2. 拷贝到 `/usr/local/bin`
3. 修改 `~/.bashrc` 使 cp/mv 自动使用带进度条版本
4. 自动检测安装是否成功

安装完成后，你的所有 cp / mv 都会自动显示进度。

---

## 🧹 卸载方法

恢复系统原生 cp/mv：

```bash
chmod +x uninstall.sh
./uninstall.sh
```

卸载动作包括：

- 删除 `/usr/local/bin/advcp` 与 `/usr/local/bin/advmv`
- 移除 `~/.bashrc` 中的 alias
- 自动恢复系统默认命令

---

## 🎯 使用说明

安装后可以像平常一样使用 cp 和 mv：

```bash
cp file.iso /mnt/data/
mv backup.zip /data/
```

输出示例：

```
 42% |███████████▎              | 420MB/1GB | 85MB/s | ETA 7s
```

---

## 🔧 手动使用（不修改系统 cp 和 mv）

如果你不想替换系统命令，可手动调用：

```bash
/usr/local/bin/advcp -g source destination
/usr/local/bin/advmv -g source destination
```

---

## ❓ FAQ

### cp 没有显示进度？
执行：

```bash
source ~/.bashrc
```

确保 alias 已写入：

```bash
grep advcp ~/.bashrc
```

---

### 支持 zsh 吗？
支持，但需手动写入 `.zshrc`：

```bash
echo "alias cp='/usr/local/bin/advcp -g'" >> ~/.zshrc
echo "alias mv='/usr/local/bin/advmv -g'" >> ~/.zshrc
source ~/.zshrc
```

---

### 如何确认安装成功？

```bash
type cp
```

输出应类似：

```
cp is aliased to `/usr/local/bin/advcp -g'
```

---

## 📜 License

本项目采用 GPLv3 许可。

---

## ❤️ 致谢

感谢 advcpmv 原作者及社区贡献者。
