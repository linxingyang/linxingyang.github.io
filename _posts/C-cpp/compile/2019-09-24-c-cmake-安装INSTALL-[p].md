---
layout: post
permalink: /:year/271c83f318834c3eae3a63d39a4b9d91
title: 2019-09-24-c-cmake-安装INSTALL
categories: [c]
tags: [c,c++,cmake系列,cmake]
relative-tags: [cmake系列]
excerpt: c,c++,cmake,install
description: cmake-依赖库
catalog: true
author: 林兴洋
---


# CMAKE

上一次test07中，我们手动将math库复制到middleware之下，这次我们使用命令将另一个库安装到该目录下。

middleware所在路径
```
middleware# pwd
/tmp/c/2019-09-12-cmaketest/middleware
```

middleware中内容
```
middleware# tree
.
├── include
│   └── math
│       └── math.h
└── lib
    ├── libmath.a
    ├── libmath.so
    ├── libmath.so.1
    └── libmath.so.1.2
```

## 安装示例

当前位置
```
test08# pwd
/tmp/c/2019-09-12-cmaketest/test08
```

当前目录情况
```
test08# tree
.
├── build
├── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    ├── conversion.cpp
    └── conversion.h

2 directories, 4 files
```

老套路来看看各文件的内容

`test08/CMakeLists.txt`文件最后新增一句设置CMAKE_INSTALL_PREFIX（安装路径前缀）。

```cmake
test08# cat CMakeLists.txt 
# cmake最低版本
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
# 项目名
PROJECT (HELLOWORLD)
# 打印两句消息
MESSAGE (STATUS "this is BINARY dir " ${HELLOWORLD_BINARY_DIR})
MESSAGE (STATUS "this is SOURCE dir " ${HELLOWORLD_SOURCE_DIR})
# 添加子目录
ADD_SUBDIRECTORY (src)

# 安装路径前缀
SET (CMAKE_INSTALL_PREFIX /tmp/c/2019-09-12-cmaketest/middleware)
```

`test08/src/CMakeLists.txt`文件的内容，新增了INSTALL命令

```cmake
test08# cat src/CMakeLists.txt 
# 添加动态库与静态库
ADD_LIBRARY (conversion_static STATIC conversion.cpp)
ADD_LIBRARY (conversion SHARED conversion.cpp)
# 动态库版本
SET_TARGET_PROPERTIES(conversion PROPERTIES VERSION 1.2 SOVERSION 1)
SET_TARGET_PROPERTIES (conversion_static PROPERTIES OUTPUT_NAME "conversion")
# 库文件输出目录
SET (LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)

# 安装库文件
INSTALL (TARGETS conversion conversion_static
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
# 安装头文件
INSTALL (FILES conversion.h
  DESTINATION include/conversion
)
```

`test08/src/conversion.h`的内容，就是一个米转厘米的函数
```c++
test08# cat src/conversion.h 
#ifndef CONVERSION_H__20191103
#define CONVERSION_H__20191103

#include <stdio.h>
#include <stdlib.h>

#define METER_TO_CENTIMETER 100

double meterToCentimeter(double dMeter);

#endif // CONVERSION_H__20191103
```

`test08/src/conversion.cpp`的内容
```c++
test08# cat src/conversion.cpp 

#include "conversion.h"

double meterToCentimeter(double dMeter) {
  return dMeter * METER_TO_CENTIMETER;
}
```

编译
```
test08# cd build/

test08/build# cmake ..
-- The C compiler identification is GNU 5.4.0
-- The CXX compiler identification is GNU 5.4.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- this is BINARY dir /tmp/c/2019-09-12-cmaketest/test08/build
-- this is SOURCE dir /tmp/c/2019-09-12-cmaketest/test08
-- Configuring done
-- Generating done
-- Build files have been written to: /tmp/c/2019-09-12-cmaketest/test08/build

test08/build# make
Scanning dependencies of target conversion_static
[ 25%] Building CXX object src/CMakeFiles/conversion_static.dir/conversion.cpp.o
[ 50%] Linking CXX static library ../lib/libconversion.a
[ 50%] Built target conversion_static
Scanning dependencies of target conversion
[ 75%] Building CXX object src/CMakeFiles/conversion.dir/conversion.cpp.o
[100%] Linking CXX shared library ../lib/libconversion.so
[100%] Built target conversion
```

划重点，接下来是使用make install命令进行安装，可以看到库文件以及头文件都被安装到middleware文件夹下对应的位置
```
test08/build# make install
[ 50%] Built target conversion_static
[100%] Built target conversion
Install the project...
-- Install configuration: ""
-- Installing: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.so.1.2
-- Up-to-date: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.so.1
-- Up-to-date: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.so
-- Installing: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.a
-- Installing: /tmp/c/2019-09-12-cmaketest/middleware/include/conversion/conversion.h
```

