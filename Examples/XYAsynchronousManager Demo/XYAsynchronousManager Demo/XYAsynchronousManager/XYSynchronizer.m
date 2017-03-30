//
//  XYSynchronizer.m
//  XYAsynchronousManager
//
//  Created by xuyang on 2017/3/29.
//  Copyright © 2017年 SeanXuCn. All rights reserved.
//


#import "XYSynchronizer.h"
#import "XYAsynchronousManager.h"
#import <pthread.h>

@interface XYSynchronizer()
@property (nonatomic, copy)NSString *identifier;
@property (nonatomic, weak)id<XYSynchronizerDelegate> delegate;
@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) BOOL doneOnMainThread;
@property (nonatomic, copy)XYAsynchronousPregress   progressBlock;
@property (nonatomic, copy)XYAsynchronousDone       doneBlock;
@end

@implementation XYSynchronizer
{
    pthread_mutex_t mutex;
}
- (instancetype)initWithIdentifier:(nonnull NSString *)identifier
                        totalCount:(NSUInteger )totalCount
                          delegate:(nonnull id<XYSynchronizerDelegate>)delegate
                     progressBlock:(nullable XYAsynchronousPregress)progress
                         doneBlock:(nonnull XYAsynchronousDone)done
                  doneOnMainThread:(BOOL)onMineThread{
    if (self = [super init]) {
        
        _identifier     = [identifier copy];
        _count          = 0;
        _totalCount     = totalCount;
        _delegate       = delegate;
        _progressBlock  = progress;
        _doneBlock      = done;
        pthread_mutex_init(&mutex, NULL);
        _doneOnMainThread     = onMineThread;
        
    }
    return self;
}

- (void)dealloc{
    pthread_mutex_destroy(&mutex);
}

- (void)xy_synchronizeOneStep{
    pthread_mutex_lock(&mutex);
    _count++;
    pthread_mutex_unlock(&mutex);
    if (_count == _totalCount) {
        if (self.doneBlock) {
            if (_doneOnMainThread == YES) {
                __weak __typeof(self)weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    strongSelf.doneBlock();
                });
            }else{
                self.doneBlock();
            }
            if ([_delegate respondsToSelector:@selector(XYSynchronizer:didFinishedWithIdentifier:)]) {
                [_delegate XYSynchronizer:self didFinishedWithIdentifier:_identifier];
            }
        }
    }else{
        if (self.progressBlock != nil) {
            self.progressBlock(_count, _totalCount);
        }
    }
}

@end

