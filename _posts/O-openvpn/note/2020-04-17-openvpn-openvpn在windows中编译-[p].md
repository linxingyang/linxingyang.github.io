---
layout: post
permalink: /:year/38cf615d41584865ab54999a75656dbd/index
title: 2020-04-17-openvpn-openvpn在windows中编译
categories: [openvpn]
tags: [openvpn,编译,windows]
relative-tags: [openvpn]
excerpt: openvpn,windows,编译
description: openvpn在windows中编译
catalog: true
---

# openvpn

## 1、准备

### 编译环境

#### Perl

下载安装[Perl](http://strawberryperl.com/) ，用于编译 openssl。

#### nasm

下载安装[nasm](https://www.nasm.us/) 用于编译openss。

##### 添加nasm环境变量

创建系统环境变量NASM_HOME，值为name的目录，如当前nasm安装路径`D:\install_software\nasm`。

```
NASM_HOME
D:\install_software\nasm
```

然后修改path环境变量，在最后添加

```
;%NASM_HOME%\VC\bin\
```

输入如下命令输出nasm帮助信息说明设置正确

```
nasm -h
```

#### VS2015 or VS2013

VS安装不赘述。

##### 添加VS环境变量

新建系统环境变量VS_HOME，值为VS2015的目录，如当前VS2015所在目录`D:\install_software\vs2015`。

```
VS_HOME
D:\install_software\vs2015
```

然后修改path环境变量，在最后添加
```
;%VS_HOME%\VC\bin\;%VS_HOME%\Common7\Tools
```

输入nmake到如下提示说明设置正确
```bat
>nmake

Microsoft (R) 程序维护实用工具 14.00.24210.0 版
版权所有 (C) Microsoft Corporation。  保留所有权利。

NMAKE : fatal error U1064: 未找到 MAKEFILE 并且未指定目标
Stop.
```



### 下载源码包

* [openssl](http://www.openssl.org/source/openssl-1.1.1f.tar.gz)
* [lzo-2.10](http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz)
* [pkcs11-helper-1.22](https://github.com/OpenSC/pkcs11-helper/releases/download/pkcs11-helper-1.22/pkcs11-helper-1.22.tar.bz2)
* [tap-windows6](https://github.com/OpenVPN/tap-windows6)

* [openvpn](https://github.com/OpenVPN/openvpn/archive/master.tar.gz) 注意下载openvpn源码直接通过这个链接下载，下载release包的里面的vs项目解决方案是VS2010的，通过这个链接下载是VS2015的。

### middleware统一存放目录

为了统一，这里使用U:\applications\2019-11-04-openvpn\middleware做为所有生成的库、头文件存放目录，目录结构（后续middleware目录即指`U:\applications\2019-11-04-openvpn\middleware\`）：

```
U:\applications\2019-11-04-openvpn\middleware\
	x86-vs2015
        bin\
        lib\
		include\
	x64-vs2015\
        bin\
        lib\
		include\
```



## 2、openssl编译

当前openssl路径`U:\applications\2019-11-04-openvpn\code\openssl`

### 32位


```bat
// 进入VS目录
pushd D:\install_software\vs2015\VC\bin

// 32为环境脚本
vcvars32.bat

// 进入openssl源码目录
pushd U:\applications\2019-11-04-openvpn\code\openssl

// 创建中间文件输出目录
mkdir build\x86-vs2015
cd build\x86-vs2015

// 配置
// 指定Configure路径 ..\..\Configure
// --prefix --openssldir 指定安装路径
perl ..\..\Configure VC-WIN32 --prefix="U:\applications\2019-11-04-openvpn\middleware\x86-vs2015" --openssldir="U:\applications\2019-11-04-openvpn\middleware\x86-vs2015"

// 编译和安装
nmake
nmake install

// 完成之后在middleware\x86-vs2015 目录下生成 bin/ lib/ include/ html/ 等等。
```



### 64位

```bat
// 进入VS amd64目录
pushd D:\install_software\vs2015\VC\bin\amd64\

// 64位环境变量
vcvars64.bat

// 进入openssl根目录
pushd U:\applications\2019-11-04-openvpn\code\openssl

// 创建中间文件输出目录
mkdir build\x64-vs2015
cd build\x64-vs2015

// 配置
perl ..\..\Configure VC-WIN64A --prefix="U:\applications\2019-11-04-openvpn\middleware\x64-vs2015" --openssldir="U:\applications\2019-11-04-openvpn\middleware\x64-vs2015"

// 编译和安装
nmake 
nmake install 

// 完成之后在middleware\x64-vs2015 目录下会生成 bin/ lib/ include/ html/ 等等。
```



### 产生libeay32.lib和ssleay32.lib

直接复制上面32位或64位生成的两个lib，如我的操作，在 `middleware\x86-vs2015\lib`和`middleware\x64-vs2015\lib`目录中：

```
libcrypto.lib ==> libeay32.lib //  复制一份libcrypto.lib改名为libeay32.lib
libssl.lib ==> ssleay32.lib    // 复制一份libssl.lib改名为ssleay32.lib
```



### 出现的问题

#### 不存在vcvar32.bat或vcvar64.bat或vcvarall.bat

这个是因为visual studio c++ 没有装好，在VS2015中去创建一个C++项目，会提示让你下载相关的一些库等等，下载即可。

#### 模块计算机类型 x64和目标计算机类型x86冲突

crypto\aes\aesni-mb-x86_64.obj : fatal error LNK1112: 模块计算机类型“x64”与目标计算机类型“X86”冲突。

编译64位的时候需要先执行：
```
D:\install_software\vs2015\VC\bin\amd64\vcvars64.bat
```

#### e_os.h(13): 'limits.h': No such file or directory

```
e_os.h(13): 'limits.h': No such file or directory
```

这个问题可能是这段脚本没有执行：

```
D:\install_software\vs2015\VC\bin\amd64\vcvars64.bat
```

如果还不行就执行这段：

```
D:\install_software\vs2015\VC\vcvarsall.bat
```

然后再执行对应编译版本的脚本：
```
D:\install_software\vs2015\VC\bin\amd64\vcvars64.bat
```

#### 执行命令ms\do_nasm提示不是内部命令

因为项目依赖的库中有OpenSSL，就开始了自己编译OpenSSL，按照网上的资料总出现”ms\do_nasm不是内部或外部命令，也不是可运行的程序或批处理”的错误.

新版本VC自带的构建程序已经没有”ms\do”系列的程序了。




## 3、lzo编译

当前lzo路径`U:\applications\2019-11-04-openvpn\code\lzo-2.10`
### 32位

```bat
// 进入该目录
pushd D:\install_software\vs2015\VC\bin

// 32位环境变量
vcvars32.bat

// 进入lzo源代码目录
pushd U:\applications\2019-11-04-openvpn\code\lzo-2.10

// 32位
// 这里中间文件默认是生成在源码目录下，后面可以清除这些中间文件
// 所以为了简单就不修改vc_dll.bat脚本，直接生成。
B\win32\vc_dll.bat

// 完成之后，复制dll,lib,include到 middleware目录下
xcopy *.dll U:\applications\2019-11-04-openvpn\middleware\x86-vs2015\bin
xcopy *.lib U:\applications\2019-11-04-openvpn\middleware\x86-vs2015\lib
xcopy include\lzo U:\applications\2019-11-04-openvpn\middleware\x86-vs2015\include\lzo\

// 清除中间文件
B\clean.bat
```


### 64位

```bat
// 进入该目录
pushd D:\install_software\vs2015\VC\bin\amd64

// 64位环境变量
vcvars64.bat

// 进入lzo源代码目录
pushd U:\applications\2019-11-04-openvpn\code\lzo-2.10

// 64位
B\win64\vc_dll.bat

// 完成之后，复制dll,lib,include到 middleware目录下
xcopy *.dll U:\applications\2019-11-04-openvpn\middleware\x64-vs2015\bin
xcopy *.lib U:\applications\2019-11-04-openvpn\middleware\x64-vs2015\lib
xcopy include\lzo U:\applications\2019-11-04-openvpn\middleware\x64-vs2015\include\lzo\

// 清除中间文件
B\clean.bat
```



## 4、pkcs11-helper-1.22编译

当前pcks11-helper路径`U:\applications\2019-11-04-openvpn\code\pkcs11-helper-1.22`

### 32位

```bat
// 进入该目录
pushd D:\install_software\vs2015\VC\bin

// 32位环境变量
vcvars32.bat

// 进入pkcs的lib目录下
pushd U:\applications\2019-11-04-openvpn\code\pkcs11-helper-1.22\lib

// 编译，其中OPENSSL_HOME指向了openssl库的目录，其下包含lib\libeay32.lib
nmake -f Makefile.w32-vc OPENSSL=1 OPENSSL_HOME="U:\applications\2019-11-04-openvpn\middleware\x86-vs2015" all

// 复制生成的东西
xcopy *.dll U:\applications\2019-11-04-openvpn\middleware\x86-vs2015\bin
xcopy *.lib U:\applications\2019-11-04-openvpn\middleware\x86-vs2015\lib
xcopy ..\include\pkcs11-helper-1.0\*.h U:\applications\2019-11-04-openvpn\middleware\x86-vs2015\include\pkcs11-helper-1.0\

// 清除中间文件
nmake -f Makefile.w32-vc clean
```

### 64位

```bat
// 进入该目录
pushd D:\install_software\vs2015\VC\bin\amd64

// 64位环境变量
vcvars64.bat

// 进入pkcs的lib目录下
pushd U:\applications\2019-11-04-openvpn\code\pkcs11-helper-1.22\lib

// 编译，其中OPENSSL_HOME指向了openssl库的目录，其下包含lib\libeay32.lib
// 指定64位的OPENSSL则生成64位的pcks，指定32位则生成32位的pcks
nmake -f Makefile.w32-vc OPENSSL=1 OPENSSL_HOME="U:\applications\2019-11-04-openvpn\middleware\x64-vs2015" all

// 复制生成的东西
xcopy *.dll U:\applications\2019-11-04-openvpn\middleware\x64-vs2015\bin
xcopy *.lib U:\applications\2019-11-04-openvpn\middleware\x64-vs2015\lib
xcopy ..\include\pkcs11-helper-1.0\*.h U:\applications\2019-11-04-openvpn\middleware\x64-vs2015\include\pkcs11-helper-1.0\

// 清除中间文件
nmake -f Makefile.w32-vc clean
```



## 5、tap-windows6

当前tap-windows6路径`U:\applications\2019-11-04-openvpn\code\tap-windows6-master\`

这个解压后无需编译，把头文件tap-windows.h复制到

```bat
// 进入src目录
pushd U:\applications\2019-11-04-openvpn\code\tap-windows6-master\src

// 32位
xcopy tap-windows.h U:\applications\2019-11-04-openvpn\middleware\x86-vs2013\include\
// 64位
xcopy tap-windows.h U:\applications\2019-11-04-openvpn\middleware\x64-vs2013\include\
```



## 6、此时x86-vs2015目录结构 

删了一些不重要的目录后如下：

```shell
/middleware# tree x86-vs2015 -L 2 -F
x86-vs2015
├── bin/
│   ├── c_rehash.pl
│   ├── libcrypto-1_1.dll
│   ├── libcrypto-1_1.pdb
│   ├── libpkcs11-helper-1.dll
│   ├── libssl-1_1.dll
│   ├── libssl-1_1.pdb
│   ├── lzo2.dll
│   ├── openssl.exe
│   └── openssl.pdb
├── include/
│   ├── lzo/
│   ├── openssl/
│   ├── pkcs11-helper-1.0/
│   └── tap-windows.h
├── lib/
│   ├── engines-1_1/
│   ├── libcrypto.lib
│   ├── libeay32.lib
│   ├── libssl.lib
│   ├── lzo2.lib
│   ├── pkcs11-helper.dll.lib
│   ├── pkcs11-helper.lib
│   └── ssleay32.lib
```



## 7、openvpn编译

当前OpenVPN源码路径`U:\applications\2019-11-04-openvpn\code\openvpn-master-2015`

按照OpenVPN建议的，要使用VS2019配合windows SDK 10.0 版本进行编译。但是目前使用的电脑装的是 VS2015，且windows SDK是 8.1版本，需要做一些处理。

### vs2015 & windows SDK8.1

#### 修改openvpn.sln文件

由于当前的openvpn.sln刚好是VS2015的项目，所以openvpn.sln文件无需处理。

#### 修改.vcxproj文件

打开源码目录下所有.vcxproj文件。（在当前的目录下搜索一下就可以了，总共有这6个文件）。

```
openvpn.vcxproj
openvpnmsica.vcxproj
openvpnserv.vcxproj
compat.vcxproj
tapctl.vcxproj
msvc-generate.vcxproj
```

##### 处理1：修改SDK版本

把每个文件的

```
<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
```

改成

```
<WindowsTargetPlatformVersion>8.1</WindowsTargetPlatformVersion>
```

##### 处理2：修改平台版本

当前使用的是140，不是142，将

```
<PlatformToolset>v142</PlatformToolset>
```

改成

```
<PlatformToolset>v140</PlatformToolset>
```

**注：如果不知道你自己的版本，就用你当前的VS创建一个空项目，然后打开该项目的vcxproj，里面可以看到。**

### 指定头文件目录/库目录

每次编译前，根据是要编译的目标是32位还是64位指定头文件目录/库目录。打开`src\compat\PropertySheet.props`文件

#### 32位

```
// 修改OPENVPN_DEPROOT一行，编译32位指定32位的库
// 这个目录下的include和lib在编译的时候会被用的。
<OPENVPN_DEPROOT>U:\applications\2019-11-04-openvpn\middleware\x86-vs2015</OPENVPN_DEPROOT>
```

#### 64位

```
// 修改OPENVPN_DEPROOT一行，编译64位指定64位的库
<OPENVPN_DEPROOT>U:\applications\2019-11-04-openvpn\middleware\x64-vs2015</OPENVPN_DEPROOT>
```

### 编译

#### 使用命令行编译

##### 32位-release

```bat
// 进入目录
pushd D:\install_software\vs2015\VC\bin

// 设置32位环境变量
vcvars32.bat

// 进入源码目录
pushd U:\applications\2019-11-04-openvpn\code\openvpn-master-2015

// 开始构建，要等一会会。
msbuild openvpn.sln /p:Platform=Win32 /p:Configuration=Release 

msbuild openvpn.sln /p:Platform=Win32 /p:Configuration=Release /F 65535
```

构建结束后，会在如下目录下生成openvpn程序及相关程序。

```
U:\applications\2019-11-04-openvpn\code\openvpn-master-2015\Win32-Output\Release
```

此时不能直接运行openvpn.exe程序，会提示缺少dll，将`U:\applications\2019-11-04-openvpn\middleware\x86-vs2015\bin`中的这四个dll拷贝到这个目录

```
libcrypto-1_1.dll
libssl-1_1.dll
lzo2.dll
libpkcs11-helper-1.dll
```

现在命令可以正确运行了

```
openvpn --help
```



##### 64位-release

```bat
// 进入目录
pushd D:\install_software\vs2015\VC\bin\amd64

// 设置64位环境变量
vcvars64.bat

// 进入源码目录
pushd U:\applications\2019-11-04-openvpn\code\openvpn-master-2015

// 开始构建，要等一会会。
msbuild openvpn.sln /p:Platform=x64 /p:Configuration=Release 
```

构建结束后，会在如下目录下生成openvpn程序及相关程序。

```
U:\applications\2019-11-04-openvpn\code\openvpn-master-2015\x64-Output\Release
```

同上将`U:\applications\2019-11-04-openvpn\middleware\x64-vs2015\bin`中的四个dll拷贝一份到上面这个目录

```
libcrypto-1_1-x64.dll
libssl-1_1-x64.dll
lzo2.dll
libpkcs11-helper-1.dll
```

现在命令可以正确运行了

```
openvpn --help
```



#### 用VS2015打开项目进行编译

直接用VS2015打开项目进行编译，VS知道项目的依赖所以知道编译顺序，直接在解决方案上右键生成解决方案就可以了。具体过程应该都懂，此处省略过程。

再啰嗦一句，如果要运行也是要拷贝这4个dll到生成openvpn.exe的目录下。

```
libcrypto-1_1-x64.dll
libssl-1_1-x64.dll
lzo2.dll
libpkcs11-helper-1.dll
```



### 在VS2013编译

在VS2013中编译，大致流程和VS2015相同，下面就列一些不同的修改点。

**注：OpenVPN依赖的OpenSSL，lzo等等这几个lib库，因为VS2013和VS2015不能共用，所以需要单独为2013再编一次。**

#### 修改openvpn.sln文件

打开openvpn.sln，把前面的这几个改成当前的vs2013版本的信息。这个信息可以直接从别的VS2013创建的项目中拷过来。

```
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 2013
VisualStudioVersion = 12.0.30501.0
MinimumVisualStudioVersion = 10.0.40219.1
```

#### 修改.vcxproj文件

打开源码目录下所有.vcxproj文件。（在当前的目录下搜索一下就可以了，总共有这6个文件）。

```
openvpn.vcxproj
openvpnmsica.vcxproj
openvpnserv.vcxproj
compat.vcxproj
tapctl.vcxproj
msvc-generate.vcxproj
```

##### 处理1：修改SDK版本

把每个文件的

```
<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
```

改成

```
<WindowsTargetPlatformVersion>8.1</WindowsTargetPlatformVersion>
```

##### 处理2：修改平台版本

当前使用的是v120_xp，不是142，将

```
<PlatformToolset>v142</PlatformToolset>
改成
<PlatformToolset>v120_xp</PlatformToolset>
```

#### 修改openvpn.vcxproj

##### 修改1，添加头文件目录

由于缺少versionhelper.h等头文件，找到所有的AdditionalIncludeDirectories，加入

```
C:\Program Files (x86)\Windows Kits\8.1\Include\shared;C:\Program Files (x86)\Windows Kits\8.1\Include\um;
```

结果如下

```
<AdditionalIncludeDirectories>C:\Program Files (x86)\Windows Kits\8.1\Include\shared;C:\Program Files (x86)\Windows Kits\8.1\Include\um;..\compat;$(TAP_WINDOWS_HOME)/include;$(OPENSSL_HOME)/include;$(LZO_HOME)/include;$(PKCS11H_HOME)/include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
```

##### 修改2，删除`legacy_stdio_definitions.lib`这个依赖库

找到所有的AdditionalDependencies，删除`legacy_stdio_definitions.lib`这个依赖库。原因看另一篇笔记。

```
<AdditionalDependencies>Ncrypt.lib;libssl.lib;libcrypto.lib;lzo2.lib;pkcs11-helper.dll.lib;gdi32.lib;ws2_32.lib;wininet.lib;crypt32.lib;iphlpapi.lib;winmm.lib;Fwpuclnt.lib;Rpcrt4.lib;setupapi.lib;%(AdditionalDependencies)</AdditionalDependencies>
```



#### 修改openvpnserv.vcxproj

##### 修改1，添加头文件目录

找到所有的AdditionalIncludeDirectories，加入

```
C:\Program Files (x86)\Windows Kits\8.1\Include\shared;C:\Program Files (x86)\Windows Kits\8.1\Include\um;
```

##### 修改2，添加库目录：缺少ntdll.lib

32位

```
C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x86;
```

64位

```
C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x64;
```

##### 修改3，删除所有`legacy_stdio_definitions.lib`依赖库

##### 修改4，多字节和宽字符的问题

```
<CharacterSet>Unicode</CharacterSet>
```

改为

```
<CharacterSet>MultiByte</CharacterSet>
```



最后如下：（删除部分其他信息）

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="12.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <!-- 修改4 -->
    <CharacterSet>MultiByte</CharacterSet>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <PlatformToolset>v120_xp</PlatformToolset>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <!-- 修改4 -->
    <CharacterSet>MultiByte</CharacterSet>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <PlatformToolset>v120_xp</PlatformToolset>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <!-- 修改4 -->
    <CharacterSet>MultiByte</CharacterSet>
    <PlatformToolset>v120_xp</PlatformToolset>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <!-- 修改4 -->
    <CharacterSet>MultiByte</CharacterSet>
    <PlatformToolset>v120_xp</PlatformToolset>
  </PropertyGroup>

  <PropertyGroup Label="UserMacros" />
  <PropertyGroup>
    <_ProjectFileVersion>10.0.30319.1</_ProjectFileVersion>
  </PropertyGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <ClCompile>
      <!-- 修改1 -->
      <AdditionalIncludeDirectories>..\openvpn;..\compat;C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <PreprocessorDefinitions>_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
    </ClCompile>
    <ResourceCompile />
    <Link>
      <!-- 修改3 -->
      <AdditionalDependencies>Userenv.lib;Iphlpapi.lib;ntdll.lib;Fwpuclnt.lib;Netapi32.lib;Shlwapi.lib;%(AdditionalDependencies)</AdditionalDependencies>
      <SubSystem>Console</SubSystem>
      <!-- 修改2 -->
      <AdditionalLibraryDirectories>C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x86;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <ClCompile>
      <!-- 修改1 -->
      <AdditionalIncludeDirectories>..\openvpn;..\compat;C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <PreprocessorDefinitions>_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
    </ClCompile>
    <ResourceCompile />
    <Link>
      <!-- 修改3 -->
      <AdditionalDependencies>Userenv.lib;Iphlpapi.lib;ntdll.lib;Fwpuclnt.lib;Netapi32.lib;Shlwapi.lib;%(AdditionalDependencies)</AdditionalDependencies>
      <SubSystem>Console</SubSystem>
      <!-- 修改2 -->
      <AdditionalLibraryDirectories>C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x64;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
    </Link>
  </ItemDefinitionGroup>
  
  <!-- 另外两个修改类似 -->
  
</Project>
```



#### 修改openvpnmsica.vcxproj

##### 修改1，添加两个头文件目录

```
C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;
```

如下

```xml
<Project>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <ClCompile>
      <AdditionalIncludeDirectories>C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <AdditionalLibraryDirectories>%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <ClCompile>
      <AdditionalIncludeDirectories>C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <ClCompile>
      <AdditionalIncludeDirectories>C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <ClCompile>
      <AdditionalIncludeDirectories>C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
  </ItemDefinitionGroup>
</Project>
```



#### 修改src\tapctl\error.h

莫名就报错这个错，VS2015编都不报错。打开`src\tapctl\error.h`，在使用inline的地方之前写这几句。

```
#ifdef HAVE_CONFIG_H
#include <config.h>
#elif defined(_MSC_VER)
#include <config-msvc.h> /* 解决报错 ： 在“inline”之后应输入“(” */
#endif
```



### 出现的问题

#### 方法过长  C1026: 分析器堆栈溢出，程序太复杂

这个是因为option.c中的add_option方法太长了，5000行到8600行，大约3600行，丧心病狂。

找了半天也没找到如何去增大编译堆栈的大小的方法，最后通过修改方法，将其拆分成两个方法解决这个问题。

```
static void
add_option(struct options *options,
           char *p[],
           const char *file,
           int line,
           const int level,
           const int msglevel,
           const unsigned int permission_mask,
           unsigned int *option_types_found,
           struct env_set *es)
```



#### 32位Release编译的时候报错无法解析的外部符号

```
2>tun.obj : error LNK2019: 无法解析的外部符号 __imp__SetupDiGetDeviceInstanceIdA@20，该符号在函数 _get_device_instance_id_interface 中被引用
2>tun.obj : error LNK2019: 无法解析的外部符号 __imp__SetupDiEnumDeviceInfo@12，该符号在函数 _get_device_instance_id_interface 中被引用
2>tun.obj : error LNK2019: 无法解析的外部符号 __imp__SetupDiDestroyDeviceInfoList@4，该符号在函数 _get_device_instance_id_interface 中被引用
2>tun.obj : error LNK2019: 无法解析的外部符号 __imp__SetupDiGetClassDevsExA@28，该符号在函数 _get_device_instance_id_interface 中被引用
2>tun.obj : error LNK2019: 无法解析的外部符号 __imp__SetupDiOpenDevRegKey@24，该符号在函数 _get_device_instance_id_interface 中被引用
2>tun.obj : error LNK2019: 无法解析的外部符号 __imp__CM_Get_Device_Interface_ListA@20，该符号在函数 _get_device_instance_id_interface 中被引用
2>tun.obj : error LNK2019: 无法解析的外部符号 __imp__CM_Get_Device_Interface_List_SizeA@16，该符号在函数 _get_device_instance_id_interface 中被引用
```



主要是tun.c中几个方法，如`CM_Get_Device_Interface_List_Size`提示无法解析的外部符号。打开tun.c，找一个地方定义win32的地方，加入这一句

```
#ifdef _WIN32
#include "openvpn-msg.h"
// 加这一句
#pragma comment(lib, "setupapi.lib")
#endif
```

再编译即可，参考 [解决来源](http://bbs.bccn.net/thread-464199-1-1.html)



#### 串联不匹配的字符串

```
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\openvpnserv\automatic.c(47): error C2308: 串联不匹配的字符串
2>          连接 宽“OpenVPN”与 窄“ServiceLegacy”
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\openvpnserv\automatic.c(48): error C2308: 串联不匹配的字符串
2>          连接 宽“OpenVPN”与 窄“ Legacy Service”
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\openvpnserv\automatic.c(49): error C2308: 串联不匹配的字符串
2>          连接 宽“tap0901”与 窄“”
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\openvpnserv\automatic.c(231): error C2308: 串联不匹配的字符串
2>          连接 宽“openvpn”与 窄“%s_exit_1”
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\openvpnserv\automatic.c(321): error C2308: 串联不匹配的字符串
2>          连接 宽“openvpn --service "”与 窄“openvpn”
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\openvpnserv\automatic.c(329): error C2308: 串联不匹配的字符串
2>          连接 宽“InitializeSecurityDescriptor start_”与 窄“openvpn”
```

右键属性->配置属性->常规->字符集->修改为 使用多语言字符集



#### 语法错误:在“inline”之后应输入“(”

```
2>  error.c
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\tapctl\error.h(85): error C2054: 在“inline”之后应输入“(”
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\tapctl\error.h(86): error C2085: “check_debug_level”: 不在形参表中
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\tapctl\error.h(86): error C2143: 语法错误 : 缺少“;”(在“{”的前面)
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\tapctl\error.h(92): error C2054: 在“inline”之后应输入“(”
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\tapctl\error.h(93): error C2085: “msg_test”: 不在形参表中
2>u:\applications\2019-11-04-openvpn\code\openvpn-master-2013-pure\src\tapctl\error.h(93): error C2143: 语法错误 : 缺少“;”(在“{”的前面)
2>  tap.c
```

打开`src\tapctl\error.h`，在使用inline的地方之前写这几句。（直接从其它头文件copy过来的）

```
#ifdef HAVE_CONFIG_H
#include <config.h>
#elif defined(_MSC_VER)
#include <config-msvc.h>
#endif
```



#### error C2440: “初始化”: 无法从“const in6_addr”转换为“UCHAR”	openvpn\route.c	3069

在VS2013编译的时候提示这个问题，进行如下修改：

```c
static bool
do_route_ipv6_service(const bool add, const struct route_ipv6 *r, const struct tuntap *tt)
{
    bool status;
    route_message_t msg = {
        .header = {
            (add ? msg_add_route : msg_del_route),
            sizeof(route_message_t),
            0
        },
        .family = AF_INET6,
		// .prefix.ipv6 = r->network,
        .prefix_len = r->netbits,
		// .gateway.ipv6 = r->gateway,
        .iface = { .index = tt->adapter_index, .name = "" },
        .metric = ( (r->flags & RT_METRIC_DEFINED) ? r->metric : -1)
    };
    /* 移到此处可编译通过 */
	msg.prefix.ipv6 = r->network;
	msg.gateway.ipv6 = r->gateway;

    /* 省略 */
 
    return status;
}
```



## 参考


* [openssl在windows中编译](https://blog.csdn.net/l1258914199/article/details/8209518)
* [VC不再带有ms\do系列程序](https://blog.csdn.net/bxsec/article/details/74006848)


