//
//  MTLCThreadMonitor.m
//  MainThreadLockChecker
//
//  Created by Arpit Panda on 18/03/19.
//  Copyright © 2019 Arpit Panda. All rights reserved.
//

#import "MTLCThreadMonitor.h"
#import "MTLCBackgroundTimeWatcher.h"

@interface MTLCThreadMonitor()
@property (nonatomic) MTLCBackgroundTimeWatcher *backgroundTimeWatcher;
@end

__strong static MTLCThreadMonitor *_sharedInstance = nil;
@implementation MTLCThreadMonitor

- (instancetype)init {
    self = [super init];
    _backgroundTimeWatcher = [[MTLCBackgroundTimeWatcher alloc]
                              initWithCheckInterval:1
                              andCriticalTimeSecs:20
                              significantChangeThreshold:10];
    return self;
}

+ (instancetype)sharedInstance {
    if (nil == _sharedInstance) {
        @synchronized([MTLCThreadMonitor class]) {
            if (nil == _sharedInstance) {
                _sharedInstance = [[MTLCThreadMonitor alloc] init];
                _sharedInstance.backgroundTimeWatcher =
                [[MTLCBackgroundTimeWatcher alloc] initWithCheckInterval:1
                                                     andCriticalTimeSecs:20
                                              significantChangeThreshold:10];
            }
        }
    }
    return _sharedInstance;
}

- (void)startMonitoringMainThread:(NSInteger)blockTimeThreshold
                 withAlertHandler:(void (^)(void))alertHandler {
    [[MTLCThreadMonitor sharedInstance].backgroundTimeWatcher startMainThreadLockChecker:blockTimeThreshold
                                                                            alertHandler:^{
                                                                                alertHandler();
                                                                            }];
}

@end
