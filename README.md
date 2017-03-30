<p align="center" ><b><font size="8">iOS入门级攻城尸</font></b></p>
<p align="center" >
  <img src="iOSLogo.jpg" title="XYAsynchronousManager logo" float=left>
</p>


当你需要同时并发多个或者多组异步线程,并等并发完成之后执行某些操作的时候可以使用此框架。
使用此框架你可以完全不考虑线程和同步的相关知识。
只需要简单的设置,我就会再合适的时机通知你操作完成。

## Features

- [x] 线程安全:你可以在任意线程的任何时刻直接调用此框架!避免了切换线程和管理同步锁的麻烦
- [x] 内部使用`pthread_mutex_t`加锁,性能优异,几乎感觉不到资源消耗!
- [x] 使用分离锁结将锁的粒度缩小到每组并发一把锁!
- [x] 从不死锁!

## Installation
- 直接将`XYAsynchronousManager`文件夹拖入项目中即可。


## How To Use

```
#import "XYAsynchronousManager.h"
...
//1、设置总并发数量，并给这组并发设置一个唯一id
[[XYAsynchronousManager sharedManager] xy_synchronizeWithIdentifier:@"oneGroup" totalCount:self.taskArray.count doneBlock:^{
    XYAM_Log(@"oneGroup Tasks Done!");
}];
...
[self.taskArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XYAM_Log(@"Task %@ executed", obj);

        //2、当你完成一步操作的时候，告知manager你完成了一步操作，你可以完全不考虑当前是在什么线程内，只需要直接调用即可。
        [[XYAsynchronousManager sharedManager] xy_synchronizeOneStepByIdentifier:@"oneGroup"];
    });
}];
```

## Communication
- 有任何问题欢迎加我的简书和微博讨论
- iOS入门级攻城尸的:[简书](http://www.jianshu.com/u/4c5a9f6f6831)、[微博](http://weibo.com/xuyang186)
