---
title: "NebulaResultSetBoot"
date: 2023-05-12
draft: false
tags: ["归档","Nebula","开源"]
---
Nebula查询结果的封装对象ResultSet比较复杂，原因是需要保存数据类型。而JSON的一大缺点就是无法保存数据类型，当然这是它简洁的代价。

在实际生产过程中一些应用场景对数据类型并没有太多要求，典型的例子是可视化。很多小伙伴都有将valuewrapper转为自定义json对象的需求，或者是将官方的图模型映射到自己的领域模型的需求。我这里提供一个我写的框架抛砖引玉。

代码地址：https://github.com/Dragonchu/NebulaResultSetBoot

[https://github.com/Dragonchu/NebulaResultSetBoot](https://github.com/Dragonchu/NebulaResultSetBoot)

核心代码很简单，就这不断的判断value wrapper的数据类型，然后递归进行解析。

这里讲一下我个人对于nebula ResulSet模型的理解吧，Nebula的点是由id加tag列表组成，而每个tag对象里是tagName和一个属性Map，有很多人建模的时候只用单tag其实是没发挥这种模型的潜力的。

```java
public class Vertex {
    private final String id;
    private final List<Tag> tags;
}
```

```java
public class Tag {
    private final String name;
    private final Map<String, Object> properties;
}
```

边的模型比较简单，起点，终点，属性，rank，edgeType。

```java
public class Edge {
    private final String src;
    private final String dst;
    private final String name;
    private final Long ranking;
    private final Map<String, Object> properties;
}
```

路径的模型有一个段（segment）的概念，每个segment是一个三元组，<起点，终点，边>，对于独立的点，起点和终点是相同的。而路径是一个段列表。

```java
public class Segment {
    private final Vertex src;
    private final Vertex dst;
    private final Edge edge;
}
```

```java
public class Path {
    private final List<Segment> segments;
}
```

这样再去看ResultSet会比较明朗一些。