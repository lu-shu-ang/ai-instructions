# AI Instructions

这个仓库是 Codex 与 Claude Code 的**统一约束唯一来源**。把跨工具、跨电脑都应遵守的规则写在 `common/POLICY.md`；工具专属补充分别写在 `codex/EXTRA.md` 与 `claude/EXTRA.md`。

## 目录

```text
common/POLICY.md          通用规则（主要编辑位置）
codex/EXTRA.md            仅适用于 Codex 的补充
claude/EXTRA.md           仅适用于 Claude Code 的补充
scripts/install.sh        将共享规则实际生成到本机全局指令文件
scripts/sync.sh           拉取远端更新，并重新生成本机指令
scripts/install-launchd.sh 安装 macOS 后台同步任务（默认每 1 分钟）
```

## 首次安装（每台电脑一次）

```bash
git clone <你的私有仓库地址> ~/projects/ai-instructions
cd ~/projects/ai-instructions
./scripts/install.sh
```

脚本会生成：

- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`

它们是由本仓库内容**实际生成**的全局指令文件，避免依赖模型是否会继续读取另一个路径。为保护已有配置，发现非本仓库管理的入口文件时，安装会停止；确认后可执行 `./scripts/install.sh --force`，原文件会备份为带时间戳的 `.bak` 文件。

如果此前已有自己维护的 `~/.codex/AGENTS.md` 或 `~/.claude/CLAUDE.md`，先把其中仍需要的规则迁入本仓库，再首次执行：

```bash
./scripts/install.sh --force
```

## 日常修改与同步

在任一电脑编辑规则并推送：

```bash
git add common/POLICY.md codex/EXTRA.md claude/EXTRA.md
git commit -m "update AI instructions"
git push
```

其他电脑在新开 Codex 或 Claude Code 会话**之前**运行：

```bash
~/projects/ai-instructions/scripts/sync.sh
```

已经开始的会话通常不会自动重新加载全局指令，所以“新会话前同步”是最可靠的实时性边界。可把这条命令设为你自己的 shell 别名或启动器的一部分。

## macOS 自动同步（推荐）

在每一台 Mac 上首次执行：

```bash
cd ~/projects/ai-instructions
./scripts/install.sh --force # 仅当首次替换已有的旧全局指令时需要
./scripts/install-launchd.sh
```

这会安装当前用户的 `launchd` 任务：登录时立即同步一次，之后每 60 秒检查 GitHub 是否出现新提交。检测到更新时，脚本以 fast-forward 方式拉取，并重新生成 `~/.codex/AGENTS.md` 与 `~/.claude/CLAUDE.md`。

```text
GitHub push → 最多约 60 秒 → 本机 git pull → 重建全局指令 → 新开 Codex/Claude Code 任务生效
```

运行中的任务不会改变上下文；对于重要规则变更，请新开任务。查看同步日志：

```bash
tail -f /tmp/ai-instructions-sync.log
```

停止自动同步：

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.lu-shu-ang.ai-instructions-sync.plist
```

## 规则编写建议

- 写具体、可验证的规则，例如“修改代码后运行相关测试”，而非“注意质量”。
- 通用原则放 `common/POLICY.md`；仅某工具可做的操作放对应 `EXTRA.md`。
- 不要提交 API Key、密码、令牌或客户数据；敏感信息应保留在本机密钥链或环境变量中。
