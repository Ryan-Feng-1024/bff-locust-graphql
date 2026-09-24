# 项目发现与适配

首次处理一个仓库时，先形成最小能力地图。目标是找出项目真实入口和约束，不要求仓库符合某个固定目录模板。

## 读取顺序

1. 读取作用域内的 `AGENTS.md`、根目录 `README.md` 和项目治理文档。
2. 检查项目级 AI 资产，例如 `.ai/skills/`、`.codex/skills/` 或仓库声明的其他位置。
3. 查看依赖与命令入口，例如 `pyproject.toml`、`uv.lock`、shell wrapper、任务运行器和 CI 配置。
4. 搜索 Locust、GraphQL、报告、运行时配置和测试目录，不凭名称猜测实现。
5. 查看一条已工作的代表场景，沿着 tag、注册、task、client、资产、headless 测试和报告追踪完整链路。

优先使用 `rg --files`、`rg`、`git status --short` 和 `git diff` 做只读发现。
查询 JSON/YAML 主数据前，先查看一条完整记录或读取项目 loader 的数据模型；优先调用项目 loader、validator 或查询脚本，不凭参考项目的字段名编写临时查询。查询结果异常地全空或全量命中时，先验证查询本身再形成结论。

## 能力地图

至少确认以下内容；缺失项记录为项目能力缺口，而不是立即创建新框架。

| 能力 | 需要确认的事实 |
| --- | --- |
| Locust 入口 | locustfile、Web/headless 参数、tag 选择方式 |
| 辅助回归 | pytest/headless runner、测试放置位置、失败断言 |
| 场景组织 | task 目录、注册机制、命名和基类 |
| 会话上下文 | 认证、租户、设备、账号池和状态对象 |
| GraphQL | client、schema、operation、变量模板和生成器 |
| 场景治理 | catalog、分类规则、主请求、执行策略和生成文档 |
| 负载模型 | 用户数、spawn rate、等待模型、workload profile |
| 报告 | 原始产物、解析器、阈值、模板和输出目录 |
| 验证 | 统一测试入口、类型检查、GraphQL drift 和 CI |
| 运行时配置 | profile 选择方式、URL 覆盖语义、凭据和账号池来源 |

## 适配判断

- 类似 `BaseGraphQLUser`、`TenantScopedGraphQLUser`、`SessionState` 的名字只是可能存在的实现。以职责和调用关系识别抽象，不以类名判断能力。
- 类似 `scenario_catalog.json` 的文件可能不存在。若项目有其他主数据源，沿用它；若完全没有治理层，先向用户说明缺口和最小引入方案。
- 如果项目提供场景 scaffold、GraphQL generator、报告 wrapper 或 test-suite wrapper，优先调用它们，不重新手写同类逻辑。
- scaffold 只代表项目认可的起始结构。生成后仍要审查 diff、替换占位数据、补全 Schema 契约，并确认测试真正断言主请求及失败统计。
- 若项目只有 Locust 而没有 pytest 辅助路径，不擅自扩大为双框架改造；新增能力是否值得引入由用户目标和维护成本决定。
- 若多个文档给出不同命令，以当前代码可解析的入口为准，并记录文档漂移。

## 真实环境护栏

- 找出显式 profile 的 CLI 参数和环境变量，以及 URL override 的实际作用范围。
- 检查 profile 是否同时提供 endpoint、账号池、租户或设备配置。只传 URL 通常不足以初始化这些上下文。
- 运行前确认目标环境、profile 名和账号容量；不得在输出中展示账号密码或 token。
- 可能修改业务数据的场景，先确认执行策略、隔离数据和清理方式。用户未授权真实写操作时只做静态或本地验证。

完成发现后，用几句话记录项目采用的入口和本次适配点，再进入具体工作流。
