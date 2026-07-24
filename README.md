# AI Instructions

这个仓库是 Codex 与 Claude Code 的**统一约束唯一来源**。把跨工具、跨电脑都应遵守的规则写在 `common/POLICY.md`；工具专属补充分别写在 `codex/EXTRA.md` 与 `claude/EXTRA.md`。

## 目录

```text
common/POLICY.md          通用规则（主要编辑位置）
codex/EXTRA.md            仅适用于 Codex 的补充
claude/EXTRA.md           仅适用于 Claude Code 的补充
scripts/install.sh        将本机全局入口配置为引用此仓库
scripts/sync.sh           拉取远端更新，并刷新本机入口
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

它们只包含到此仓库规则文件的绝对路径引用，因此规则仍由仓库统一维护。为保护已有配置，发现非本仓库管理的入口文件时，安装会停止；确认后可执行 `./scripts/install.sh --force`，原文件会备份为带时间戳的 `.bak` 文件。

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

## 规则编写建议

- 写具体、可验证的规则，例如“修改代码后运行相关测试”，而非“注意质量”。
- 通用原则放 `common/POLICY.md`；仅某工具可做的操作放对应 `EXTRA.md`。
- 不要提交 API Key、密码、令牌或客户数据；敏感信息应保留在本机密钥链或环境变量中。

