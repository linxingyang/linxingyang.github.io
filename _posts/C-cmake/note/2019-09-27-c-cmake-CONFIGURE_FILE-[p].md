---
layout: post
permalink: /:year/047a454bb32d465f984b4c4b5ffe569a
title: 2019-09-27-c-cmake-CONFIGURE_FILE
categories: [c]
tags: [c,c++,cmake系列,cmake]
relative-tags: [cmake系列]
excerpt: c,c++,cmake,CONFIGURE_FILE,configure_file
description: cmake的CONFIGURE_FILE
catalog: true
---

# cmake

## CONFIGURE_FILE

为了看看CONFIGURE_FILE的作用，来个例子

当前目录结构
```
test13# tree
.
├── build
├── CMakeLists.txt
├── helloworld.cpp
└── helloworld.h.in

1 directory, 3 files
```

CMakeLists.txt 的内容。
```cmake
test13# cat CMakeLists.txt 
# 最低版本
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
# 项目名称
PROJECT(HELLOWORLD)

# 设置两个值
SET (IP \"127.0.0.1\")
SET (PORT 8080)

# 使用configure_file
CONFIGURE_FILE (
  "${PROJECT_SOURCE_DIR}/helloworld.h.in"
  "${PROJECT_BINARY_DIR}/helloworld.h"
)
# 包含头文件
INCLUDE_DIRECTORIES (${PROJECT_BINARY_DIR})
# 生成可执行文件
ADD_EXECUTABLE (helloworld helloworld.cpp)
```

在helloworld.h.in中，注意不是helloworld.h
```c++
test13# cat helloworld.h.in 

#include <stdio.h>
#include <stdlib.h>

#define IP @IP@
#define PORT @PORT@
```
可以看到里面两个奇怪的define，定义了IP和PORT这两个宏，后面的东西却用两个@包起来
```
#define IP @IP@
#define PORT @PORT@
```

主程序就是打印IP和PORT内容，注意此处引用的是#include "helloworld.h"而不是，helloworld.h.in
```c++
test13# cat helloworld.cpp 
#include <stdio.h>
#include <stdlib.h>
#include "helloworld.h"

int main(int argc, char * args[]) {
  printf("hello world\n");
  
  printf("%s %d\n", IP, PORT);
}
```


进入build进行编译
```
test13# cd build/
test13/build# cmake ..
-- The C compiler identification is GNU 7.4.0
-- The CXX compiler identification is GNU 7.4.0
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
-- Configuring done
-- Generating done
-- Build files have been written to: /opt/x86/2019-09-12-cmaketest/test13/build
```
注意，此时build目录下生成了一个helloworld.h。再进行make

```
test13/build# make
Scanning dependencies of target helloworld
[ 50%] Building CXX object CMakeFiles/helloworld.dir/helloworld.cpp.o
[100%] Linking CXX executable helloworld
[100%] Built target helloworld

test13/build# ./helloworld 
hello world
127.0.0.1 8080
```

可以看到打印出了在CMakeLists.txt中定义的IP和PORT对应的值。

### `test13/CMakeLists.txt`解析

#### configure_file

```
configure_file(<input> <output>
               [COPYONLY] [ESCAPE_QUOTES] [@ONLY]
               [NEWLINE_STYLE [UNIX|DOS|WIN32|LF|CRLF] ])
```

通过输入文件生成输出文件，可以对文件内容进行替换，达到配置化的目的。

* <input> 输入文件
* <output> 输出文件
* COPYONLY 只复制，不会替换任何变量或者其他内容
* ESCAPE_QUOTES 转义引号
* @ONLY 限制只替换 @VAR@ 的变量，因为有时候<input>文件使用${VAR}这种语法
* NEWLINE_STYLE 换行类型，  UNIX或LF是\n， DOS或WIN32或CRLF是\r\n


其它的东西都是之前看过的，就只这段

```
# 使用configure_file
CONFIGURE_FILE (
  "${PROJECT_SOURCE_DIR}/helloworld.h.in"
  "${PROJECT_BINARY_DIR}/helloworld.h"
)
```

看过上面的例子应该就知道这个是什么作用了，将项目源代码目录下的helloworld.h.in进行解析，生成helloworld.h放置于项目编译目录下。

我们在这里设置了两个值
```
SET (IP \"127.0.0.1\")
SET (PORT 8080)
```

然后在helloworld.h.in中使用 `@名称@` 的方式来引用这两个值
```
#define IP @IP@
#define PORT @PORT@
```
所以最后在运行helloworld的时候，打印出来的就是定义在CMakeLists.txt中的这两个值。恩，就是这么简单。

#### 使用场景

我们可以根据实际情况指定使用什么IP和PORT，比如生产情况下使用一个IP和PORT，测试情况下使用另一个IP和PORT，如下，那么在不同场景下，生成的helloworld.h将会有不同的IP和PORT（类似spring在不同场景下加载不同的配置文件），这样我们就可以不去修改helloworld.h，而是每次生成需要的helloworld.h。
```
IF(<expression1>)
  SET (IP 10.10.10.10)
  SET (PORT 8080)
ELSEIF(<expression2>)
  SET (IP 20.20.20.20)
  SET (PORT 8081)
ELSE()
  SET (IP 30.30.30.30)
  SET (PORT 8082)
ENDIF()
```

如果配置项非常多，那么可以这样，把配置项放到文件中，然后在helloworld.h.in中来引用配置文件

```
// product.h file
#define IP 10.10.10.10
#define PORT 8080

// ... 许多define
```

```
// test.h file
#define IP 20.20.20.20
#define PORT 8081

// ... 许多define
```

```
// local.h file
#define IP 30.30.30.30
#define PORT 8082

// ... 许多define
```

然后在CMakeLists.txt文件中
```
IF(<expression1>)
  SET (ENV_INCLUDE_HEADER_FILE product.h)
ELSEIF(<expression2>)
  SET (ENV_INCLUDE_HEADER_FILE test.h)
ELSE()
  SET (ENV_INCLUDE_HEADER_FILE local.h)
ENDIF()
```

在helloworld.h.in中
```
#include <stdio.h>
#include <stdlib.h>
#include "@ENV_INCLUDE_HEADER_FILE@"
```

大概就这么个意思。

#### @cmakedefine

另外一种定义方式define的方式：

```
#cmakedefine FOO_ENABLE
#cmakedefine FOO_STRING "@FOO_STRING@"
```
如何在CMakeLists.txt配置文件中定义了如下内容
```
option(FOO_ENABLE "Enable Foo" ON)
if(FOO_ENABLE)
  set(FOO_STRING "foo")
endif()
configure_file(foo.h.in foo.h @ONLY)
```
那么将生成
```
#define FOO_ENABLE
#define FOO_STRING "foo"
```
如果没有定义，那么将会生成
```
/* #undef FOO_ENABLE */
/* #undef FOO_STRING */
```

这个在官网就了解到这个场景，可能还有其他骚操作等待发现

## 参考

* [更多命令与脚本参考cmake官网](https://cmake.org/cmake/help/v3.16/manual/cmake-commands.7.html)