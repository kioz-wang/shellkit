# ShellKit

A great baSh-oriented software develop Kits.

see [Release Note](ReleaseNotes.md)

## 版本号

`ShellKit` 并没有使用常见的[语义化版本](https://semver.org/lang/zh-CN/)，而是采用了简单清晰的基于日期的版本规则，格式等同如下命令的输出：

```
date +v%y.%-m.%-d
```

非正式的版本号中，可以使用形如 `-suffix.1` 的后缀。

## 运行时

### 初始化

执行 `source /path/to/ShellKit_init.sh` 以初始化 `ShellKit` 运行时。

首先导出几个环境变量：

- `ShellKit_ROOT`
    - `ShellKit` 根目录的绝对路径（`ShellKit_init.sh` 所在的目录）
- `ShellKit_Version`
    - `ShellKit` 版本号
- `ShellKit_TEMP`
    - 除输入输出外，`ShellKit` 可读写的目录（通过环境变量配置，默认为 `/tmp`）

> `ShellKit_ROOT` 通过 `realpath` 命令获取，移植时需要注意这个地方

然后依次初始化以下模块（**应当始终保证这些模块可以成功初始化**）：

1. assert_env
2. console_codes
3. log
4. common

### 可读写目录

运行时只会读写如下目录：

- 输入所在的目录
- 输出所在的目录
- `ShellKit_TEMP` 指定的目录

## 运行时模块

模块文件不具备可执行权限。使用 `source` 导入模块文件，以向当前上下文提供其能力。

### assert_env

`ShellKit_assert_env.sh` 中约定了系统命令的注册信息三元组 `einfo(ename epath echeck)`，实现了函数 `ShellKit_assert_env` 对注册信息执行断言：

- 重复的注册将被忽略
- 缺少 `echeck` 则不做检查
- 断言失败，立即终止运行时所在进程

`einfo` 被追加到 `ShellKit_ENV_lst` 中，最后遍历数组，执行断言，以保证所有系统命令的可用性。

> 移植时根据初始化错误提示，逐个修正系统命令的注册信息。

如果运行时由应用初始化，那么也叫应用运行时。在应用运行时中，如果应用所在目录下存在 `ASSERT_ENV.sh` 文件，那么会优先对其执行断言。

### console_codes

该模块只有一个单独的文件 `ShellKit_console_codes.sh`，提供了一系列终端控制函数。

> 更多内容，可阅读 `man console_codes` 和 `man tput`

> 关于终端的更多内容，可参阅 [XTerm](https://invisible-island.net/xterm/xterm.html), [Vttest](https://invisible-island.net/vttest/vttest.html)

### log

`ShellKit_log.sh` 中配置了默认的日志等级使能。

`log/` 下给出了该模块的多种实现：

- ShellKit_echo
    - 基于 `echo -e` 的简单实现（`echo` is bash-builtin）

### common

`ShellKit_common.sh` 中定义了 `ShellKit` 返回值。

`common/` 下给出了常用的基本的功能实现：

- ShellKit_assert
    - `assert` 系列函数，提供了参数数量判定、文件/目录读写权限判定等功能，当判定结果为 `false` 时，会调用 `exit` 退出当前进程
- ShellKit_file
    - 实现了基于文件的大小获取、哈希、`base64` 编码等功能
    - 包装了文件/目录读写权限判定函数，可用于 `if` 条件表达式

最后，在常规的应用运行时（不包含 `tgen`, `tcase`）中，会尝试导入应用所在目录下的 `PROVIDER.sh` 文件。

## 资源

资源（resource）是特殊的常量或变量。`ShellKit` 约定了资源的活动性：静态（static）和动态（dynamic），以及资源的活动范围：全局（global）和局部（local）。

下面的表格梳理了关于资源的各种概念，并给出了命名要求：

|prefix |static         |dynamic        |/|
|-------|---------------|---------------|--|
|global |`_gs_`\|`_s_`  |`_gd_`         |限定在 `ShellKit_TEMP` 指定的目录下|
|local  |`_ls_`\|`_s_`  |`_ld_`\|`_`    |生命周期较短，使用灵活|
|/|总是安全的；通常不需要严格区分活动范围|保持谨慎：初始化和释放|/|

> 输入输出是特殊的资源。

## app

具备可执行权限，并且具备直接的输入输出处理能力的文件，称为应用（application）文件。

`ShellKit` 为其约定了两种流程规范：`rapp` 和 `app`。两者的主要区别是，`app` 的主程序实现为 `main` 函数，整体结构更清晰；`rapp` 更加灵活，便于实现需要复杂资源管理的程序。

应用中可以调用另一个应用，以获取其实现的通用能力。

### asn1packer

> README [asn1packer](apps/asn1packer/README.md)

### secure_asn1packer

> README [secure_asn1packer](apps/secure_asn1packer/README.md)

## demo

例程是特殊的应用，通常用于功能演示，而非提供通用能力。

### color_timer

> README [color_timer](demos/color_timer/README.md)

### painter

> README [painter](demos/painter/README.md)

## 测试

> `tgen` 和 `tcase` 都是特殊的应用。

### tgen

执行应用所在目录下的 `TEST_DATAGEN.sh` 以生成测试数据。

### tcase

执行应用所在目录下的 `TEST_CASE.sh` 以执行测试用例。

## APIs

### assert_env

```
einfo name(ECHO) path(/usr/bin/echo) check(--version)
einfo name(CAT) path(/usr/bin/cat) check(--version)
einfo name(SLEEP) path(/usr/bin/sleep) check(--version)
einfo name(OPENSSL) path(/usr/bin/openssl) check(version)
einfo name(SED) path(/usr/bin/sed) check(--version)
einfo name(AWK) path(/usr/bin/awk) check(--version)
einfo name(BASENAME) path(/usr/bin/basename) check(--version)
einfo name(DIRNAME) path(/usr/bin/dirname) check(--version)
einfo name(REALPATH) path(/usr/bin/realpath) check(--version)
einfo name(RM) path(/usr/bin/rm) check(--version)
einfo name(WC) path(/usr/bin/wc) check(--version)
einfo name(LS) path(/usr/bin/ls) check(--version)
einfo name(PRINTF) path(/usr/bin/printf) check(--version)
einfo name(HEAD) path(/usr/bin/head) check(--version)
einfo name(TAIL) path(/usr/bin/tail) check(--version)
einfo name(GREP) path(/usr/bin/grep) check(--version)
einfo name(DD) path(/usr/bin/dd) check(--version)
einfo name(MV) path(/usr/bin/mv) check(--version)
```

### console_codes

**颜色和样式控制**

| API | 作用 |
| --- | --- |
| ShellKit_ccode_SGR_Reset | 清除所有颜色和样式 |
| ShellKit_ccode_SGR_Color | 将前景或背景色设置为 8-Color (black/red/green/brown/blue/magenta/cyan/white/default) |
| ShellKit_ccode_SGR_Color256 | 将前景或背景色设置为 256-Color |
| ShellKit_ccode_SGR_Style | 设置或清除样式 (bold/dim/italic/underscore/blink/reverse/underline) |

**位置控制**

| API | 作用 |
| --- | --- |
| ShellKit_ccode_CSI_Move | 基于当前位置，向指定方向（up/down/right/left）移动光标 |
| ShellKit_ccode_CSI_MoveXY | 移动光标到指定坐标，超出屏幕将移动到边缘；左上角为 (1,1) |
| ShellKit_ccode_CSI_MoveSaveRest | 保存当前的光标位置/移动光标到上一次保存的位置 |
| ShellKit_ccode_CSI_CPR | 将光标坐标赋值给指定变量 |

**缓冲区操作**

| API | 作用 |
| --- | --- |
| ShellKit_ccode_CSI_Erase | 对终端显示，擦除从光标位置到显示区域左上角（up）/右下角（down）或全部（whole）/包含滚动缓存区（scroll）的内容；</br>对光标所在行，擦除从光标位置到行首（up）/行尾（down）或整行（whole）的内容；</br>对字符，擦除从光标位置开始指定数量的字符 |
| ShellKit_ccode_CSI_InsDel | 从当前行开始，插入/删除指定数量的空行；</br>从光标位置开始，插入/删除指定数量的（空白）字符 |

**其他**

| API | 作用 |
| --- | --- |
| ShellKit_ccode_ESConly | Reset(ris)/Linefeed(ind)/Newline(nel)/Reverse linefeed(ri) |
| ShellKit_ccode_CSI_PriMode | 打开/关闭反色（scnm）、光标显示（tecm） |

### log

默认日志等级配置如下：

| level | status |
| ----- | ------ |
| SHELLKIT_LOG_DEBUG_ENABLE | false |
| SHELLKIT_LOG_VERB_ENABLE | false |
| SHELLKIT_LOG_INFO_ENABLE | true |
| SHELLKIT_LOG_WARN_ENABLE | true |
| SHELLKIT_LOG_ERROR_ENABLE | true |

#### ShellKit_echo

| API | Color/Style |
| --- | ----------- |
| skechoi | `ShellKit_ccode_SGR_Color -f green` |
| skechov | `ShellKit_ccode_SGR_Color -f blue` |
| skechow | `ShellKit_ccode_SGR_Color256 -f -r 255 -g 255` |
| skechoe | `ShellKit_ccode_SGR_Color -f red && ShellKit_ccode_SGR_Style blink` |
| skechod | `ShellKit_ccode_SGR_Color256 -f -r 160 -g 160 -b 160` |

### common

返回值定义如下：

**常规**

| errno | 含义 |
| ----- | ---- |
| SHELLKIT_RET_SUCCESS | |
| SHELLKIT_RET_UNSUPPORT | 不支持 |
| SHELLKIT_RET_INVPARAM | 无效的参数 |
| SHELLKIT_RET_NOTFOUND | |
| SHELLKIT_RET_NOMEMORY | 内存不足 |
| SHELLKIT_RET_OUTOFRANGE   | 越界访问 |
| SHELLKIT_RET_SUBPROCESS   | 子程序错误 |
| SHELLKIT_RET_FILEIO   | 文件读写错误 |
| SHELLKIT_RET_ASN1 | ASN1 编解码出错 |
| SHELLKIT_RET_MISC | 未归类错误 |
| SHELLKIT_RET_BE_CAREFUL   | 可以避免的运行时错误 |

**信息安全**

| errno | 含义 |
| ----- | ---- |
| SHELLKIT_RET_CYBER_CRYPTO | 机密性（Confidentiality） |
| SHELLKIT_RET_CRYPTO_SYM   | 机密性：对称密码学（Symmetric） |
| SHELLKIT_RET_CRYPTO_ASYM  | 机密性：非对称密码学（Asymmetric） |
| SHELLKIT_RET_CYBER_AUTHEN | 认证（Authentication） |
| SHELLKIT_RET_CYBER_INTEGR | 完整性（Integrity） |
| SHELLKIT_RET_CYBER_NON_RE | 不可否认性（Non-repudiation）|

#### ShellKit_assert

| API | 作用 |
| --- | --- |
| assert_params_num_min | 命令行参数数量检查 |
| assert_file_exist     | 文件应当存在      |
| assert_files_r        | 文件应当可读      |
| assert_files_w        | 文件应当可写      |
| assert_dir_exist      | 目录应当存在      |
| assert_dirs_r         | 目录应当可读      |
| assert_dirs_w         | 目录应当可写      |

#### ShellKit_file

| API | 作用 |
| --- | --- |
| file_get_size | 输出文件大小 |
| file_get_hash | 输出文件摘要      |
| file_base64 | 对文件或 `stdin` 中的内容进行 `base64` 编解码并输出 |
| file_access_r | 文件是否可写      |
| file_access_w | 文件是否可写      |
| dir_access_r  | 目录是否可读      |
| dir_access_w  | 目录是否可写      |

## 编码规范（CodeSpec）

### 流程规范（Process）

#### raw arguments

**[P.rarg.0]** *命令行参数数量检查*

```bash
if [ $# -lt 2 ]; then
    echo "Tell me two variables' name for coordinate"
    return 1
fi
```

```bash
assert_params_num_min "${app}" "{ifile0} [{ifile1} ...] {ofile}" 2 $#
```

**[P.rarg.1]** *初始化命令行参数变量或常量*

```bash
local -n CPRx_ref=$1
local -n CPRy_ref=$2
```

**[P.rarg.2]** 命令行参数有效性检查

```bash
assert_files_r "${ifile_lst[@]}"
```

```bash
if [ -z "${mode2int[${mode}]}" ]; then
    echo "NotFound mode ${mode} in [${!mode2int[*]}]"
    return 1
fi
```

#### complex arguments

**[P.carg.0]** *声明（或初始化）命令行参数变量*

```bash
local escape=false
local -i r256=0
local -i g256=0
local -i b256=0
```

**[P.carg.1]** *while getopts*

```bash
while getopts ":er:g:b:" opt; do
    case ${opt} in
        e)
            escape=true ;;
        r)
            r256=${OPTARG} ;;&
        g)
            g256=${OPTARG} ;;&
        b)
            b256=${OPTARG} ;;&
        r|g|b)
            if [ "${OPTARG}" -lt 0 ] || [ "${OPTARG}" -ge 256 ]; then
                echo "RGB value ${OPTARG} NotIn [0,255]"
                return 1
            fi
            ;;
        \?)
            echo "Invalid Option: -${OPTARG}"
            return 1
            ;;
    esac
done; unset opt
shift $((OPTIND - 1)); unset OPTIND
```

#### raw app

**[P.rapp.0]** *定义 app 名*

```bash
declare -r app="app_name"
```

**[P.rapp.1]** *初始化应用运行时*

```bash
ShellKit_APPDIR="${BASH_SOURCE[0]%/*}"
# shellcheck source=../../ShellKit_init.sh
source "${ShellKit_ROOT:-"${ShellKit_APPDIR}/../.."}/ShellKit_init.sh" || exit 1
# shellcheck disable=SC2034
# SHELLKIT_LOG_VERB_ENABLE=true
# shellcheck disable=SC2034
# SHELLKIT_LOG_DEBUG_ENABLE=true
```

**[P.rapp.2]** 初始化全局常量

**[P.rapp.3]** 复杂命令行参数（complex arguments）解析

**[P.rapp.4]** 原始命令行参数（raw arguments）解析

**[P.rapp.5]** dump 命令行参数

```bash
skechod "[${app}] params:"
for (( i=0; i < ifile_num; i++ )); do
    skechod "[${app}]     ifile[$i] = ${ifile_lst[i]}"
done; unset i
skechod "[${app}]     ofile    = ${ofile}"
skechod
```

**[P.rapp.6]** *初始化全局 ret*

```bash
declare -i ret=${SHELLKIT_RET_SUCCESS}
```

**[P.rapp.7]** 声明（或初始化）全局变量

**[P.rapp.8]** 定义子函数

**[P.rapp.9]** *实现主程序*

**[P.rapp.10]** *exit*

```bash
exit ${ret}
```

#### app

**[P.app.0]** *定义 app 名*

**[P.app.1]** *初始化应用运行时*

**[P.app.2]** 初始化全局常量

**[P.app.3]** 声明（或初始化）全局变量

**[P.app.4]** 定义子函数

**[P.app.5]** *定义 main 函数*

**[P.app.6]** *调用 main 函数*

```bash
main "$@"
```

#### function

**[P.func.0]** 初始化局部常量

**[P.func.1]** 复杂命令行参数（complex arguments）解析

**[P.func.2]** 原始命令行参数（raw arguments）解析

**[P.func.3]** dump 命令行参数

**[P.func.4]** 初始化局部 ret

```bash
local -i ret=${SHELLKIT_RET_SUCCESS}
```

**[P.func.5]** 声明（或初始化）局部变量

**[P.func.6]** *实现函数主体*

**[P.func.7]** return

```bash
return ${ret}
```

#### TEST_DATAGEN

**[P.tgen.0]** *定义 tgen 名*

```bash
declare -r tgen="tgen(app_name)"
```

**[P.tgen.1]** *初始化应用运行时*

**[P.tgen.2]** *进入 TEST 目录*

```bash
assert_dirs_w "${BASH_SOURCE[0]%/*}/TEST/"
cd "${BASH_SOURCE[0]%/*}/TEST/" || exit 1
```

**[P.tgen.3]** *生成测试数据*

#### TEST_CASE

**[P.tcase.0]** *定义 tcase 名*

```bash
declare -r tcase="tcase(app_name)"
```

**[P.tcase.1]** *初始化应用运行时*

**[P.tcase.2]** *进入 TEST 目录*

**[P.tcase.3]** *实现测试用例*

#### PROVIDER

**[P.prov.0]** 初始化全局常量

**[P.prov.1]** 声明（或初始化）全局变量

**[P.prov.2]** *实现接口函数*

#### ASSERT_ENV

**[P.assertenv.0]** 命令实现

**[P.assertenv.1]** *命令注册*

```bash
declare -a ShellKit_ENV_lst=()

# shellcheck disable=SC2034
declare -a ShellKit_ENV_TPUT=(TPUT /usr/bin/tput -V)
ShellKit_ENV_lst+=(ShellKit_ENV_TPUT[@])
# shellcheck disable=SC2034
declare -a ShellKit_ENV_SLEEP=(SLEEP _sleep)
ShellKit_ENV_lst+=(ShellKit_ENV_SLEEP[@])
```

**[P.assertenv.2]** *命令断言*

```bash
# echo "AssertEnv following (${BASH_SOURCE[0]})"
for ShellKit_ENV in "${ShellKit_ENV_lst[@]}"; do
    ShellKit_assert_env "${ShellKit_ENV}"
done; unset ShellKit_ENV

unset ShellKit_ENV_lst
```

### 编码规则（Rule）

> 参考 [Google Style Guides - Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
