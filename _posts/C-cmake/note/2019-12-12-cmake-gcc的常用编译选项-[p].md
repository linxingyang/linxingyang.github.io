---
layout: post
permalink: /:year/bd7886a8b31e4fae9b51795b33d9b78c/index
title: 2019-12-12-cmake-gcc的常用编译选项
categories: [cmake]
tags: [c,c++,cmake系列,cmake]
relative-tags: [cmake系列]
excerpt: c,c++,cmake,gcc的常用编译选项
description: gcc的常用编译选项
catalog: true
---

# cmake

## gcc使用常用选项

###  -o 选项 指定输出可执行程序名称

```
gcc main.c -o main
```

### -Wall 开启所有的警告

如下代码

```
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char * args) {

    int i = 0;
    printf("hello world\n");
    return 0;
}
```

会发出警告，提示i没有被用到

```
# gcc main.c -o main -Wall
main.c:5:5: warning: second argument of ‘main’ should be ‘char **’ [-Wmain]
 int main(int argc, char * args) {
     ^
main.c: In function ‘main’:
main.c:7:9: warning: unused variable ‘i’ [-Wunused-variable]
     int i = 0;
         ^
```

### -Werror 警告变错误

将编译警告转换成错误.视警告为错误;出现任何警告即放弃编译.
编译警告很多时候会被我们忽视，在特殊场合我们还是需要重视编译警告，如果能把编译警告变长直接输出错误，那我们的重视程度会提高很多并去解决。

```
#include<stdio.h>

int main(void)
{
  char c;
  // Print the string
   printf("\n The Geek Stuff [%d]\n", c);
   return 0;
}
```

编译后将会报错

### -E 生成预编译文件

```
 gcc -E main.c > main.i
```

### -S 生成汇编文件

```
gcc -S main.c > main.s
```

### -C 生成没有带任何链接的代码

```
gcc -c main.c
```

The command above would produce a file main.o that would contain machine level code or the compiled code.

### -save-temps 生成所有文件

```
gcc -save-temps main.c
```

```
$ ls
a.out  main.c  main.i  main.o  main.s
```

### -l 链接动态库

```
gcc -Wall main.c -o main -lCPPfile
```

### -v 打印所有执行的命令

打印gcc执行过程中所有的步骤

```
$ gcc -Wall -v main.c -o main
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/i686-linux-gnu/4.6/lto-wrapper
Target: i686-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu/Linaro 4.6.3-1ubuntu5' --with-bugurl=file:///usr/share/doc/gcc-4.6/README.Bugs --enable-languages=c,c++,fortran,objc,obj-c++ --prefix=/usr --program-suffix=-4.6 --enable-shared --enable-linker-build-id --with-system-zlib --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --with-gxx-include-dir=/usr/include/c++/4.6 --libdir=/usr/lib --enable-nls --with-sysroot=/ --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --enable-gnu-unique-object --enable-plugin --enable-objc-gc --enable-targets=all --disable-werror --with-arch-32=i686 --with-tune=generic --enable-checking=release --build=i686-linux-gnu --host=i686-linux-gnu --target=i686-linux-gnu
Thread model: posix
gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5)
...
...
...
```

### -funsigned-char 所有的char被作为unsigned-char对待

```
#include<stdio.h>

int main(void)
{
  char c = -10;
  // Print the string
   printf("\n The Geek Stuff [%d]\n", c);
   return 0;
}
```

上面定义的 c将会被作为 unsigned-char对待

```
$ gcc -Wall -funsigned-char main.c -o main
$ ./main

 The Geek Stuff [246]
```

### -fsigned-char 所有的char被作为signed-char对待

还是上面那份代码，现在的情况是这种样的：

```
$ gcc -Wall -fsigned-char main.c -o main
$ ./main

 The Geek Stuff [-10]
```

### -D指定宏

```c
#include<stdio.h>

int main(void)
{
#ifdef MY_MACRO
  printf("\n Macro defined \n");
#endif
  char c = -10;
  // Print the string
   printf("\n The Geek Stuff [%d]\n", c);
   return 0;
}
```

The compiler option -D can be used to define the macro MY_MACRO from command line.

```
$ gcc -Wall -DMY_MACRO main.c -o main
$ ./main

 Macro defined 

 The Geek Stuff [-10]
```

### @ 指定选项文件

我们可以把所有的选项放在一个文件里面，然后使用@去引用。（Java也可以这样的。。。这样看，感觉Java应该是借鉴了gcc）

```
$ cat opt_file 
-Wall -omain
```

```
$ gcc main.c @opt_file
main.c: In function ‘main’:
main.c:6:11: warning: ‘i’ is used uninitialized in this function [-Wuninitialized]

$ ls main
main
```



###  -fpermissive



```
  -fpermissive
           Downgrade some diagnostics about nonconformant code from errors to warnings.  Thus, using -fpermissive will allow some nonconforming code to compile.
```

该选项会将不一致代码的诊断从错误降级为警告。

该选项最好不要使用，因为会降低对于代码检查的严格性。

该选项好像只能用于c++，对c是无效的（至少在我使用的gcc版本是这样的）。



```c++
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

const static char *source = "source";

int main(int argc, char *argv[])
{
    char buf[512];
    snprintf(buf, "%s", source);
    return 0;
}
```

在该代码中，snprintf并没有使用第二个参数sizeof(buf),如果不使用该选项，编译结果如下所示：

```
fpermissive.cpp: In function ‘int main(int, char**)’:
fpermissive.cpp:10: 错误：从类型 ‘const char*’ 到类型 ‘size_t’ 的转换无效
fpermissive.cpp:10: 错误：  初始化实参 2，属于 ‘int snprintf(char*, size_t, const char*, ...)’
```

可以看到，报的是错误，如果加上该选项编译，结果如下：

```
fpermissive.cpp: In function ‘int main(int, char**)’:
fpermissive.cpp:10: 警告：从类型 ‘const char*’ 到类型 ‘size_t’ 的转换无效
fpermissive.cpp:10: 警告：  初始化实参 2，属于 ‘int snprintf(char*, size_t, const char*, ...)’
```

可以看到，从错误级别降为了警告级别，而这可能会给程序带来意想不到的问题，所以，最好还是不要使用该选项







## 参考

* [更多命令与脚本参考cmake官网](https://cmake.org/cmake/help/v3.16/manual/cmake-commands.7.html)
* [gcc常用的编译选项](https://www.thegeekstuff.com/2012/10/gcc-compiler-options/)