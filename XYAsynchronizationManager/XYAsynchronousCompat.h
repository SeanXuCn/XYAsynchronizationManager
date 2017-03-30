//
//  XYAsynchronousCompat.h
//  XYAsynchronousManager Demo
//
//  Created by xuyang on 2017/3/29.
//  Copyright © 2017年 SeanXuCn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __OBJC_GC__
#error XYAsynchronousManager does not support Objective-C Garbage Collection
#endif

#ifdef DEBUG
#define XYAM_Log(...) NSLog(__VA_ARGS__);
#else
#define XYAM_Log(...)
#endif

/**
 *  progressBlock
 *
 *  @param currentCount 当前完成的数量
 *  @param totalCount   总并发数量
 */
typedef void (^XYAsynchronousPregress)(NSUInteger currentCount,NSUInteger totalCount);

/**
 *  doneBlock
 */
typedef void (^XYAsynchronousDone)();

