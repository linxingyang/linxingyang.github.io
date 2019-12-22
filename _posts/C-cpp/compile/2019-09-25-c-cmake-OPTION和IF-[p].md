---
layout: post
permalink: /:year/287f64ea1c5f4a53bc12cc9787cc32cf
title: 2019-09-25-c-cmake-OPTION和IF
categories: [c]
tags: [c,c++,cmake系列,cmake]
relative-tags: [cmake系列]
excerpt: c,c++,cmake,OPTION,IF
description: cmake-OPTION和IF
catalog: true
---

# CMake

CMAKE这几篇没有太深入研究它的原理，主要关注点在使用上。

接着看看Option和IF这两个能够做的一些事。

## OPTION 开关

定义一个开关量。语法：
```
option(<option_variable> 
  "help string describing option"
  [initial value])
```
* option_variable 变量名
* initial value 默认是OFF，可取值为ON 或者 OFF

## IF 控制语句

基本结构
```
IF(<expression>)
  ...
ENDIF()
```
IF(${variable}) - 如果variable被定义了并且被设置为真，如1, TRUE, ON, YES，那么进入执行体


在使用NOT来表示相反的
```
IF(NOT <expression>)
  ...
ENDIF()
```

if-else结构
```
IF(<expression1>)
  ...
ELSEIF(<expression2>)
  ...
ELSE()
  ...
ENDIF()
```

正则表达式匹配
```
IF(variable MATCHES <regular expression>)
  - 如果variable被定义了，并且根据正则能匹配上后面的表达式，那么进入执行体
```

字符串比较
```
IF("${variable}" STREQUAL "foobar")
  - 如果variable被定义了，并且二者的值是相同的，那么进入执行体。
  - 注意此处的 "${variable}"  使用双引号包含，这意味着${variable}将会被转换为字符串类型的
```

### if 和 option 的例子

我们可以配合使用IF和OPTION来选择性的使用一些库。

例如现在可以选择支持或者不支持WEBSOCKET功能，以及选择A/B功能中的其中一个

那在CMakeLists.txt中，我们可以这样
```
# 定一个变量 ENABLE_WEBSOCKET 为 ON
OPTION (ENABLE_WEBSOCKET
  "enable websocket"
  ON
)

# IF根据ENABLE_WEBSOCKET变量为ON为OFF判断走哪个分支
IF (ENABLE_WEBSOCKET)
  MESSAGE (STATUS " current is enable websocket ")
ELSE ()
  MESSAGE (STATUS " current is disable websocket ")
ENDIF ()


# 定义ENABLE_A和ENABLE_B
OPTION (ENABLE_A
  "enable A"
  ON
)
OPTION (ENABLE_B
  "enable B"
  OFF
)

# 根据ENABLE_A和ENABLE_B来确定走哪个分支
IF (ENABLE_A)
  MESSAGE (STATUS " current is enable A ")
ELSEIF (ENABLE_B)
  MESSAGE (STATUS " current is enable B ")
ELSE ()
  MESSAGE (STATUS " current is disable A & B ")
ENDIF ()
```

在执行cmake的时候
```
test10# cd build

test10/build# cmake ..
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
--  current is enable websocket 
--  current is enable A 
-- Configuring done
-- Generating done
```

可以看到，因为ENABLE_WEBSOCKET为ON，ENABLE_A也为ON，所以输出以下两句
```
--  current is enable websocket 
--  current is enable A 
```

#### option缓存问题

关于OPTION的缓存问题，即当前配置了ENABLE_WEBSOCKET为ON
```
OPTION (ENABLE_WEBSOCKET
  "enable websocket"
  ON
)
```

修改CMakeLists.txt为OFF
```
OPTION (ENABLE_WEBSOCKET
  "enable websocket"
  OFF
)
```

再编译依然显示的是enable，而不是disable
```
test10/build# cmake ..
--  path is : /tmp/c/2019-09-12-cmaketest/dir02/
--  current is enable websocket 
--  current is enable A 
-- Configuring done
-- Generating done
-- Build files have been written to: /tmp/c/2019-09-12-cmaketest/test10/build
```

这是因为我们虽然修改了CMakeLists.txt，但是CMakeCache.txt中的缓存没有改变，如下显示在缓存文件中它还是ON。
```
test10/build# cat CMakeCache.txt | grep ENABLE_WEBSOCKET -A 2 -B 2

//enable websocket
ENABLE_WEBSOCKET:BOOL=ON

//Value Computed by CMake
```

对于这种情况，暂时没有找到什么方法可以更新缓存的。暂时知道两个方法
* 手动修改CMakeCache.txt文件，将其修改为OFF
* 删除CMakeCache.txt文件，再次进行 cmake 则生成新的CmakeCache.txt中，该值为OFF

## Debug和Release模式

我们可以在配置文件中设置DEBUG：
```
SET(CMAKE_BUILD_TYPE "Debug”)
```

或者RELEASE模式：
```
SET(CMAKE_BUILD_TYPE "Release")
```

也可以在cmake命令后带一个参数指定Debug还是Release模式
```
cmake -DCMAKE_BUILD_TYPE="Debug" ..
```

