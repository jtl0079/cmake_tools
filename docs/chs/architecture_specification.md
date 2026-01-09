# 1 Skeleton-First Design
## 1.1 Description
> Design:（Priority / Category / Domain / Template）
> 本文档定义了 cmake_tools 的**根本架构思想**。  
> 它不是“目录说明”，而是一套**代码坐标系统**。  
> cmake_tools 中的每一行代码，都必须能映射到这套坐标中。

---

## 1.2 核心思想（第一性原则）

cmake_tools **不是**围绕：

- 功能
- 第三方库
- 文件或模块

来组织的。

而是围绕一个**四维骨架坐标系**：

```
<priority>/<category>/<domain>/<pattern> [+ context]

```
| 维度       | 含义              | 是否必填 |
| -------- | --------------- | ---- |
| priority | 语义优先级 / 层级角色    | 必填   |
| category | 使用者视角的业务分类      | 条件必填 |
| domain   | 技术 / 第三方库 / 标准域 | 条件必填   |
| pattern  | 架构模式 / 实现组织     | 必填   |
| context  | 可选细分上下文         | 可选   |
```
priority ∈ { api, core, packages, providers, utils}
category ∈ { audio, video, math, signal, time, 
  text, data, filesystem, network, process ...
}		
domain	 ∈ { sdl, ffmpeg, std }
pattern  ∈ { 
}
```

## 1.3 特例 / 实例
1. 当 \<priority\> = provider 时，其规则等同于
```
- <priority>/<->/<domain>/<pattern> [+ context]
- <priority>/<doamin>/<pattern> [+ context]

eg.
 provider/sdl/fetch/
```

# 2 四个维度的定义
## 2.1 《priority》
\<priority\> —— 依赖优先级（纵向维度，最重要）

决定「谁可以依赖谁」
```
priority ∈  { api, core, packages, providers, utils }
```

| priority  | 职责               | 维度骨架 |
| --------- | ----------------- | --------------- |
| api       | 对外公开 API（函数声明） | \<priority>/\<category>/\<pattern> |
| packages  | 面向业务语义的功能包     | \<priority>/\<category>/\<domain>/\<pattern> |
| core      | 内部共享实现            | \<priority>/\<category>/\<pattern> |
| utils     | 无副作用工具函数        | \<priority>/\<category>/\<pattern> |
| providers | 外部依赖来源 / 获取方式  | \<priority>/\<domain>/\<pattern> |

铁律：
- 依赖只能 向下
- 不允许环形依赖
- packages → core / utils / providers ✅
- core → packages ❌


## 2.2 《category》
回答问题：这是哪一类能力？
* **category = 使用者思考问题的方式**
* 描述“我在做什么”，而不是“我用了什么库”
```
category ∈ {	
	audio,	video,	math,		signal,		time, 
	text,	data,	filesystem,	network,	process ...
}
```

## 2.3 《domain》
<\domain\> —— 技术域 / 世界边界 / 来源
```
domain ∈ { sdl, ffmpeg, stl, std, chrono, posix, win32, custom, none }
```

规则：
- core 通常 没有 domain
- framework 只做抽象层面的 domain 投射
- modules 必须绑定 具体 domain

## 2.4 《pattern》
\<pattern\> —— 组织 / 执行模板

回答问题：代码按什么结构和模式存在？
代码应当按什么结构和模式存在？

pattern 描述的是可复用的结构协议（structural protocol），
它定义代码如何被组织、约束与协作，而不承载任何业务语义。

pattern ≠ business

pattern = structure + rule + responsibility

### 2.4.0 pattern 总集合
```
pattern ∈ {
  api,            # 对外接口协议
  facade,         # 聚合/门面
  entry,          # 入口点
  config,         # 配置与选项
  resolve,        # 解析 / 决策
  detect,         # 环境探测
  select,         # 策略选择
  fetch,          # 获取外部资源
  target,         # target 构建/包装
  backend,        # 具体实现
  adapter,        # 域适配
  mapper,         # 结构映射
  pipeline,       # 执行流程
  registry,       # 注册/索引
  policy,         # 规则集合
  helper,         # 内部辅助（非 utils）
  internal        # 明确禁止外部使用
}

```

| 标记 | 含义             |
| -- | -------------- |
| ✅  | 允许，且是推荐用法      |
| ⚠️ | 有条件允许（需严格遵守定义） |
| ❌  | 明确禁止           |


