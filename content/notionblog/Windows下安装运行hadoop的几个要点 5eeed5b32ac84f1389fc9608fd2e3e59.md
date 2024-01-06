---
title: "Windows下安装运行hadoop的几个要点"
date: 2022-09-29
draft: false
tags: ["Hadoop","归档","环境配置"]
description: "没有办法必须在windows部署hadoop2.7.1，请注意这几点"
---

1. hadoop2.7.1要使用的jdk必须是64位的，使用javac命令，如果是64位的jdk会有64的字眼出现，没有就不是64位的，这一点很关键，32位的sdk是运行不了hadoop2.7.1的。
2. hadoop的压缩包解压需要管理员权限
3. 环境变量里面要添加HADOOP_HOME，path路径里面要增加hadoop安装目录下的bin
4. 要修改**Hadoop-2.7.1/etc/hadoop/hadoop-env.cmd**里面java的路径，**JAVA_HOME=%JAVA_HOME%**，理论上如果环境变量里面设置了JAVA_HOME也就不需要改了

伪集群运行，配置文件哪些是必须填的，哪些是选择，有什么作用？

```xml
<!--core-site.xml-->
<configuration>

   <property>
       <!--这是选择使用默认的文件系统-->
       <name>fs.defaultFS</name>

       <!--使用localhost，这样hdfs的客户端连接端口会默认启动在localhost:8020上，才能在本机通过hadoop fs命令以及直接用java api 访问-->
       <value>hdfs://localhost/</value>

   </property>

</configuration>
```

```xml
<!--mapred-site.xml-->
<configuration>

   <property>

       <name>mapreduce.framework.name</name>

       <value>yarn</value>

   </property>

</configuration>
```

```xml
<!--hdfs-site.xml-->
<configuration>

   <property>
       <!--配置副本数-->
       <name>dfs.replication</name>

       <value>1</value>

   </property>
   <!--下面的namenode和datanode路径是可选的，主要是为了指定namenode和datanode的路径，如果不指定的话，hadoop会在默认路径下生成这些文件，好像是直接在根目录下生成（反正不在安装目录下，要看一下日志文件），指定路径就要在相对于的位置下（这里是安装目录下）创建相对应的目录-->
   <property>

       <name>dfs.namenode.name.dir</name>

       <value>/hadoop-2.7.1/data/namenode</value>

   </property>

   <property>

       <name>dfs.datanode.data.dir</name>

       <value>/hadoop-2.7.1/data/datanode</value>

   </property>

</configuration>
```

```xml
<!--yarn-site.xml-->
<configuration>

   <property>

                <name>yarn.nodemanager.aux-services</name>

                <value>mapreduce_shuffle</value>

   </property>

</configuration>
```

执行**hdfs namenode –format**，在bin目录下，bin目录已经设在path里了，应该在哪里都可以直接使用

执行**start-all.cmd**，在sbin目录下

会启动四个服务，使用jps可以查看

四个服务分别是namenode的服务，datanode的服务，yarn里面的两个服务，一个负责资源管理，一个负责节点管理