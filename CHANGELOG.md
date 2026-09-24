# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/)。

## [0.2.0] - 2026-09-24

### Added

- 增加空目录和新项目启动工作流，覆盖问答决策、参考项目选择、最小骨架、Schema 接入和分阶段验收。
- 明确 GraphQL URL、相邻客户端代码、客户端生成类型与 live Schema 的证据边界。
- 增加副作用场景、真实 profile、账号与业务数据未就绪时的安全停止条件。

### Changed

- 扩展 Skill 描述和调用入口，使其同时覆盖从零建立与维护既有 BFF 测试项目。

## [0.1.0] - 2026-09-24

### Added

- 增加 BFF Locust GraphQL 通用 Skill 入口与 Codex 元数据。
- 增加项目发现、场景开发、GraphQL 资产、执行报告、故障诊断和验证工作流。
- 基于两个 BFF 测试项目完成前向验证。
- 增加显式运行时 profile、GraphQL 全深度契约、目标请求和串行 Locust 护栏。
- 增加 scaffold、catalog、GraphQL drift、builder、headless、lint 和类型检查的验收规则。