pattern × priority 是一个受限矩阵

⚠️ 不是每个 priority 都能使用所有 pattern

| Pattern \ Priority | api | packages | core | utils | providers |
| ------------------ | --- | -------- | ---- | ----- | --------- |
| **api**            | ✅   | ❌        | ❌    | ❌     | ❌         |
| **facade**         | ⚠️   | ✅        | ❌    | ❌     | ❌         |
| **entry**          | ✅   | ⚠️       | ❌    | ❌     | ❌         |
| **config**         | ✅   | ⚠️       | ⚠️   | ❌     | ❌         |
| **resolve**        | ❌   | ✅        | ⚠️   | ❌     | ❌         |
| **detect**         | ❌   | ❌        | ✅    | ⚠️    | ❌         |
| **select**         | ❌   | ❌        | ✅    | ❌     | ❌         |
| **fetch**          | ❌   | ❌        | ❌    | ❌     | ✅         |
| **target**         | ❌   | ✅        | ❌    | ❌     | ❌         |
| **backend**        | ❌   | ✅        | ⚠️   | ❌     | ❌         |
| **adapter**        | ❌   | ⚠️       | ✅    | ❌     | ❌         |
| **mapper**         | ❌   | ⚠️       | ✅    | ❌     | ❌         |
| **pipeline**       | ❌   | ⚠️       | ✅    | ❌     | ❌         |
| **registry**       | ❌   | ⚠️       | ✅    | ❌     | ❌         |
| **policy**         | ❌   | ⚠️       | ✅    | ❌     | ❌         |
| **helper**         | ❌   | ❌        | ⚠️   | ❌     | ❌         |
| **internal**       | ❌   | ❌        | ⚠️   | ❌     | ❌         |


### 2.4.1 《api pattern》
api pattern = 对外稳定调用面

- 允许用户直接调用的函数集合

- 不包含实现

- 不包含第三方细节

- 不包含条件逻辑

**允许的 priority**
```
priority ∈ { api }
```
示例坐标
```
api/audio/api/
api/video/api/
```

---

### 2.4.2 《facade pattern》

定义

facade = 对多个子系统的统一入口

- 聚合多个 packages
- 隐藏内部层级复杂度
---
### 2.4.3 《entry pattern》
定义

entry = 系统入口点

- 初始化

- 注册

- 全局状态准备
eg.
```
api/audio/entry/
```
---
### 2.4.4《config pattern》
定义

config = 用户/系统配置定义

- option

- cache

- 默认值
eg.
```
api/audio/config/options.cmake
core/audio/config/defaults.cmake

```
---
### 2.4.5 《resolve pattern》
定义

resolve = 决策层

- 根据条件决定“用哪个”

- 不做实现

- 不直接 fetch

eg.
```
packages/audio/ffmpeg/resolve.cmake
```
---

### 2.4.6 《detect pattern》
定义

detect = 探测外部环境

- OS

- compiler

- capability

eg.
```
core/compiler/detect/
```
---

### 2.4.7 《select pattern》
定义

select = 策略选择

- provider 选择

- backend 选择

- eg.
```
core/provider/select/
```
---
### 2.4.8《fetch pattern》（provider 专属）
定义

fetch = 获取外部资源

- FetchContent

- vcpkg

- system
eg.
```
providers/sdl/fetch/
```

### 2.4.9 《target pattern》
定义

- target = target 创建与包装

- imported target

- namespace
- alias
eg.
```
packages/sdl/target/
```
---

### 2.4.10 《backend pattern》
定义

backend = 具体实现

- 强绑定 domain

- 不可复用

eg.
```
packages/audio/ffmpeg/backend/
```
---
### 2.4.11《adapter / mapper pattern》
定义

adapter / mapper = 域之间的结构转换

- API 形态转换

- target 形态转换

eg.
```
core/mapper
package/audio/sdl/mapper
```
---
### 2.4.12 《pipeline pattern》
定义

pipeline = 执行流程编排

- 顺序

- 生命周期

- 状态推进

- eg.
```
core/audio/pipeline/
```
---

### 2.4.13 《registry pattern》
定义

registry = 注册表 / 索引

- backend registry

- provider registry

### 2.4.14 《helper / internal pattern》
定义

helper / internal = 内部辅助

- 明确不对外

- 非 utils

- 可随时重构

## 2.5 [+ content]
content = 内部细分结构
