# AI Instructions

这个仓库是 Codex 与 Claude Code 的**统一约束唯一来源**。把跨工具、跨电脑都应遵守的规则写在 `common/POLICY.md`；工具专属补充分别写在 `codex/EXTRA.md` 与 `claude/EXTRA.md`。

## 目录

```text
common/POLICY.md          通用规则（主要编辑位置）
codex/EXTRA.md            仅适用于 Codex 的补充
claude/EXTRA.md           仅适用于 Claude Code 的补充
.local/CURRENT.md         本机聚合规则（忽略，不提交）
```

## 跨电脑使用

```bash
git clone <你的私有仓库地址> ~/projects/ai-instructions
```

每台电脑的 Codex/Claude Code 全局自定义指令中，应配置为读取本仓库，并按下面的“本地聚合协议”执行。仓库路径与本机实际克隆路径一致即可。

不使用定时任务，也不提供同步脚本；由每个新任务按需完成检查与聚合。

## 本地聚合协议

聚合文件固定为：`.local/CURRENT.md`。

该文件是本机缓存，必须保持在 `.gitignore` 中，禁止提交、推送或手工编辑。文件顶部必须包含 ISO 8601 格式的“最后聚合时间”。

每个新任务开始时，AI 按以下规则处理：

1. 若 `.local/CURRENT.md` 存在，且当前时间距“最后聚合时间”不足 **10 分钟**：不执行 Git 操作，直接读取并遵守该文件。
2. 若文件不存在或已经达到 10 分钟：先检查工作区是否有已跟踪文件的未提交修改；没有则执行 `git pull --ff-only`，再重新生成聚合文件。
3. 若拉取因网络、认证或本地已跟踪修改而失败，但旧聚合文件存在：保留并使用旧文件，不覆盖它；只有与当前任务有关时才说明刷新失败。
4. 新电脑首次没有聚合文件时：先读取 `common/POLICY.md` 和当前工具的专属补充文件，生成 `.local/CURRENT.md`；有可用远端时，应先完成 `git pull --ff-only`。首次同步失败时仍可根据本地已克隆的规则生成聚合文件。

### 聚合标准

`.local/CURRENT.md` 必须按顺序包含：

1. 本机缓存标识、源仓库绝对路径、最后聚合时间、最后聚合的git提交号；
2. `common包里面` 的完整内容；
3. `codex/EXTRA.md` 与 `claude/EXTRA.md` 的完整内容，并明确当前工具只应用自己的专属段落；
4. 冲突处理规则：项目内更具体的规则优先，但不得削弱安全要求。

## 日常修改

在任一电脑编辑规则并推送：

```bash
git add common/POLICY.md codex/EXTRA.md claude/EXTRA.md
git commit -m "update AI instructions"
git push
```

其他电脑在下一次新开任务且本地聚合缓存超过 10 分钟后，会按协议拉取并生成新缓存。已开始的会话通常不会重新加载指令；重要规则更新后请新开任务。

## 规则编写建议

- 写具体、可验证的规则，例如“修改代码后运行相关测试”，而非“注意质量”。
- 通用原则放 `common/POLICY.md`；仅某工具可做的操作放对应 `EXTRA.md`。
- 不要提交 API Key、密码、令牌或客户数据；敏感信息应保留在本机密钥链或环境变量中。
