---
layout: post
permalink: /:year/5b849418e8ce4e3785cb179f21b11113/index
title: 2020-11-05-c++-iconv-字符名称中缺少横杆引发coredump
categories: [c/c++]
tags: [c/c++,iconv]
excerpt: c/c++,cpp,iconv,字符名称中缺少横杆引发coredump
description: cpp-iconv-字符名称中缺少横杆引发coredump
catalog: false
---


昨天碰到一个挺无语的问题的，找到问题的时候我自嗨一句：居然还有这种问题。。。


**在ubuntu20中编译通过的源码，放到ubuntn16上居然coredump。。。**（为何开发用ub20，还要放到u16上？别问，问就是稳定）

定位到是iconv_open的问题，起初还想是不是分配的空间不够大? 编码字串大小写问题? 试了一下都没解决。最后没的怀疑，我就想看看，在那个utf8中间加个横杆试试，乖乖，可以了，但这个问题解决的毫无成就感 >_<

```
int GbkToUtf8(char * str_str, size_t src_len, char * dst_str, size_t dst_len) {
    iconv_t cd;
    char **pin = &str_str;
    char **pout = &dst_str;

    /* 
     * utf8中必须要有横线，在ubuntu16TLS中编译通过运行coredump，在ubuntu20TLS上没问题
     */
    // cd = iconv_open("utf8", "gbk");
    cd = iconv_open("utf-8", "gbk");
    if (cd == 0) {
        return -1;
    }

    memset(dst_str, 0, dst_len);
    if (int(iconv(cd, pin, &src_len, pout, &dst_len)) == -1) {
        return -1;
    }
    
    iconv_close(cd);

    return 0;
}
```



我在ubunt16看看了一下，UTF8和UTF-8都是支持的好吧，不过它前面简介倒是说了，列在其中的字符编码可能不可用。
这，这是什么操作？人与人之间的信任呢？。。惨遭社会毒打。。


```
# iconv -l

The following list contains all the coded character sets known.  This does
not necessarily mean that all combinations of these names can be used for
the FROM and TO command line parameters.  One coded character set can be
listed with several different names (aliases).

...

  UNICODE, UNICODEBIG, UNICODELITTLE, US-ASCII, US, UTF-7, UTF-8, UTF-16,
  UTF-16BE, UTF-16LE, UTF-32, UTF-32BE, UTF-32LE, UTF7, UTF8, UTF16, UTF16BE,
  UTF16LE, UTF32, UTF32BE, UTF32LE, VISCII, WCHAR_T, WIN-SAMI-2, WINBALTRIM,
...

```


