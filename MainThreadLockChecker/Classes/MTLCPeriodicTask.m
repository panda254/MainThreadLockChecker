//
//  MTLCPeriodicTask.m
//  MainThreadLockChecker
//
//  Created by Arpit Panda on 18/03/19.
//  Copyright © 2019 Arpit Panda. All rights reserved.
//

#import "MTLCPeriodicTask.h"

@interface MTLCPeriodicTask ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSDate *creationTime;
@property (nonatomic) NSTimeInterval period;
@property (nonatomic) NSTimeInterval initialDelay;
@property (nonatomic, copy) TaskBlock block;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSDate *lastExecutionDate;
@property (getter=isCancelled) BOOL isCancelled;

- (void)startTask;

@end

@implementation MTLCPeriodicTask

- (id)initWithBlock:(TaskBlock)block
  withPeriodSeconds:(NSTimeInterval)period
            onQueue:(dispatch_queue_t)queue
  afterDelaySeconds:(NSTimeInterval)delay {
    self = [super init];
    if (self) {
        __weak MTLCPeriodicTask *weakSelf = self;
        TaskBlock internalBlock = ^void(MTLCPeriodicTask *task) {
            MTLCPeriodicTask *strongSelf = weakSelf;
            if (strongSelf) {
                @synchronized (strongSelf) {
                    strongSelf.lastExecutionDate = [NSDate date];
                }
                block(task);
            }
        };
        _block = internalBlock;
        _creationTime = [NSDate date];
        _period = period;
        _initialDelay = delay;
        _queue = queue;
        _timer = getDispatchTimer(period, delay, queue, internalBlock, self);
        _isCancelled = NO;
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

//----------------------------------------------------------------------------------------
#pragma mark - public scheduling helpers
//----------------------------------------------------------------------------------------

+ (MTLCPeriodicTask *)scheduleBlock:(TaskBlock)block
                 withPeriodSeconds:(NSTimeInterval)period
                           onQueue:(dispatch_queue_t)queue
                 afterDelaySeconds:(NSTimeInterval)delay {
    MTLCPeriodicTask *task = [[MTLCPeriodicTask alloc]
                             initWithBlock:block
                             withPeriodSeconds:period
                             onQueue:queue
                             afterDelaySeconds:delay];
    [task startTask];
    return task;
}

+ (MTLCPeriodicTask *)scheduleBlock:(TaskBlock)block
                           onQueue:(dispatch_queue_t)queue
                 afterDelaySeconds:(NSTimeInterval)delay {
    TaskBlock oneTimeBlock = ^void(MTLCPeriodicTask *task) {
        block(task);
        [task cancel];
    };
    MTLCPeriodicTask *task = [[MTLCPeriodicTask alloc]
                             initWithBlock:oneTimeBlock
                             withPeriodSeconds:INT_MAX
                             onQueue:queue
                             afterDelaySeconds:delay];
    [task startTask];
    return task;
}

//----------------------------------------------------------------------------------------
#pragma mark - private methods
//----------------------------------------------------------------------------------------

- (void)startTask {
    dispatch_resume(_timer);
}

- (void)cancel {
    @synchronized(self) {
        if (self.isCancelled) {
            return;
        }
        self.isCancelled = YES;
        dispatch_source_cancel(_timer);

        _timer = nil;
        _block = nil;
        _queue = nil;
    }
}

- (NSDate *)nextExecutionDate {
    @synchronized (self) {
        if (self.isCancelled) {
            return nil;
        }

        NSTimeInterval creationTimestamp = _creationTime.timeIntervalSince1970;
        NSTimeInterval nextExecutionTimestamp;
        if (_lastExecutionDate) {
            nextExecutionTimestamp = _lastExecutionDate.timeIntervalSince1970 + _period;
        }
        else {
            nextExecutionTimestamp = creationTimestamp + _initialDelay;
        }
        NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
        if (nextExecutionTimestamp < currentTimestamp) {
            return [NSDate date];
        }
        else {
            return [NSDate dateWithTimeIntervalSince1970:nextExecutionTimestamp];
        }
    }
}

//------------------------------------------------------------------------------
# pragma mark - timer creator helpers
//------------------------------------------------------------------------------

dispatch_source_t getDispatchTimer(NSTimeInterval interval,
                                   NSTimeInterval delay,
                                   dispatch_queue_t queue,
                                   TaskBlock block,
                                   id self) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer,
                                  dispatch_walltime(NULL, delay * NSEC_PER_SEC),
                                  interval * NSEC_PER_SEC,
                                  1 * NSEC_PER_SEC /* leeway */);
        MTLCPeriodicTask __weak *weakSelf = self;
        dispatch_source_set_event_handler(timer, ^{ block(weakSelf); });
    }
    return timer;
}

@end