### if 和 debug/release模式

此处使用IF以及STREQUAL来区分两种不同的编译方式。根据RELEASE和DEBUG两种不同的编译方式，将生成的可执行文件分别放在Debug和Release目录下。
```
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
PROJECT (HELLOWORLD)

# 如果是Debug模式，那么将可执行程序生成到build下的Debug目录中
if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug") 
  MESSAGE (STATUS "current is Debug mode")
  SET (EXECUTABLE_OUTPUT_PATH /tmp/c/2019-09-12-cmaketest/test11/build/Debug)
ENDIF () 

# 如果是Debug模式，那么将可执行程序生成到build下的Release目录中
if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
  MESSAGE (STATUS "current is Release mode")
  SET (EXECUTABLE_OUTPUT_PATH /tmp/c/2019-09-12-cmaketest/test11/build/Release)
ENDIF () 

ADD_EXECUTABLE (helloworld helloworld.cpp)
```

进行编译
```
test11# cd build/
```

以Debug模式编译，可以看到 `current is Debug mode`
```
test11/build# cmake -DCMAKE_BUILD_TYPE="Debug" ..
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
-- current is Debug mode
-- Configuring done
-- Generating done
-- Build files have been written to: /tmp/c/2019-09-12-cmaketest/test11/build
```

同时可执行程序helloworld被放到 Debug 目录下了
```
test11/build# make
Scanning dependencies of target helloworld
[ 50%] Building CXX object CMakeFiles/helloworld.dir/helloworld.cpp.o
[100%] Linking CXX executable Debug/helloworld
[100%] Built target helloworld
```

以Release模式编译：
```
test11/build# cmake -DCMAKE_BUILD_TYPE="Release" ..     
-- current is Release mode
-- Configuring done
-- Generating done
-- Build files have been written to: /tmp/c/2019-09-12-cmaketest/test11/build
```

可执行程序放到Release目录下了
```
test11/build# make
[ 50%] Building CXX object CMakeFiles/helloworld.dir/helloworld.cpp.o
[100%] Linking CXX executable Release/helloworld
[100%] Built target helloworld
```

当前build下的目录情况。
```
test11/build# tree -F -L 2 -I CMakeFiles
.
├── CMakeCache.txt
├── cmake_install.cmake
├── Debug/
│   └── helloworld*
├── Makefile
└── Release/
    └── helloworld*
```

## 交叉编译

写嵌入式程序的时候免不了要交叉编译，在CMakeLists.txt中可以如下配置。
```
# 编译目标为NUVOTON
OPTION (COMPILER_FOR_NUVOTON
  " compile chain for nuvoton "
  ON
)

# 编译目标为ARAGO
OPTION (COMPILER_FOR_ARAGO
  " compile chain for arago "
  OFF
)

# 根据对应的编译方式，指定C/C++编译器(CMAKE_C_COMPILER,CMAKE_CXX_COMPILER)、依赖库目录(LINK_DIRECTORIES)、头文件目录(INCLUDE_DIRECTORIES)。
IF (COMPILER_FOR_NUVOTON)
  MESSAGE (STATUS " use nuvoton compile chain ")
  SET(CMAKE_C_COMPILER "/opt/vbox/arm_linux_4.8/bin/arm-nuvoton-linux-uclibceabi-gcc")
  SET(CMAKE_CXX_COMPILER "/opt/vbox/arm_linux_4.8/bin/arm-nuvoton-linux-uclibceabi-g++")
  INCLUDE_DIRECTORIES(/opt/vbox/arm_linux_4.8/include)
  LINK_DIRECTORIES(/opt/vbox/arm_linux_4.8/lib)

ELSEIF (COMPILER_FOR_ARAGO)
  MESSAGE (STATUS " use arago compile chain ")
  SET(CMAKE_C_COMPILER "/opt/vbox/arago-linux-devkit/bin/arm-arago-linux-gnueabi-gcc")
  SET(CMAKE_CXX_COMPILER "/opt/vbox/arago-linux-devkit/bin/arm-arago-linux-gnueabi-g++")
  INCLUDE_DIRECTORIES(/opt/x86/24-xfrp/working/bin/libevent/arago/include)
  LINK_DIRECTORIES(/opt/x86/24-xfrp/working/bin/libevent/arago/lib)

ELSE ()
  MESSAGE (STATUS " use default compile chain ")

ENDIF ()
```

## 区分不同的操作系统

区分windows、unix系列、苹果系统。使用CMAKE内置的几个变量来区分：
```
IF (WIN32)
  MESSAGE(STATUS "current is windows.")
ELSEIF (APPLE)
  MESSAGE(STATUS "current is Apple systens.")
ELSEIF (UNIX)
  MESSAGE(STATUS "current is UNIX-like OS's.")
ENDIF ()
```

## 参考

* cmake practice
* [为何要使用cmake中文翻译参考](https://www.cnblogs.com/liu3yuan/p/6895419.html)
* [cmake变量](https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html#variables-that-change-behavior)
* [更多命令与脚本参考cmake官网](https://cmake.org/cmake/help/v3.16/manual/cmake-commands.7.html)