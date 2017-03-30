//
//  XYAsynchronousManager.h
//  XYAsynchronousManager
//
//  Created by xuyang on 2017/3/29.
//  Copyright © 2017年 SeanXuCn. All rights reserved.
//
//
/**
 1、你要通过调用
 - (void)xy_synchronizeWithIdentifier:(nonnull NSString *)identifier
                            totalCount:(NSUInteger )totalCount
                            doneBlock:(nonnull XYAsynchronousDone)done; 
 来告诉我你一共有多少个并发操作。
 
 2、当你在任何线程的任何时刻完成了一步操作的时候。都可以通过
 - (void)xy_synchronizeOneStepByIdentifier:(nonnull NSString *)identifier;
 来告诉我你完成了一步操作。
 
 3、接下来等你所有的并发线程都完成的时候,我会调用doneBlock。

 */

#import <Foundation/Foundation.h>
#import "XYAsynchronousCompat.h"
NS_ASSUME_NONNULL_BEGIN

@interface XYAsynchronousManager : NSObject

@property (nonatomic, copy, readonly) NSString *version;

/**
 * Returns global XYAsynchronousManager instance.
 *
 * @return XYAsynchronousManager shared instance
 */
+ (instancetype)sharedManager;

/**
 *  注册一个同步管理器(synchronizer),每一个同步管理器都负责管理一个并发组的锁和回调函数
 *  在不关心进度的情况下强烈推荐使用本函数!
 *  不设置progressBlock将会显著的提升回调函数的即时性
 *
 *  @param identifier   每一个并发组的唯一id
 *  @param totalCount   一共有多少个操作需要并发执行
 *  @param doneBlock    所有并发操作执行完成之后会调用它
 */
- (void)xy_synchronizeWithIdentifier:(nonnull NSString *)identifier
                          totalCount:(NSUInteger )totalCount
                           doneBlock:(nonnull XYAsynchronousDone)doneBlock;

/**
 *  注册一个同步管理器(synchronizer),每一个同步管理器都负责管理一个并发组的锁和回调函数
 *
 *  @param identifier   每一个并发组的唯一id
 *  @param totalCount   一共有多少个操作需要并发执行
 *  @param progress     当前完成的进度(异步调用,会比你真正调用完成的时机晚一些,如果对进度的即时性要求比较强,请不要以此为参考标准)
 *  @param doneBlock    所有并发操作执行完成之后会调用它
 */
- (void)xy_synchronizeWithIdentifier:(nonnull NSString *)identifier
                          totalCount:(NSUInteger)totalCount
                       progressBlock:(nullable XYAsynchronousPregress)progress
                           doneBlock:(nonnull  XYAsynchronousDone)doneBlock;

/**
 *  注册一个同步管理器(synchronizer),每一个同步管理器都负责管理一个并发组的锁和回调函数
 *
 *  @param identifier   每一个并发组的唯一id
 *  @param totalCount   一共有多少个操作需要并发执行
 *  @param progress     当前完成的进度(异步调用,会比你真正调用完成的时机晚一些,如果对进度的即时性要求比较强,请不要以此为参考标准)
 *  @param doneBlock    所有并发操作执行完成之后会调用它
 *  @param onMineThread 为了尽可能的保证回调操作的即时性,默认回调将会在最后一个并发线程中执行。如果需要在主线程中完成回调,将此参数设置为YES。
 */
- (void)xy_synchronizeWithIdentifier:(nonnull NSString *)identifier
                          totalCount:(NSUInteger )totalCount
                       progressBlock:(nullable XYAsynchronousPregress)progress
                           doneBlock:(nonnull  XYAsynchronousDone)doneBlock
                    doneOnMineThread:(BOOL)onMineThread;

/**
 *  通过组id，告知管理器(synchronizer)计数加一
 *
 *  @param identifier   每一个并发组的唯一id
 */
- (void)xy_synchronizeOneStepByIdentifier:(nonnull NSString *)identifier;

/**
 *  通过组id，销毁一个管理器(synchronizer)
 *  当某个并发组注定不会被完成时，请手动调用销毁。
 *  @param identifier   每一个并发组的唯一id
 */
- (void)xy_destorySynchronizerByIdentifier:(nonnull NSString *)identifier;
@end
NS_ASSUME_NONNULL_END
