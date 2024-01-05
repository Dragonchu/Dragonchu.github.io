# ANTLR学习笔记（2）

date: March 8, 2023
inList: No
inMenu: No
publish: Yes
tags: ANTLR, 归档
template: post

**书籍名称**：The definitive ANTLR 4 Reference

**章节：Chapter4 A quick tour**

<aside>
🧵 线索

</aside>

<aside>
📓 笔记

</aside>

---

ANTLR解析的模版

g4文件中这样定义可以在生成的java文件中创造出常量MUL

使用vistor手动遍历

使用Listener

还可以深度自定义

---

```java
public static void main(String[] args) throws IOException {
        String inputFile = null;
        if (args.length > 0){
            inputFile = args[0];
        }
        InputStream is = System.in;
        if(inputFile!=null){
            is = new FileInputStream(inputFile);
        }
        ANTLRInputStream input = new ANTLRInputStream(is);
        ExprLexer lexer = new ExprLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        ExprParser parser = new ExprParser(tokens);
        ParseTree tree = parser.prog();
        System.out.println(tree.toStringTree(parser));
    }
```

词法解析和语法解析可以拆分成两个文件，使用idea插件生成只需要先生成词法再生成语法就可以。

ANTLR中//是注释，#是加标签，没有标签ANTLR默认只为一个rule创建一个vistor

```java
MUL : '*' ;
```

使用vistor需要继承xxxBaseVistor类

```java
ParseTree tree = parser.prog();
xxxVisitor vistor = new xxxVisitor();
vistor.visit(tree);
```

使用listener需要继承xxxBaseListenre类

```java
ParseTreeWalker walker = new ParseTreeWalker(); // create standard walker 
xxxListener listener = new xxxListener(parser); 
walker.walk(listener, tree); // initiate walk of tree with listener
```

需要在g4文件中定义，我目前用应该用不着，很复杂

```java
@parser::members { // add members to generated RowsParser int col;
public RowsParser(TokenStream input, int col) { // custom constructor this(input);
        this.col = col;
    }
}
```

<aside>
🗯️ 总结

</aside>

---

ANTLR4使用还是很简单的，生成了代码之后使用继承vistor和listener就可以，深入的学习目前用不到，等需要定制开发语言再继续学习。