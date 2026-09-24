---
name: bff-locust-graphql
description: "从空目录建立或在现有仓库维护采用 Locust 与 GraphQL 的 BFF 测试项目，管理 Schema、场景、冒烟、性能测试、报告和故障诊断。当用户需要新建、迁移或维护此类项目时调用。"
---

# BFF Locust GraphQL

完成 BFF GraphQL 测试项目的初始化、适配和维护。现有仓库以其架构为准；空目录先定义最小项目契约，再建立可验证骨架。不要把任一参考项目的类名、目录、tag、profile 或业务链路当成所有项目的固定标准。

## 开始前

1. 读取目标仓库中作用域内的 `AGENTS.md`，再读取 `README.md`、治理文档以及与任务相关的项目级 skill。
2. 查看 `git status --short` 和相关 diff，保留用户已有改动。
3. 确认用户要的是分析、实现、执行还是诊断。仅诊断时不要擅自修复；实现请求要完成相应验证。
4. 以目标仓库当前代码、配置和生成器为事实来源。文档与实现冲突时，查清差异并在交付中说明。
5. 任何访问真实 BFF 或初始化账号池的操作，都先确认项目要求的运行时 profile、环境和凭据来源。不得从文件存在推断 profile 已加载，也不得把仅覆盖 URL 当成完整运行时配置。

首次接触仓库、接入新项目或无法确定入口时，先读 [references/project-discovery.md](references/project-discovery.md)。确认目标是空目录或尚无可运行框架时，再读 [references/new-project-bootstrap.md](references/new-project-bootstrap.md)。

## 工作流路由

- 从空目录建立或从其他 BFF 框架迁移新项目：读 [references/new-project-bootstrap.md](references/new-project-bootstrap.md)，再按需读取 Schema、场景和验证工作流。
- 新增、迁移或修改 Locust 场景：读 [references/scenario-authoring.md](references/scenario-authoring.md)，涉及 GraphQL operation 时再读 [references/graphql-assets.md](references/graphql-assets.md)。
- 生成、同步或审查 Schema、`.graphql`、变量模板：读 [references/graphql-assets.md](references/graphql-assets.md)。
- 运行冒烟、压测或生成报告：读 [references/execution-and-reporting.md](references/execution-and-reporting.md)。
- 排查接口、认证、场景注册、数据或报告失败：读 [references/troubleshooting.md](references/troubleshooting.md)。
- 完成代码变更、选择回归范围或交付前检查：读 [references/verification.md](references/verification.md)。

只读取当前任务需要的 reference。跨工作流任务按上述关系组合，不要一次性加载全部材料。

## 通用约束

- 优先复用项目已有的 GraphQL client、用户基类、会话状态、请求 builder、分页器、注册器和报告入口。
- 同一业务逻辑若同时服务 Locust 与 pytest/headless，保持两条路径兼容；正式冒烟和性能结论以项目规定的 Locust 入口为准。
- 登录态、租户态和设备上下文由统一状态对象维护，不在 task 间散传 token 或临时拼接隐式状态。
- GraphQL 请求使用项目生成器、文档和变量模板，不在 task 中复制完整请求体。
- 不得裁剪字段来隐藏 GraphQL errors、业务错误或 5xx。项目要求全深度契约时，保留完整选择集并让错误成为失败证据。
- 场景改动要同步项目实际采用的 catalog、阈值、workload、生成文档和测试映射；不要假设所有项目使用同一组字段。
- 报告模板只负责展示。CSV/JSON 解析、目标请求识别、阈值判定和业务失败分类应留在报告代码中。
- 共用账号池或登录态时串行运行真实 Locust 验证，避免互踢产生假失败。
- 不写入明文 token、密码、Cookie 或 session；使用目标项目已有的安全配置入口。
- Python 命令、依赖工具和日志方式服从目标项目约定；存在 `uv`、包装脚本或统一日志模块时优先复用。

## 完成标准

交付时说明：改动内容、采用的项目适配点、实际执行的验证、真实环境/profile（不暴露密钥）、失败或未执行项。不能只以“请求数大于零”判定通过；至少核对目标业务请求、Locust failure、GraphQL errors、业务失败和报告评估。

## 触发示例

- “给这个 BFF 新增一个 GraphQL Locust 场景，并补齐冒烟测试。”
- “同步最新 Schema，更新这个 operation 的 GraphQL 资产。”
- “跑一下该 tag 的 30 秒冒烟并生成报告。”
- “分析为什么报告里没有目标业务请求。”
- “把现有 BFF 压测框架适配到另一个类似服务。”
- “当前是空目录，请通过问答建立一个新的 BFF Locust GraphQL 测试项目。”