到middleware文件夹中看看，可以看到确实库文件和头文件已经过来了
```
test08# cd ../middleware/

middleware# tree -F
.
├── include/
│   ├── conversion/
│   │   └── conversion.h
│   └── math/
│       └── math.h
└── lib/
    ├── libconversion.a
    ├── libconversion.so -> libconversion.so.1
    ├── libconversion.so.1 -> libconversion.so.1.2
    ├── libconversion.so.1.2
    ├── libmath.a
    ├── libmath.so*
    ├── libmath.so.1*
    └── libmath.so.1.2*

4 directories, 10 files
```

### make install 命令

根据配置文件中INSTALL命令指定的信息，将一些文件安装到指定位置。

### `test08/CMakeLists.txt`解析

其它都是之前讲过的，就最后一句的CMAKE_INSTALL_PREFIX
```cmake
test08# cat CMakeLists.txt 
# cmake最低版本
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
# 项目名
PROJECT (HELLOWORLD)
# 打印两句消息
MESSAGE (STATUS "this is BINARY dir " ${HELLOWORLD_BINARY_DIR})
MESSAGE (STATUS "this is SOURCE dir " ${HELLOWORLD_SOURCE_DIR})
# 添加子目录
ADD_SUBDIRECTORY (src)

# 安装路径前缀
SET (CMAKE_INSTALL_PREFIX /tmp/c/2019-09-12-cmaketest/middleware)
```

#### CMAKE_INSTALL_PREFIX 设置安装路径的前缀

```
# 安装路径前缀
SET (CMAKE_INSTALL_PREFIX /tmp/c/2019-09-12-cmaketest/middleware)
```

执行`make install`命令可以执行安装操作，如果不设置`CMAKE_INSTALL_PREFIX`，那么生成的头文件和可执行文件以及库文件将会放在`/usr/local/`下面，如果设置了`CMAKE_INSTALL_PREFIX`，那么生成的头文件和可执行文件以及库文件将会放在指定目录下面

注意这个命令需要在项目下的`test08/CMakeLists.txt`文件中配置，尝试配置在`test08/src/CMakeLists.txt`文件中配置无效。

### `test08/src/CMakeLists.txt`解析

该文件中新增了INSTALL命令
```cmake
test08# cat src/CMakeLists.txt 
# 添加动态库与静态库
ADD_LIBRARY (conversion_static STATIC conversion.cpp)
ADD_LIBRARY (conversion SHARED conversion.cpp)
# 动态库版本
SET_TARGET_PROPERTIES(conversion PROPERTIES VERSION 1.2 SOVERSION 1)
# 静态库改名
SET_TARGET_PROPERTIES (conversion_static PROPERTIES OUTPUT_NAME "conversion")
# 库文件输出目录
SET (LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)

# 安装库文件
INSTALL (TARGETS conversion conversion_static
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
# 安装头文件
INSTALL (FILES conversion.h
  DESTINATION include/conversion
)
```

#### INSTALL 安装

INSTALL 指令用于定义安装规则，安装的内容可以包括目标二进制、动态库、静态库以及 文件、目录、脚本等。

##### 安装目标二进制

参数中的 TARGETS 后面跟的就是我们通过 ADD_EXECUTABLE 或者 ADD_LIBRARY 定义的目标文件，可能是可执行二进制、动态库、静态库。

目标类型也就相对应的有三种，ARCHIVE 特指静态库，LIBRARY 特指动态库，RUNTIME 特指可执行目标二进制。

```cmake
INSTALL(TARGETS targets...
  [[ARCHIVE|LIBRARY|RUNTIME]
  [DESTINATION <dir>]
  [PERMISSIONS permissions...]
  [CONFIGURATIONS
  [Debug|Release|...]]
  [COMPONENT <component>]
  [OPTIONAL]
  ] [...])
```

DESTINATION 定义了安装的路径，如果路径以/开头，那么指的是绝对路径，这时候
CMAKE_INSTALL_PREFIX 其实就无效了。如果你希望使用 CMAKE_INSTALL_PREFIX 来 定义安装路径，就要写成相对路径，即不要以/开头，那么安装后的路径就是`${CMAKE_INSTALL_PREFIX}/<DESTINATION 定义的路径>`


举个简单的例子：
```cmake
INSTALL(TARGETS myrun mylib mystaticlib
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION libstatic)
```

上面的例子会将： 可执行二进制 myrun 安装到`${CMAKE_INSTALL_PREFIX}/bin` 目录 动态库libmylib 安装到`${CMAKE_INSTALL_PREFIX}/lib` 目录 静态库 libmystaticlib 安装到`${CMAKE_INSTALL_PREFIX}/libstatic` 目录

特别注意的是你不需要关心 TARGETS 具体生成的路径，只需要写上 TARGETS 名称就可以 了。

