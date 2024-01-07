---
title: "HadoopMapReduce代码分析GrepExample（二）"
date: 2023-02-23
draft: false
tags: ["归档","Hadoop"]
---

run方法先进行命令行参数校验，没什么好看的。

接下来创建临时文件，用的是Path类，目前也没什么好看的。

接下来获取Configuration，用的实现的接口的getConf()，在之前ToolRunner中已经set了一个了，这个Configuration很简单，直接new出来的，loadDefaults为true。

（Context和conf是不一样的两个东西）

conf目前看起来是简单的map存放各种配置，里面会有些对过期的key的检查与设置。

接下来创建了一个Job，job里面用了深拷贝将conf里的配置拷贝给自己，这样job中随便怎么修改conf也不会影响外部，深拷贝将conf变成了JobConf。

然后在Job中set需要执行的类，这次就是Grep.class，我觉得这一步非常关键，好好学一下。

进去之后就是先找jar包，好像确实就是找jar，最后返回的是file:这种通用文件定位格式的字符串。

后面的设置mapper,reducer,combiner class没什么复杂的，就是把对应的class保存起来。

重头戏应该是waitForCompletion，这个函数就是将job提交到cluster。

Job一共就只有两种状态，DEFINE，RUNNING，如果是DEFINE那就提交。粗看了一下，这里的wait是提交上去之后立即返回，然后不断轮询状态，要是轮询失败了就抛异常。看看submit()函数里具体做了什么。

好吧，submit这里就有点看不懂了，好像做了一些mock，得debug进去看一看