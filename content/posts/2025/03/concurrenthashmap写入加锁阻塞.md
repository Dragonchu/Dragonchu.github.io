---
title: "Concurrenthashmap写入加锁阻塞"
date: 2025-02-19T12:48:07+08:00
draft: false
---

我们有一个服务会往数据库中写入一系列的规则，并且查询请求是否命中了这些规则。

规则的数据结构非常复杂， 拓展性很强， 劣势直接使用这种数据结构进行查询性能很差。 为此，我们设计了一个定时任务， 定期的将写入时的mysql数据转化为能更加快速读取的redis缓存数据结构。（我们的规则生效允许有一定的延时， 所以定时任务可以满足要求）

每个请求会读取该请求所需要的规则，同时也会读取全局规则。 规则都存储在redis中，所以大量请求读取全局规则会导致热点key问题。

为了解决热点key问题，我们为这些全局规则做了服务上的本地缓存。（全局规则的数量很少，一共只会占用不到1mb的内存）。

进行压力测试时，发现大量的读请求阻塞在concurrenthashmap的compute方法上， 导致80%的请求超时失败，服务无法正常提供功能。

原因是使用的本地缓存，在读取redis上值为空时写入空，这会导致每个本地缓存读取请求都触发一次缓存更新操作（从redis读取）并写入底层的concurrenthashmap中，而concurrenthashmap的写入需要加锁并且性能很差，导致请求被阻塞。业务原因是，全局规则有可能不存在，所以redis上也不存在相应的值。

最终，通过读取不到规则时设置一个对应的空规则而不是null，解决了该问题。
