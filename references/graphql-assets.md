# GraphQL Schema 与资产管理

GraphQL 资产应来自同一份契约来源。先发现项目已有的 schema 获取、operation 生成、变量生成和 drift 检查入口，再执行变更。

## 推荐顺序

1. 确认目标环境和运行时 profile，判断本次使用仓库内 Schema 还是需要从 server 刷新。
2. 需要验证最新契约时，使用项目现有脚本获取 introspection/schema；不得绕开其认证和环境保护。
3. 使用项目生成器按 operation 名生成或更新 `.graphql` 与变量模板。
4. 同步提交或更新生成器要求的 schema、operation、变量模板及配置覆盖。
5. 审查 diff，确认 operation 类型、变量类型、嵌套参数和选择集符合预期。
6. 运行项目的 GraphQL client 测试和资产 drift 检查。

## 契约规则

- 项目采用全深度生成时，默认保留全深度选择集。字段导致 BFF、resolver 或 Schema 报错，应记录为契约问题，不能通过删字段制造假通过。
- 同一参数名在不同嵌套字段需要不同变量时，优先使用项目的嵌套参数白名单、变量别名或 generator override，不手工篡改生成结果。
- operation 文档和变量模板必须匹配。必填变量、枚举、分页参数和 input object 改动要同步到 builder 与测试数据。
- 不直接编辑生成文档来规避 drift；若生成器结果不正确，修生成规则或显式覆盖配置，并补相应测试。
- Schema 更新可能影响多个 operation。根据项目 drift 工具检查纳管资产，不只测试当前文件。

## 运行验证

- 静态验证至少覆盖解析、生成器单测或项目提供的 gqlclient 测试。
- drift 验证应基于项目声明的 Schema 来源，并明确是本地契约还是 live server。
- 隔离验收可以用仓库内 Schema 验证生成、drift 和接线机制，但只能证明与本地契约一致。项目要求 server 当前 Schema 时，交付前仍须通过正式获取/生成入口重新同步；不得把本地 Schema 通过表述为 live 契约已确认。
- 真实请求需要检查 HTTP 状态、GraphQL `errors`、业务错误码和目标数据结构。
- 如果仅同步资产而用户未授权调用真实环境，不擅自发起 mutation。

## 常见失败分类

| 症状 | 优先检查 |
| --- | --- |
| Unknown field/argument | Schema 版本、生成来源、operation 是否陈旧 |
| Variable type mismatch | Schema 参数类型、变量模板和 builder |
| 嵌套字段缺少参数 | generator override、白名单与 operation 级配置 |
| HTTP 200 但场景失败 | GraphQL errors、业务码和 response parser |
| drift 大面积变化 | 是否切错环境、Schema 是否完整、生成器配置是否变化 |

交付时说明 Schema 来源、生成命令、关键 diff 和 drift 结果，不泄露认证信息。
