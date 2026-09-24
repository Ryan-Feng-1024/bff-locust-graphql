# BFF Locust GraphQL Skill

一个用于维护 Python、Locust 与 GraphQL BFF 测试项目的通用 Codex Skill。

它帮助 Agent 在目标仓库已有架构内完成：

- 新增或更新 BFF GraphQL 测试场景
- 管理 Schema、GraphQL operation 和变量模板
- 执行 Locust 冒烟、性能测试与报告检查
- 维护场景 catalog、阈值和 workload 配置
- 诊断认证、上下文、GraphQL、场景注册和报告问题
- 按改动风险选择最小充分验证

该 Skill 不携带具体服务地址、账号、token、业务 tag 或固定 profile 名。目标项目的 `AGENTS.md`、README、代码、配置和项目级 Skill 始终优先。

## 安装

将仓库复制或克隆到 Codex skills 目录：

```bash
git clone <repository-url> ~/.codex/skills/bff-locust-graphql
```

如果通过其他路径下载，请确保最终目录名为：

```text
~/.codex/skills/bff-locust-graphql/
```

安装后在新的 Codex 任务或下一轮对话中使用。Codex 会根据 `SKILL.md` 的描述自动发现，也可以显式调用：

```text
$bff-locust-graphql 为当前 BFF 项目新增 TenantQuotaUsageDetail 场景，并完成本地契约验证。
```

## 使用示例

```text
给这个 BFF 新增一个 GraphQL Locust 场景，并补齐 catalog、headless 测试和验证。
```

```text
使用 $bff-locust-graphql 同步目标 operation 的 GraphQL 资产并检查 drift。
```

```text
分析为什么 Locust 原始 stats 中有前置请求，但报告没有目标业务请求。
```

```text
把现有 Locust + GraphQL 测试框架适配到另一个类似 BFF 服务。
```

## 工作方式

入口文件 [SKILL.md](SKILL.md) 只保留共享约束和工作流路由。详细流程按需加载：

- `references/project-discovery.md`：项目能力发现与适配
- `references/scenario-authoring.md`：场景新增和更新
- `references/graphql-assets.md`：Schema 与 GraphQL 资产
- `references/execution-and-reporting.md`：冒烟、压测和报告
- `references/troubleshooting.md`：故障诊断
- `references/verification.md`：改动验证

## 设计原则

- 先发现目标项目约定，再执行工作流。
- 复用项目已有基类、会话状态、builder、注册器和报告入口。
- 正式冒烟与性能结论遵循目标项目的 Locust 口径。
- 不裁剪 GraphQL 字段来掩盖服务端或契约错误。
- 显式主请求缺失必须失败，不能借用 `Aggregated` 指标判绿。
- 真实环境运行前必须确认 profile、账号池和数据风险。
- 保留用户已有改动，不使用破坏性 Git 操作。

## 验证

仓库包含发布前检查脚本：

```bash
sh scripts/validate.sh
```

也可以直接运行 Codex 官方 Skill 校验器：

```bash
uv run --with pyyaml python \
  "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" \
  .
```

## 版本

当前版本见 [VERSION](VERSION)。版本变更记录见 [CHANGELOG.md](CHANGELOG.md)。

## 许可证

本项目使用 [MIT License](LICENSE)。
