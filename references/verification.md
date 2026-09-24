# 变更验证

按改动风险选择最小充分验证。先运行窄而确定的检查，失败时先定位原因，再扩大范围。

## 基础步骤

1. 查看 `git status --short` 和本轮 diff，区分用户已有改动与本次改动。
2. 根据目标仓库的统一测试入口选择命令，优先使用 wrapper，不扩散零散命令。
3. 先确认测试 CLI 是否连离线 pytest 也强制要求 profile；若要求，使用项目 wrapper 或显式传递 profile，不先用裸命令试错。真实 BFF 验证前另行确认环境、账号池和数据风险。
4. 记录实际运行结果；不能只声称命令“应该通过”。

## 风险映射

| 改动范围 | 最小验证方向 |
| --- | --- |
| 单个 task/builder | 目标单测、headless 场景；行为改变时补单 tag Locust 冒烟 |
| GraphQL operation/schema | gqlclient 测试、生成器测试、资产 drift；必要时真实 query 验证 |
| 登录/会话/租户/设备 | 状态层测试及所有受影响入口的代表链路 |
| registry/tag/公共 User | load 层测试、场景选择测试和主要消费者回归 |
| catalog/分类/阈值 | catalog 严格校验、生成文档、规划或报告映射测试 |
| reporting/模板 | parser/evaluator 测试、目标与 aggregated 口径、显式主请求缺失时判失败、代表产物渲染 |
| workload/profile/CLI | 参数解析、各入口透传、示例配置和部署/CI 入口 |
| 跨层重构 | 项目 CI 入口、类型检查、GraphQL drift 和代表 Locust 冒烟 |

## 判定规则

- Python 变更不得引入新的类型检查错误；存量错误与本次新增错误分开报告。
- catalog 和生成文档以项目主数据源为准，不手工维护生成文件中的业务事实。
- 报告测试必须覆盖显式主请求存在、同名多行合并和显式主请求缺失三种情况；缺失时不能借用 fallback 指标通过。
- GraphQL 资产变更必须运行项目 drift 检查；若使用 live Schema，记录环境与 profile。
- 新增或更新场景时，若项目要求正式 Locust 验证，应确认目标业务请求实际出现且没有 failure、GraphQL error 或业务失败。
- scaffold 生成的 headless 测试必须检查是否只统计总请求；有登录或准备链路时改为按 catalog 主请求名统计，并保留失败数断言。
- 新增 Python 文件后运行项目 formatter/linter，不能只依赖类型检查。
- 共享账号池的 Locust 验证串行执行。
- 环境、权限或数据阻塞时，完成仍可执行的静态和本地验证，并明确列出缺失的真实验证。
- 不使用破坏性 Git 命令清理用户改动，不因测试生成物覆盖已有文件。

交付摘要应包括通过项、失败项、未执行项及原因，以及任何项目适配假设。
