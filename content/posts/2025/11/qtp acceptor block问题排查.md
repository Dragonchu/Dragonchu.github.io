---
title: "Qtp Acceptor Block问题排查"
date: 2025-11-28T03:55:17Z
draft: false
---

线上发现每一台机器都始终有一个线程block, 并且每一个block的线程名都一样。qtpxxxx-acceptor-1@xxx-ServerConnector@xxx{HTTP/1.1,(http/1.1)}{0.0.0.0:8080}。
*xxxx指代各种数字编码*。

https://github.com/jetty/jetty.project/issues/760
https://github.com/jetty/jetty.project/issues/3266

在jetty里，这种现象是正常的，当没有请求的时候，一个acceptor会监听，其他的acceptor会被阻塞。但是我们服务之前是没有这个block线程的，查看其他类似的服务也没有发现有block线程。一定是有什么发生了变化导致acceptor变多了。

https://github.com/jetty/jetty.project/blob/a9729c7e7f33a459d2616a8f9e9ba8a90f432e95/jetty-server/src/main/java/org/eclipse/jetty/server/AbstractConnector.java#L222-L227

结合代码和网上的资料，jetty在12.0.7版本之前的计算公式是
```java
        int cores = ProcessorUtils.availableProcessors();
        if (acceptors < 0)
            acceptors = Math.max(1, Math.min(4, cores / 8));
        if (acceptors > cores)
            LOG.warn("Acceptors should be <= availableProcessors: " + this);
        _acceptors = new Thread[acceptors];
```

我们机器最近扩配，核数从8升级为16，所以acceptor数量从1变成了2，当变成2后就出现1个acceptor被阻塞。
> You have 2 ServerConnectors, so you have 1 RUNNABLE thread each, 1 lock each, and N-1 BLOCKED threads each (where N is the number of acceptors you have configured).
