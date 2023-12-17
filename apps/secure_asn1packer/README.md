# secure_asn1packer

保证了机密性，提供了认证能力的 `asn1packer`：`sasn1packer`。

## secure pack

```
Usage:
  sasn1pack {ifile0} [{ifile1} ...] {ofile}
```

加密所有输入文件 `{ifilen}`，调用 [asn1pack](../asn1packer/ShellKit_asn1pack.sh) 按先后顺序打包，然后对输出签名，并以一定的结构合并签名和输出，得到 `${ofile}`。

不考虑子应用，会在输入输出文件所在目录下产生动态资源文件：

- `${ofile}.raw`
- `${ofile}.sign`
- `${ifilen}.y`

## secure unpack

```
Usage:
  sasn1unpack {ifile} [{odir}]
```

分离输入文件 `{ifile}` 得到 [asn1unpack](../asn1packer/ShellKit_asn1unpack.sh) 可以处理的输入，和签名。首先验证签名，通过后，调用 `asn1unpack` 解包得到所有加密数据，最后解密这些数据。

不考虑子应用，会在输入输出文件所在目录下产生动态资源文件：

- `${ifile}.raw`
- `${ifile}.sign`
- `${odir}/ifile${i}.y`

## PROVIDER

依赖全局静态资源：

- rsa2048.key
- rsa2048.puk

实现了如下接口：

- secure_asn1packer_encrypt
- secure_asn1packer_decrypt
- secure_asn1packer_sign
- secure_asn1packer_verify
- secure_asn1packer_join_signature
- secure_asn1packer_split_signature

其中，sign 和 verify 基于算法 `rsa2048`, `sha512`；encrypt 和 decrypt 基于 `aes-356-cbc`；signature 的 join 和 split 决定了签名和被签名数据的组织结构。

## tgen

随机生成 3 个小于 0xffffff 大小的数据文件，其中每个文件的大小也是随机的。每个文件按生成顺序，命名为 `bin$i`。

按同样的规则，生成一个名为 `bin name include spaces` 的文件。这是为了测试应用对文件名包含空格的文件路径的处理。

## tcase

### case0

打包 bin0, bin1, bin2, "bin name include spaces" 共 4 个文件，然后解出所有文件。
