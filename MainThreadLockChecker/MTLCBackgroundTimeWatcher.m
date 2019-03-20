//
//  MTLCBackgroundTimeWatcher.m
//  MainThreadLockChecker
//
//  Created by Arpit Panda on 18/03/19.
//  Copyright © 2019 Arpit Panda. All rights reserved.
//

#import "MTLCBackgroundTimeWatcher.h"
#import "MTLCPeriodicTask.h"
#import "UIKit/UIKit.h"

@interface MTLCBackgroundTimeWatcher()

@property (nonatomic) NSTimeInterval criticalTimeSeconds;
@property (nonatomic) NSTimeInterval significantChangeThreshold;
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) NSTimeInterval deadlockThresholdSeconds;
@property (nonatomic) MTLCPeriodicTask *backgroundWatchTimer;
@property (nonatomic) NSNumber *currentBackgroundTime;
@property (nonatomic) NSDate *lastUpdatedDate;
@property (nonatomic) NSDate *startDate;

@property (nonatomic) MTLCPeriodicTask *deadlockTimer;
@property (nonatomic) int deadlockCheckCount;
@end

@implementation MTLCBackgroundTimeWatcher

- (instancetype)initWithCheckInterval:(NSTimeInterval)interval
                  andCriticalTimeSecs:(NSTimeInterval)criticalTimeSeconds
           significantChangeThreshold:(NSTimeInterval)significantChangeThreshold {
    self = [super init];
    if (self) {
        _criticalTimeSeconds = criticalTimeSeconds;
        _significantChangeThreshold = significantChangeThreshold;
        _interval = interval;
        _deadlockThresholdSeconds = 10;
    }
    return self;
}

- (void)startBackgroundTimeMonitoring {
    @synchronized(self) {
        if (self.backgroundWatchTimer) {
            // Already monitoring
            return;
        }
        self.startDate = [NSDate date];
        self.deadlockCheckCount = 0;
        if ([NSThread isMainThread]) {
            self.currentBackgroundTime =
            @([UIApplication sharedApplication].backgroundTimeRemaining);
            self.lastUpdatedDate = [NSDate date];
        }
        __weak MTLCBackgroundTimeWatcher *weakself = self;
        self.backgroundWatchTimer =
        [MTLCPeriodicTask
         scheduleBlock:^(MTLCPeriodicTask *task) {
             MTLCBackgroundTimeWatcher *strongself = weakself;
             if (!strongself) {
                 return;
             }
             [strongself checkBackgroundTime];
         } withPeriodSeconds:self.interval
         onQueue:dispatch_get_main_queue() afterDelaySeconds:0];
    }
}

- (void)stopBackgroundTimeMonitoring {
    @synchronized(self) {
        [self.backgroundWatchTimer cancel];
        self.backgroundWatchTimer = nil;
    }
}

- (void)startMainThreadLockChecker:(NSTimeInterval)deadlockThresholdSeconds
                      alertHandler:(void (^) (void))alertHandler {
        @synchronized(self) {
            self.deadlockThresholdSeconds = deadlockThresholdSeconds;
            if (self.deadlockTimer) {
                // Already monitoring
                return;
            }
            __weak MTLCBackgroundTimeWatcher *weakself = self;
            self.deadlockTimer =
            [MTLCPeriodicTask
             scheduleBlock:^(MTLCPeriodicTask *task) {
                 MTLCBackgroundTimeWatcher *strongself = weakself;
                 if (!strongself) {
                     return;
                 }
                 [strongself checkDeadlock:alertHandler];
             } withPeriodSeconds:self.interval
             onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
             afterDelaySeconds:0];
        }
}

- (void)stopMainThreadLockChecker {
    @synchronized(self) {
        [self.deadlockTimer cancel];
        self.deadlockTimer = nil;
        self.deadlockCheckCount = 0;
    }
}

