---
title: "Mysql事务实战"
date: 2024-05-29
draft: false
tags: ["mysql"]
---
## 前言

Mysql的事务机制，各类书籍博客上都讲了很多，八股文也基本都有，但是我属于不实践都搞不懂的笨蛋，所有本文来通过实践理解mysql的四个事务级别。

## mysql安装（已经安装的可以跳过）

首先安装mysql，我使用的是Mac，安装mysql很简单。

```brew install mysql```

接着执行

```brew services start mysql```启动mysql

因为只是在本地测试，直接使用```mysql -u root```登录就可以

本文的目的是想要实践mysql的事务，为了更加直观的操作，所以不使用额外的客户端操作mysql，但是直接使用终端比较麻烦，所以我推荐安装[mycli](https://www.mycli.net/)

在Mac上的安装也很简单，```brew install mycli```

这时就可以使用```mycli -u root```连接mysql了

## 测试数据准备

本文的测试数据使用官方的[测试数据集](https://github.com/datacharmer/test_db), 按照readme文档，设置数据就好。

## 开始研究

首先执行```select * from employees limit 10;```看一下有那些数据。

![imgage001](/img/2024/05/image001.png)

ANSI SQL标准定义了4种隔离级别。

1. READ UNCOMMITTED
2. READ COMMITTED
3. REPEATABLE READ
4. SERIALIZABLE

### READ UNCOMMITTED

如其名所描述，这种数据库隔离级别的特征肯定是读到uncommitted的数据。首先我们打开不同的终端，开启两个数据库连接。在两个数据库终端中设置当前会话的事务提交类型为READ UNCOMMITTED

```SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;```

接着在两个数据库连接中都开启事务

```start transaction;```

首先，我们在两个事务中都查询一下编号为10002的员工的性别。

```select * from employees where emp_no = '10002';```

打开第三个终端，查询当前事务的状态。

```SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX\G```

![imgage002](/img/2024/05/image002.png)

当前，有两个事务，分别是281479414878104和28147941487731，他们的事务级别也都是READ UNCOMMITTE，值得注意的是trx_weight这个字段。InnoDB目前处理死锁的方式是将持有最少行级排他锁的事务回滚。为了解决死锁,InnoDB 选择一个小的权重的事务来回滚。

接下来我们在事务A中更新1002的性别，不提交事务A，在事务B中进行查询。

事务A：```update employees set gender = 'M' where emp_no = '10002';```

事务B：```select * from employees where emp_no = '10002';```

![imgage003](/img/2024/05/image003.png)

可以看到在read uncommitted事务下，事务B读取到了事务A中还没有提交的变动。

我们再在事务B中更新1002的性别（这个时候仍然不提交事务A）

事务B更新：```update employees set gender = 'F' where emp_no = '10002';```

![imgage003](/img/2024/05/image003.png)

我们发现这个事务B会被阻塞，所以read uncommitted状态下，两个事务修改同一个行仍然会有阻塞现象发生。

read uncommitted级别下，一个事务可以读取到另一个事务暂未提交的改变，在我们上述的例子中，如果事务A的更新失败回滚了，事务B中第一次读取到的数据是脏数据。举一个实际的例子，一个用户在某个商城进行实名认证，商城中的一个购物活动需要验证用户的实名状态。假如使用的都是read uncommitted事务级别，那么会发生这种情况，用户提交实名，系统异常导致实名的事务最终回滚，但是在提交到回滚这段时间，购物活动前来请求并且读到了用户已经完成实名。而用户在系统实名认证失败后放弃再次实名，并且秒杀活动后续也没有重新校验用户的实名状态，就会出现一个未实名的用户参与购物活动的现象发生。
这么一个问题就叫做「脏读」

### READ COMMITTED

我们将两个会话的事务级别调整为 read committed。

```SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;```

同样的，我们在两个会话中开启事务，并查询一下当前1002的状态。


