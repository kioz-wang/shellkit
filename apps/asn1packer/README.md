# asn1packer

基于 `asn1` 编解码的数据打包/解包。

## pack

```
Usage:
  asn1pack {ifile0} [{ifile1} ...] {ofile}
```

把所有输入文件 `{ifilen}` 按先后顺序打包进输出文件 `{ofile}`，可以直接使用如下命令解析输出文件：

```shell
$ openssl asn1parse -infrom der -in {ofile}
```

输出中丢弃了输入的文件系统路径，存放了输入的索引（从0计数，表示先后顺序）、大小、摘要（当前为 `sha256`）和对原始数据的 `base64` 编码。

打包过程中会产生动态资源文件 `${ShellKit_TEMP}/config.asn1`。

## unpack

```
Usage:
  asn1unpack {ifile} [{odir} [{idx}]]
```

把输入文件 `{ifile}` 解包到输出目录 `{odir}` 下，如果没有指定输出目录，则解包到当前目录下。如果指定了索引 `{idx}`，则只解包索引的数据，否则解包所有。

每个数据被解包后，会得到两个文件，分别是：

- `ifile{idx}`：原始数据
- `ifile{idx}.hash`：原始数据的摘要

不管是否指定索引，都会在输出目录下生成一个 `ifile_num` 文件，内容是一个整数，表示输入文件中含数据的多少。

解包过程中会产生动态资源文件 `${ShellKit_TEMP}/parse.asn1`。

## tgen

随机生成 10 个小于 0xffffff 大小的数据文件，其中每个文件的大小也是随机的。每个文件按生成顺序，命名为 `bin$i`。

按同样的规则，生成一个名为 `bin name include spaces` 的文件。这是为了测试 `ShellKit` 对文件名包含空格的文件路径的处理。

## tcase

### case0

打包 bin0, bin1, bin2, "bin name include spaces" 共 4 个文件，然后解出索引为 2 的文件，即 bin2。

### case1

打包 bin7, bin6 共 2 个文件，然后全部解出。