此处我们用到的命令就是将动态库和静态库安装到以CMAKE_INSTALL_PREFIX为前缀的lib目录下，即
`/tmp/c/2019-09-12-cmaketest/middleware/lib`

```
INSTALL (TARGETS conversion conversion_static
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
```

注意其中有一项CONFIGURATIONS，
CONFIGURATIONS指定了的Debug和Release，是根据当前是Debug还是Release模式来设置的.

```cmake
INSTALL (TARGETS conversion conversion_static
  LIBRARY DESTINATION lib CONFIGURATIONS Release # 只在release模式生效
  ARCHIVE DESTINATION lib CONFIGURATIONS Release # 只在release模式生效
)
```

如上配置，如果当前是Debug模式（默认Debug），那么静态库和动态库在make install都时候都不会安装。
```
test08/build# make install
[ 50%] Built target conversion_static
[100%] Built target conversion
Install the project...
-- Install configuration: ""
-- Up-to-date: /tmp/c/2019-09-12-cmaketest/middleware/include/conversion/conversion.h
```


如果设置了Release模式
```
SET (CMAKE_BUILD_TYPE "Release")
```
从打印的信息中可以看出安装了静态库和动态库
```
test08/build# make install
[ 50%] Built target conversion_static
[100%] Built target conversion
Install the project...
-- Install configuration: "Release"
-- Installing: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.so.1.2
-- Up-to-date: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.so.1
-- Up-to-date: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.so
-- Installing: /tmp/c/2019-09-12-cmaketest/middleware/lib/libconversion.a
-- Up-to-date: /tmp/c/2019-09-12-cmaketest/middleware/include/conversion/conversion.h
```

##### 安装普通文件（如文本，帮助文档之类）

```cmake
INSTALL(FILES files... DESTINATION <dir>
  [PERMISSIONS permissions...]
  [CONFIGURATIONS [Debug|Release|...]]
  [COMPONENT <component>]
  [RENAME <name>] [OPTIONAL])
```

可用于安装一般文件，并可以指定访问权限，文件名是此指令所在路径下的相对路径。如果 默认不定义权限 PERMISSIONS，安装后的权限为：OWNER_WRITE, OWNER_READ, GROUP_READ,和 WORLD_READ，即 644 权限。

我们使用这个来安装我们的头文件
```
INSTALL (FILES conversion.h
  DESTINATION include/conversion
)
```

#####  非目标文件的可执行程序安装(比如脚本)

```
INSTALL(PROGRAMS files... DESTINATION <dir>
[PERMISSIONS permissions...]
[CONFIGURATIONS [Debug|Release|...]]
[COMPONENT <component>]
[RENAME <name>] [OPTIONAL]) 
```
跟上面的 FILES 指令使用方法一样，唯一的不同是安装后权限为:OWNER_EXECUTE, GROUP_EXECUTE, 和 WORLD_EXECUTE，即 755 权限

##### 目录的安装

```
INSTALL(DIRECTORY dirs... DESTINATION <dir>
  [FILE_PERMISSIONS permissions...]
  [DIRECTORY_PERMISSIONS permissions...]
  [USE_SOURCE_PERMISSIONS]
  [CONFIGURATIONS [Debug|Release|...]]
  [COMPONENT <component>]
  [[PATTERN <pattern> | REGEX <regex>]
  [EXCLUDE] [PERMISSIONS permissions...]] [...])
```

这里主要介绍其中的 DIRECTORY、PATTERN 以及 PERMISSIONS 参数。
DIRECTORY 后面连接的是所在 Source 目录的相对路径，但务必注意：
abc 和 abc/有很大的区别。 如果目录名不以/结尾，那么这个目录将被安装为目标路径下的 abc，如果目录名以/结尾， 代表将这个目录中的内容安装到目标路径，但不包括这个目录本身。
PATTERN 用于使用正则表达式进行过滤，PERMISSIONS 用于指定 PATTERN 过滤后的文件 权限。

我们来看一个例子:
```
INSTALL(DIRECTORY icons scripts/ DESTINATION share/myproj
  PATTERN "CVS" EXCLUDE
  PATTERN "scripts/*"
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
  GROUP_EXECUTE GROUP_READ)
```
这条指令的执行结果是： 将 icons 目录安装到 <prefix>/share/myproj，将 scripts/中的内容安装到`<prefix>/share/myproj`不包含目录名为 CVS 的目录，对于 scripts/*文件指定权限为 OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ.


上面这些INSTALL内容都是比较基础的。

## 参考

* cmake practice
* [为何要使用cmake中文翻译参考](https://www.cnblogs.com/liu3yuan/p/6895419.html)
* [cmake变量](https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html#variables-that-change-behavior)
* [更多命令与脚本参考cmake官网](https://cmake.org/cmake/help/v3.16/manual/cmake-commands.7.html)


