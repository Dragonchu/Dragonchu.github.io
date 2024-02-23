---
title: "AutoWire可以注入列表和字典"
date: 2024-02-23
draft: false
tags: ["spring", "java"]
---

目前我们业务代码里有一种常见的模式，定义一个接口，接着通过多个handler类实现这个接口, 在面对不同的情况时通过调用不同的handler类来处理业务代码，通常这些handler类都会继承一个公用的父类，父类中会有一些公共的方法。

本文不讨论这种模式的合理性，单纯从技术角度分析实现的方案。因为在Java生态下，都是使用spring框架。所以之前的业务代码中都会把这些handler做成bean，而如何使用这些bean，实现方案千奇百怪。有交给spring ioc容器管理后，自行从context中根据bean name获取的。也有手动注入到一个大map中的。

其实官方文档里指出里Autowired注解是可以自动注入map和list的，这句话有点奇怪，我还是直接show code吧。

我使用的java版本是
```shell
openjdk 21.0.2 2024-01-16
OpenJDK Runtime Environment (build 21.0.2+13-58)
OpenJDK 64-Bit Server VM (build 21.0.2+13-58, mixed mode, sharing)
```

对于使用spring的ioc容器和bean而言，只需要spring-context依赖即可。

```mvn
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>6.1.4</version>
</dependency>
```

首先我们定义一个接口IMan和它的两个字类Teacher和Student, 为了方便我们不加入额外的逻辑和属性
```java
public interface IMan {}
```
```java
public class Teacher implements IMan{}
```
```java
public class Student implements IMan{}
```

我们在实现一个ClassRoom类，该类使用@AutoWried注解注入一个元素类型为IMan的list和一个key为String, Value类型为IMan的map

```java
public class ClassRoom {
    @Autowired
    IMan[] people;
    @Autowired
    Map<String, IMan> categories;
}
```

同时，使用xml配置自动装配和相关的bean
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans.xsd
                           http://www.springframework.org/schema/context
                           http://www.springframework.org/schema/context/spring-context.xsd">


    <!-- 启用自动装配 -->
    <context:annotation-config/>

    <bean name="teacher" class="org.example.Teacher"/>
    <bean name="student" class="org.example.Student"/>
    <bean name="classRoom" class="org.example.ClassRoom"/>
</beans>
```

在主类中，通过ClassPathXmlApplicationContext读取xml配置后，通过IOC容器获取classRoom
```java
public class Main {
    public static void main(String[] args) {
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("spring-root.xml");
        ClassRoom classRoom = applicationContext.getBean("classRoom", ClassRoom.class);
        Teacher teacher = applicationContext.getBean("teacher", Teacher.class);
        Student student = applicationContext.getBean("student", Student.class);
        System.out.println("Teacher Bean: "+teacher);
        System.out.println("Student Bean: "+student);
        for (IMan man : classRoom.people) {
            System.out.println(man);
        }
        System.out.println(classRoom.categories);
    }
}
```

查看运行结果, 可以看到被AutoWired注解标记的list和map会自动注入相关接口的实现bean，并且对于map，它的主键会是bean的name, 值则是对应的bean
```shell
Teacher Bean: org.example.Teacher@6af93788
Student Bean: org.example.Student@ef9296d
org.example.Teacher@6af93788
org.example.Student@ef9296d
{teacher=org.example.Teacher@6af93788, student=org.example.Student@ef9296d}
```
