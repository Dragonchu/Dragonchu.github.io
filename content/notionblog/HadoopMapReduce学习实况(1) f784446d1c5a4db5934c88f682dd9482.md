---
title: "HadoopMapReduce学习实况(1)"
date: 2023-02-17
draft: false
tags: ["归档","Hadoop"]
description: "解读MapReduce: Simplified Data Processing on Large Clusters"
---

MapReduce是一个编程模型，基本思想是：

用户编写一个Map程序，这个Map程序的输入是一个key/value pair，输出也是一个key/value pair。（当然也能是一组，这就是具体实现的区别，下文会看谷歌的具体实现）

用户再编写一个Reduce程序，这个Reduce程序的输入是先前Map程序的输出，这个Reduce程序将先前Map程序输出的所有key/value pair按照key进行merge。

这个思想很简单，但是在实践中想要用这种编程方式并行处理大数据需要处理一些问题。

1. 输入的数据进如何进行分区
2. 每一个程序该在哪台机器上执行
3. 集群中有机器坏了如何处理
4. 机器之间如何传递数据

这些问题都需要解决，并且要高效，要让程序尽可能的快

谷歌把这些问题解决了，然后发表了这篇论文，厉害之处在于他们把上述复杂的问题解决了（还保证程序能跑的很快），给开发者暴露出简单的接口，这样开发者只需要专注于程序的逻辑，不需要考虑分布式运行时出现的各种问题。

谷歌的MapReduce编程模型

用户写的Map程序接受一个key/value pair，输出一组key/value pairs。

MapReduce Library将这一组key/value pairs按照key进行merge，然后将结果传给用户写的Reduce程序（为了防止OOM，Reduce通过迭代器模式获取这些结果）。

用户写的Reduce程序接受一个key和这个key对应的一堆values，然后把这一堆values变成一小堆values，这一小堆values的数目通常是1或者0。

再明确一下MapReduce只是一种编程模型，在不同的场合下可以有不同的实现