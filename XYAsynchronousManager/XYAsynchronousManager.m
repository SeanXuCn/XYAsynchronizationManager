//
//  XYAsynchronousManager.m
//  XYAsynchronousManager
//
//  Created by xuyang on 2017/3/29.
//  Copyright © 2017年 SeanXuCn. All rights reserved.
//


#import "XYAsynchronousManager.h"
#import "XYSynchronizer.h"

static dispatch_queue_t XY_ASYNCHRONOUS_MANAGER_SERIAL_QUEUE(){
    static dispatch_queue_t _XY_ASYNCHRONOUS_MANAGER_SERIAL_QUEUE;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _XY_ASYNCHRONOUS_MANAGER_SERIAL_QUEUE = dispatch_queue_create("com.xy.asynchronous.manager.serial.queue", DISPATCH_QUEUE_SERIAL);
    });
    return _XY_ASYNCHRONOUS_MANAGER_SERIAL_QUEUE;
}

@interface XYAsynchronousManager()<XYSynchronizerDelegate>
@property (nonatomic, copy)NSMutableDictionary *Synchronizers;
@end

@implementation XYAsynchronousManager

- (NSString *)version{
    return @"1.0.0";
}
#pragma mark - initialize
+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static XYAsynchronousManager *instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] initPrivately];
    });
    return instance;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"XYAM: Manager init error" reason:@"Use the designated initializer to init." userInfo:nil];
    return [self initPrivately];
}

- (id)initPrivately{
    if ((self = [super init])) {
        _Synchronizers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - actions
- (void)xy_synchronizeWithIdentifier:(nonnull NSString *)identifier
                          totalCount:(NSUInteger )totalCount
                       progressBlock:(nullable XYAsynchronousPregress)progress
                           doneBlock:(nonnull XYAsynchronousDone)doneBlock
                    doneOnMineThread:(BOOL)onMineThread{
    NSAssert(identifier != nil, @"XYAM: Identifier can't be nil");
    NSAssert(totalCount > 0 , @"XYAM: Totalcount must greater than 0");
    NSAssert(totalCount < NSUIntegerMax , @"XYAM: Totalcount must less or equal than NSUIntegerMax");
    
    if ([self.Synchronizers objectForKey:identifier] != nil) {
        XYAM_Log(@"XYAM: Identifier has already existed please ");
    }
    XYSynchronizer *synchronizer =  [[XYSynchronizer alloc] initWithIdentifier:identifier totalCount:totalCount delegate:self progressBlock:progress doneBlock:doneBlock doneOnMainThread:onMineThread];
    
    [self.Synchronizers setObject:synchronizer forKey:identifier];
}


- (void)xy_synchronizeWithIdentifier:(nonnull NSString *)identifier
                          totalCount:(NSUInteger )totalCount
                       progressBlock:(nullable XYAsynchronousPregress)progress
                           doneBlock:(nonnull XYAsynchronousDone)doneBlock{
    [self xy_synchronizeWithIdentifier:identifier totalCount:totalCount progressBlock:progress doneBlock:doneBlock doneOnMineThread:NO];
}

- (void)xy_synchronizeWithIdentifier:(nonnull NSString *)identifier
                          totalCount:(NSUInteger )totalCount
                           doneBlock:(nonnull XYAsynchronousDone)doneBlock{
    [self xy_synchronizeWithIdentifier:identifier totalCount:totalCount progressBlock:nil doneBlock:doneBlock doneOnMineThread:NO];
}

- (void)xy_synchronizeOneStepByIdentifier:(nonnull NSString *)identifier{
    NSAssert(identifier != nil, @"XYAM: Identifier can not be nil");
    XYSynchronizer *synchronizer = [_Synchronizers objectForKey:identifier];
    if (nil == synchronizer) {
        XYAM_Log(@"XYAM: Synchronizer not found");
        return;
    }
    [synchronizer xy_synchronizeOneStep];
}

- (void)xy_destorySynchronizerByIdentifier:(nonnull NSString *)identifier{
    NSAssert(identifier != nil, @"XYAM: Identifier can not be nil");
    __weak __typeof(self)weakSelf = self;
    dispatch_async(XY_ASYNCHRONOUS_MANAGER_SERIAL_QUEUE(), ^{
        __strong __typeof(weakSelf)StrongSelf = weakSelf;
        [StrongSelf.Synchronizers removeObjectForKey:identifier];
    });
}
#pragma mark - SynchronizerDelegate
- (void)XYSynchronizer:(XYSynchronizer *)synchronizer didFinishedWithIdentifier:(NSString *)identifier{
    [self xy_destorySynchronizerByIdentifier:identifier];
}

@end
