//
//  XYSynchronizer.h
//  XYAsynchronousManager
//
//  Created by xuyang on 2017/3/29.
//  Copyright © 2017年 SeanXuCn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYAsynchronousCompat.h"


NS_ASSUME_NONNULL_BEGIN
@class XYSynchronizer;
@protocol XYSynchronizerDelegate <NSObject>
@required
/**
 当一个synchronizer完成了它的任务时，这个函数会被调用。用于通知XYAsynchronousManager回收内存
 */
- (void)XYSynchronizer:(XYSynchronizer *)synchronizer didFinishedWithIdentifier:(NSString *)identifier;
@end

@interface XYSynchronizer : NSObject
- (instancetype)initWithIdentifier:(nonnull NSString *)identifier
                        totalCount:(NSUInteger )totalCount
                          delegate:(nonnull id<XYSynchronizerDelegate>)delegate
                     progressBlock:(nullable XYAsynchronousPregress)progress
                         doneBlock:(nonnull XYAsynchronousDone)done
                  doneOnMainThread:(BOOL)onMineThread;
- (void)xy_synchronizeOneStep;
@end

NS_ASSUME_NONNULL_END
