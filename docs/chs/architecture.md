
```asgl
cmake_tools/                         # repo root
├── CMakeLists.txt                   # meta for build/tests
├── cmake/                           # 所有模块、按职责划分
│   ├── cmake_tools.cmake            # 唯一入口（include(cmake_tools)）
│   ├── api.cmake                    # 对外函数与 option（稳定区）
│   ├── version.cmake                # repo 版本
│   ├── options.cmake                # 全局 option 和 cache 定义
│   ├── providers/                   # provider 实现（可新增）
│   │   ├── provider_vcpkg.cmake
│   │   ├── provider_system.cmake
│   │   ├── provider_fetch.cmake
│   │   └── provider_pkgconfig.cmake
│   ├── packages/                    # 特定包的 resolve & targets（按包分）
│   │   ├── sdl/
│   │   │   ├── sdl.cmake
│   │   │   └── sdl_targets.cmake
│   │   └── ffmpeg/
│   │       ├── ffmpeg_resolve.cmake
│   │       └── ffmpeg_targets.cmake
│   ├── targets/                     # target 工具：wrapper/create imported targets
│   │   ├── namespace.cmake
│   │   └── imported_helpers.cmake
│   ├── environment/                 # 平台/编译器/语言抽象
│   │   ├── platform.cmake
│   │   ├── compiler.cmake
│   │   └── languages.cmake
│   ├── diagnostics/                 # dump/report/assert 函数
│   └── utils/                       # guard/log/normalize/require
│
├── examples/                        # minimal 使用示例（多语言）
│   ├── cpp_minimal/
│   ├── mixed_lang/
│   └── sdl_example/
│
├── tests/                           # ctest/unit style（CMake driven tests）
│   ├── unit/
│   └── integration/
│
├── ci/                              # CI pipeline snippets
│   ├── github_actions.yml
│   └── pipeline_docs.md
│
├── docs/                            # usage, API, migration, contrib
│   ├── README.md
│   ├── API.md
│   ├── GUIDES.md
│   └── MIGRATION.md
│
├── scripts/                         # helper scripts (release, tag, bootstrap)
└── LICENSE, SECURITY.md, CODE_OF_CONDUCT
```