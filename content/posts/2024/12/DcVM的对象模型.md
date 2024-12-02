---
title: "DcVm的对象模型"
date: 2024-12-02T09:54:36Z
draft: false
---

我在[用Rust写一个JVM](https://github.com/Dragonchu/DcVm)，整个项目从三个月前开始准备，查阅了大量的资料，也写了不少代码做试验，直到最近才走上正规，进入了稳定的开发阶段。

其中最困扰我的是如何设计DcVm的内存模型来表达Java的对象，我在之前没有用C++、Rust这种无GC的语言系统性的写过大项目，也没有过编写虚拟机或者语言解释器的经验，这部分着实花了我很久才找到一点头绪。

一开始的时候，我打算照搬[KiVM](https://github.com/imkiva/KiVM)的设计，KiVM是用C++编写的JVM，使用了一种简化的oop-klass模型。然而我在使用Rust编写时，发现照搬oop-klass模型实在是太复杂了，非常难以实现。oop-klass模型使用了大量的继承关系，并且oop-klass之前有引用的关系。官方也提到这种模型的实现里面有历史原因，比如markOop不是一个oop。我希望DcVM是一个简单的、优先考虑可读性而不是性能的教学用的JVM（未来打算进行可视化），所以我不想在新实现的时候还要背负hotspot这种成熟的、性能高的的JVM的复杂实现。

然后我又去研究了[rjvm](https://github.com/andreabergia/rjvm)的设计，rjvm使用Rust编写的Jvm，它的实现是类似与解释性语言的虚拟机实现，在底层通过复杂的指针操作，将类型信息直接写入内存，这在写简单的解释型语言的虚拟机时是个场景的做法，但是Java的字节码里是有类型信息的，底层这种大量的指针操作使得代码很不直观，作者也对这部分实现不满意。

百思不得其解时，我读到了[Writing Interpreters in Rust: a Guide](https://github.com/rust-hosted-langs/book)这边教程，这个教程并不是写JVM的，而是教如何写一个解释型语言的虚拟机实现的。代码很好，让我学到了很多rust的使用方式，我尝试使用其中TaggedPtr, FatPtr, ScopterPtr, TaggedScopterPtr, RawPtr各种Ptr来表示我的底层实现。我发现这太复杂了，我大部分实现都在思考用什么Ptr，这些ptr在教程里的好处是在虚拟机实现的时候写代码在编译期能拿到类型，但这只使用与解释型语言，因为他们的类型是固定的几种，而Java是可以自定义类型的。

最终，我决定简化oop-klass模型，将oop始作数据的存储区，将klass始作算法的存储区，DcVM的类型分为三类：原始类型、instance和Array, 原始类型是int、long这些，而Instance是自定义的类型，每个instanceOop会指向一个instanceKlass(虚拟机运行时同一个类可以很多个oop， 但只能有1个klass), Array是个递归的结构（里面可以存Array, Instance或原始类型）。整体的实现目前没有使用裸指针，先用typed_arena做了简单的内存分配(后面要自己写内存分配器和垃圾回收), 所以代码里有大量的引用的生命周期参数。目前我简单的将所有的生命周期都写成一样的，后续对生命周期理解深入了之后需要做一下优化。