- (void)checkDeadlock:(void (^)(void))alertHandler {
    @synchronized(self) {
        self.deadlockCheckCount += 1;
        if (self.deadlockCheckCount > self.deadlockThresholdSeconds) {
            //            NSDate *lastDeadlockResetDate = self.lastUpdatedDate ? self.lastUpdatedDate:self.startDate;
            //            NSDictionary *logDict = @{@"type": @"MainThreadBlocked",
            //                                      @"blockDuration": @(-[lastDeadlockResetDate timeIntervalSinceNow])};
            alertHandler();
            self.deadlockCheckCount = 0;
        }
    }
}
- (void)checkDeadlock {
    @synchronized(self) {
        self.deadlockCheckCount += 1;
        if (self.deadlockCheckCount > self.deadlockThresholdSeconds) {
//            NSDate *lastDeadlockResetDate = self.lastUpdatedDate ? self.lastUpdatedDate:self.startDate;
//            NSDictionary *logDict = @{@"type": @"MainThreadBlocked",
//                                      @"blockDuration": @(-[lastDeadlockResetDate timeIntervalSinceNow])};
            self.deadlockCheckCount = 0;
        }
    }
}

- (void)checkBackgroundTime {
    @synchronized(self) {
        self.deadlockCheckCount = 0;
        NSTimeInterval backgroundTimeRemaining =
        [UIApplication sharedApplication].backgroundTimeRemaining;

        NSNumber *lastBackgroundTime = self.currentBackgroundTime;
        self.currentBackgroundTime = @(backgroundTimeRemaining);
        self.lastUpdatedDate = [NSDate date];
        if (backgroundTimeRemaining <= self.criticalTimeSeconds &&
            (!lastBackgroundTime || lastBackgroundTime.doubleValue > self.criticalTimeSeconds)) {
            NSDictionary *logDict = @{@"type": @"QuantumCritical",
                                      @"timeRemaining": @(backgroundTimeRemaining)};
            NSLog(@"%@", logDict);

//            // Dispatch the delegate as this doesn't need to be delivered immediately
//            // and a slight delay is ok here.
//            // Also, dispatching delegate keeps this class deadlock safe
//            __weak MTLCBackgroundTimeWatcher *weakself = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                MTLCBackgroundTimeWatcher *strongself = weakself;
//                if (strongself.delegate) {
//                    [strongself.delegate backgroundTimeWatcher:strongself
//                                         criticalTimeRemaining:backgroundTimeRemaining];
//                }
//            });
        }
        else if (lastBackgroundTime &&
                 ABS(lastBackgroundTime.doubleValue - backgroundTimeRemaining) >
                 self.significantChangeThreshold) {
            NSDictionary *logDict = @{@"type": @"QuantumSignificantChange",
                                      @"timeDiff": @(backgroundTimeRemaining -
                                          lastBackgroundTime.doubleValue),
                                      @"timeRemaining": @(backgroundTimeRemaining)};
            NSLog(@"%@", logDict);

            // Dispatch the delegate as this doesn't need to be delivered immediately
            // and a slight delay is ok here.
            // Also, dispatching delegate keeps this class deadlock safe
//            __weak MTLCBackgroundTimeWatcher *weakself = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                MTLCBackgroundTimeWatcher *strongself = weakself;
//                if (strongself.delegate) {
//                    [strongself.delegate backgroundTimeWatcher:strongself
//                                     significantTimeChangeFrom:lastBackgroundTime.doubleValue
//                                                        toTime:backgroundTimeRemaining];
//                }
//            });
        }
    }
}

- (NSTimeInterval)backgroundTimeRemaining {
    @synchronized(self) {
        if (!self.lastUpdatedDate ||
            [self.lastUpdatedDate timeIntervalSinceNow] < -10 /* Too Old */) {
            return -1; // Unknown
        }
        return (self.currentBackgroundTime.doubleValue -
                [self.lastUpdatedDate timeIntervalSinceNow]);
    }
}

@end


