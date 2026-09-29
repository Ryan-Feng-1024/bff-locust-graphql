# Locust 入口、参数与运行约定

本 reference 定义新建 BFF Locust 项目时的推荐外部契约，目的是让不同项目的启动方式相似、让 Web UI 与命令行走同一套场景选择逻辑。它不是要求旧项目立即重构的目录模板：已有项目的 `AGENTS.md`、可工作的入口和用户明确指定的约定优先。

## 适用边界

- 新项目默认采用本 reference 的入口和参数形状；已有项目先记录当前入口，再以兼容层逐步靠拢。
- `tag` 是测试场景标识，`operation` 是 GraphQL 请求名，`primary_request` 是报告判定对象。三者可以同名，但不能因为方便就混为一个概念。
- 业务 tag、profile 名、User 类名、账号模型和写入开关由目标项目决定，不从本 reference 固定复制。
- 真实运行前仍必须确认目标环境、完整 runtime profile、账号来源、数据风险和副作用授权。

## 推荐入口

新项目涉及 Locust 时，优先提供真实入口文件：

```text
src/load/locustfile.py
```

该入口负责：

1. 暴露可运行的 User 类或项目注册器发现的 User 类；
2. 注册自定义命令行参数；
3. 在用户创建前解析 runtime profile 和场景 tag；
4. 按 tag 过滤 User 类及其任务，避免无关用户类被实例化；
5. 保持 Web UI 启动与 headless 启动使用同一套解析和过滤函数。

如果项目历史上使用根目录 `locustfile.py`，可以保留一个兼容 wrapper，但 README、CI 和生成的执行命令应以实际可复用的标准入口为准。入口不得包含 token、Cookie、Authorization、storageState 或账号密码。

## 标准参数契约

### 场景选择

推荐通过 Locust 的 `events.init_command_line_parser` 注册：

```text
--scenarios <tag-or-tags>
```

实现约定：

- 参数值使用字符串，支持空格或逗号分隔多个 tag，例如 `--scenarios "tag-a tag-b"`；
- 设置 `include_in_web_ui=True`，使它出现在 Locust UI 的 Custom parameters 中；
- 多个 tag 采用 OR 语义：任务命中任意一个 tag 即保留；
- `--scenarios` 有值时优先于 Locust 内置 `--tags`；没有迁移需求时仍保留 `--tags` 作为兼容入口；
- tag 应先经过项目 catalog/registry 校验，未知 tag 应在启动阶段明确失败；
- 空值行为必须在项目 README 中说明。新项目推荐回退到安全的只读/健康检查 tag，或直接拒绝启动，不要无提示地运行混合读写全量任务。

### Runtime profile

推荐提供：

```text
--bff-config-profile <profile>
```

可选提供互斥的：

```text
--bff-config-path <path>
```

profile 应表达完整运行时配置，而不是只有 URL：至少要能说明 endpoint、认证/账号来源、客户端或设备上下文，以及该环境所需的数据权限。命令行 profile 应覆盖同名默认环境变量，但只影响本次进程；不要用 profile 参数绕过项目既有的外部凭据来源。

如果 profile 选择不适合暴露在 Web UI 中，可以只保留命令行参数，让 UI 启动命令预先固定 profile；`--scenarios` 仍应可在 UI 中填写。`--bff-config-profile` 与 `--bff-config-path` 应互斥，避免实际运行时来源不明确。

### Locust 通用参数

场景入口应直接兼容 Locust 的标准参数，不再要求用户为了 tag 手工传 User 类：

```text
-f/--locustfile
--headless
-u/--users
-r/--spawn-rate
-t/--run-time
--csv/--html/--json
```

项目可以增加客户端、设备或账号池参数，但必须同步到 README、UI/CI 入口和参数测试。

## 任务过滤实现

启动测试时应先完成以下顺序：

1. 读取并校验完整 runtime profile；
2. 解析 `--scenarios`，必要时回退 `--tags`；
3. 根据 tag 从所有候选 User 类中保留匹配类，并裁剪类内任务；
4. 没有任何匹配类时以非零结果停止；
5. 将自定义 tag 同步到 Locust 内置 tag 状态，避免二次过滤产生“无任务”或错误统计。

过滤逻辑应有离线单测，至少覆盖：多 tag 解析、`--scenarios` 优先级、只保留匹配 User 类和只保留匹配任务。Locust 的 User 元类可能在动态子类创建时合并父类任务；若采用动态子类过滤，应在类创建完成后再赋值 `tasks`，并用真实 Locust User 做一次回归验证。

## 命令行与 Web UI 示例

以下只展示参数形状，`<tag>`、`<profile>` 和业务写入开关必须替换为目标项目实际值。

单场景 headless smoke：

```bash
uv run locust -f src/load/locustfile.py \
  --scenarios <tag> --bff-config-profile <profile> \
  --headless -u 1 -r 1 --run-time 30s
```

多场景：

```bash
uv run locust -f src/load/locustfile.py \
  --scenarios "<read-tag-a> <read-tag-b>" \
  --bff-config-profile <profile> \
  --headless -u 1 -r 1 --run-time 30s
```

Locust UI：

```bash
uv run locust -f src/load/locustfile.py \
  --bff-config-profile <profile>
```

启动后在 Custom parameters 的 `scenarios` 输入一个或多个 tag。UI 与 CLI 必须进入同一个 parser/filter 路径，不能为 UI 另写一套默认场景选择逻辑。

可恢复写场景必须沿用项目既有的显式开关、原值恢复和 testRunId 隔离策略，例如：

```bash
<MUTATION_GUARD>=true uv run locust -f src/load/locustfile.py \
  --scenarios <reversible-tag> --bff-config-profile <profile> \
  --headless -u 1 -r 1 --run-time 30s
```

## 性能用法

`--scenarios` 只负责选择场景，不代表已经进入性能模式。性能运行还必须明确 users、spawn rate、run time、wait/workload profile、账号容量、输出产物和阈值。

直接运行一个只读性能场景时，命令形状可以是：

```bash
uv run locust -f src/load/locustfile.py \
  --scenarios <read-tag> --bff-config-profile <load-profile> \
  --headless -u 10 -r 2 --run-time 10m \
  --csv artifacts/performance/<read-tag>/locust
```

如果项目提供 performance wrapper，wrapper 应生成等价的 Locust 命令，并在元数据中记录 tag、runtime profile、users、spawn rate、run time、wait model、客户端入口和 testRunId。不能让 wrapper 退回到另一套 `UserClass + --tags` 语法而导致文档、UI 和脚本口径分裂。

共享账号或共享登录态未准备独立池时，性能运行固定单用户并串行执行；不可逆、数据依赖或会持续创建资源的场景默认只做 smoke，不作为普通压测 tag。

## 新项目验收清单

- README 同时给出单 tag headless、Locust UI 和性能用法；
- `src/load/locustfile.py` 或项目明确的等价入口能被命令行加载；
- `--scenarios` 能被 CLI 和 UI 解析，且场景过滤在用户创建前生效；
- runtime profile 选择、URL override、凭据来源和账号池约束写入项目约定；
- smoke/performance wrapper（若存在）与直接 Locust 命令使用同一 tag/profile 契约；
- 离线测试覆盖参数优先级、未知 tag、User/task 过滤和命令生成；
- 真实 smoke 前先完成静态/单测/类型检查，再按 profile 串行验证主请求、Locust failure、GraphQL errors 和业务失败。
