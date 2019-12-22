---
layout: post
permalink: /:year/0f54414a5711484492943c0cb58bd7b4
title: 2019-09-26-c-cmake-ADD_DEFINITION
categories: [c]
tags: [c,c++,cmake系列,cmake]
relative-tags: [cmake系列]
excerpt: c,c++,cmake,ADD_DEFINITION
description: cmake的ADD_DEFINITION
catalog: true
---

# CMake

## add_definitions

### -D 的使用

最基本的用法，在CMakeLists.txt中定义一个TYPE_B

```cmake
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
PROJECT (HELLOWORLD)

MESSAGE (STATUS " mode is " ${CMAKE_BUILD_TYPE})

ADD_DEFINITIONS(-DTYPE_B)

ADD_EXECUTABLE (helloworld helloworld.cpp)
```

然后在代码中使用 #ifdef来判断

```c++
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char * args[]) {
  printf("hello world\n");
  int a;
  int b = 1;
#ifdef TYPE_A
  printf("it's TYPE_A\n");
#elif TYPE_B
  printf("it's TYPE_B\n");
#else
  printf("it's NOTHING\n");
#endif

}
```

最后输出

```
 ./helloworld 
hello world
it's TYPE_B
```

### -w -W的使用

Wall选项意思是编译后显示所有警告,会打开一些很有用的警告选项，建议编译时加此选项。

* -Wall
选项可以打印出编译时所有的错误或者警告信息。这个选项很容易被遗忘，编译的时候，没有错误或者警告提示，以为自己的程序很完美，其实，里面有可能隐藏着许多陷阱。变量没有初始化，类型不匹配，或者类型转换错误等警告提示需要重点注意，错误就隐藏在这些代码里面。没有使用的变量也需要注意，去掉无用的代码，让整个程序显得干净一点。下次写Makefile的时候，一定加-Wall编译选项。
* -werror
将编译警告转换成错误.视警告为错误;出现任何警告即放弃编译.
编译警告很多时候会被我们忽视，在特殊场合我们还是需要重视编译警告，如果能把编译警告变长直接输出错误，那我们的重视程度会提高很多并去解决。

**推荐开启这一项，大佬的开发环境是将这一项开启的，不允许任何带有警告的代码上传到库。**

* -Wextra

打印一些额外的警告信息

```cmake
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
PROJECT (HELLOWORLD)

MESSAGE (STATUS " mode is " ${CMAKE_BUILD_TYPE})

# 要同时开启Wall和Werror
# 显示所有警告
ADD_DEFINITIONS(-Wall)
# 警告变成错误
ADD_DEFINITIONS(-Werror)
# 定义宏 TYPE_B
ADD_DEFINITIONS(-DTYPE_B)

# 还可以指定其它的
#ADD_DEFINITIONS(-fsigned-char)
#ADD_DEFINITIONS(-funsigned-char)
#ADD_DEFINITIONS(-Wno-deprecated)

ADD_EXECUTABLE (helloworld helloworld.cpp)
```

此时在代码中有一个变量b没有被使用，那么将编译报错。因为Werror将编译警告变为编译错误。

```c++
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char * args[]) {
  printf("hello world\n");

  char a = -10;
  int b;

  printf("a is %d\n", a);
#ifdef TYPE_A
  printf("it's TYPE_A\n");
#elif TYPE_B
  printf("it's TYPE_B\n");
#else
  printf("it's NOTHING\n");
#endif

}
```

```
[ 50%] Building CXX object CMakeFiles/helloworld.dir/helloworld.cpp.o
/tmp/c/2019-09-12-cmaketest/test12/helloworld.cpp: In function ‘int main(int, char**)’:
/tmp/c/2019-09-12-cmaketest/test12/helloworld.cpp:7:7: error: unused variable ‘b’ [-Werror=unused-variable]
   int b;
       ^
cc1plus: all warnings being treated as errors
CMakeFiles/helloworld.dir/build.make:62: recipe for target 'CMakeFiles/helloworld.dir/helloworld.cpp.o' failed
make[2]: *** [CMakeFiles/helloworld.dir/helloworld.cpp.o] Error 1
CMakeFiles/Makefile2:67: recipe for target 'CMakeFiles/helloworld.dir/all' failed
make[1]: *** [CMakeFiles/helloworld.dir/all] Error 2
Makefile:83: recipe for target 'all' failed
make: *** [all] Error 2
```

## 参考

* [更多命令与脚本参考cmake官网](https://cmake.org/cmake/help/v3.16/manual/cmake-commands.7.html)