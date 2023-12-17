# Release Note v23.12.17

- [assert_env] 
    - 基于 `indirect expansion` 的 *`two-dimensional`* 重构，更易于维护的命令断言
    - 自动导入 ASSERT_ENV
- [common] 常规应用中，自动导入 PROVIDER
    - [file] 修复当文件名含有等号时，file_get_hash 无法返回摘要的问题
- [app:asn1packer] 修复当摘要十六进制串前缀0时，unpack失败的问题
- 明确了应用（application）、资源（resource）等基础概念，明确了可读写目录
- 优化了流程规范，减少冗余
- 更新文档
- 调整了目录结构

```
./
├── apps/
│   ├── asn1packer/
│   │   ├── README.md
│   │   ├── ShellKit_asn1packer.sh*
│   │   ├── ShellKit_asn1unpacker.sh*
│   │   ├── TEST_CASE.sh*
│   │   └── TEST_DATAGEN.sh*
│   └── secure_asn1packer/
│       ├── PROVIDER.sh
│       ├── README.md
│       ├── rsa2048.key
│       ├── rsa2048.puk
│       ├── ShellKit_secure_asn1packer.sh*
│       ├── ShellKit_secure_asn1unpacker.sh*
│       ├── TEST_CASE.sh*
│       └── TEST_DATAGEN.sh*
├── common/
│   ├── ShellKit_assert.sh
│   └── ShellKit_file.sh
├── demos/
│   ├── color_timer/
│   │   ├── ASSERT_ENV.sh
│   │   ├── color_timer.sh*
│   │   └── README.md
│   └── painter/
│       └── README.md
├── index.html
├── LICENSE
├── log/
│   └── ShellKit_echo.sh
├── README.md
├── ReleaseNotes.md
├── ShellKit_assert_env.sh
├── ShellKit_common.sh
├── ShellKit_console_codes.sh
├── ShellKit_init.sh
└── ShellKit_log.sh

9 directories, 29 files
```

# Release Note v23.12.14

[ShellKit]

- 新增环境变量 `ShellKit_TEMP`，用于限定除输入输出外的可读写目录

# Release Note v23.9.16

[ShellKit]

- 设计和实现了 ShellKit 总体框架
- 梳理出了编码的流程规范
- 完成了 ShellKit 核心 README 的编写

[apps]

- 设计和实现了基于 `asn1` 编解码的数据安全打包/解包工具

[Demo]

- 提供了 [color_timer.sh](../Demo/color_timer/color_timer.sh) 用于演示 [console_codes](ShellKit_console_codes.sh) 的用法
