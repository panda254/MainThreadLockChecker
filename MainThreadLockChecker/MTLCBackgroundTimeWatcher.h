//
//  MTLCBackgroundTimeWatcher.h
//  MainThreadLockChecker
//
//  Created by Arpit Panda on 18/03/19.
//  Copyright © 2019 Arpit Panda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTLCBackgroundTimeWatcher;
@protocol MTLCBackgroundTimeDelegate

// This is fired only when critical time is remaining
- (void)backgroundTimeWatcher:(MTLCBackgroundTimeWatcher *)watcher
        criticalTimeRemaining:(NSTimeInterval)timeRemaining;
- (void)backgroundTimeWatcher:(MTLCBackgroundTimeWatcher *)watcher
    significantTimeChangeFrom:(NSTimeInterval)fromTime
                       toTime:(NSTimeInterval)toTime;
@end

@interface MTLCBackgroundTimeWatcher : NSObject

- (instancetype)initWithCheckInterval:(NSTimeInterval)interval
                  andCriticalTimeSecs:(NSTimeInterval)criticalTimeSeconds
           significantChangeThreshold:(NSTimeInterval)significantChangeThreshold;

- (NSTimeInterval)backgroundTimeRemaining;

- (void)startBackgroundTimeMonitoring;
- (void)stopBackgroundTimeMonitoring;
- (void)startMainThreadLockChecker:(NSTimeInterval)deadlockThresholdSeconds
                      alertHandler:(void (^) (void))alertHandler;
- (void)stopMainThreadLockChecker;
@end
