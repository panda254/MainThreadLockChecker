//
//  MTLCThreadMonitor.h
//  MainThreadLockChecker
//
//  Created by Arpit Panda on 18/03/19.
//  Copyright © 2019 Arpit Panda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTLCThreadMonitor : NSObject

- (void)startMonitoringMainThread:(NSInteger)blockTimeThreshold
                 withAlertHandler:(void (^)(void))alertHandler;

@end

