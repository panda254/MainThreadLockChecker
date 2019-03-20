//
//  MTLCPeriodicTask.h
//  MainThreadLockChecker
//
//  Created by Arpit Panda on 18/03/19.
//  Copyright © 2019 Arpit Panda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTLCPeriodicTask;
typedef void(^TaskBlock)(MTLCPeriodicTask *);

@interface MTLCPeriodicTask : NSObject

// Returns the time at which this timer was first created
@property (nonatomic, readonly) NSDate *creationTime;

// Returns the current interval between consecutive executions of the tasks.
@property (nonatomic, readonly) NSTimeInterval period;

// Returns the delay that was set when timer was first created
@property (nonatomic, readonly) NSTimeInterval initialDelay;

/**
 * Use this method to setup a periodic task which runs on the specified queue.
 *
 * @param block     : The block which would be executed periodically. The block should
 *                    ideally not contain strong references within.
 * @param period    : The period in seconds between consecutive task executions.
 * @param queue     : The queue on which to run the task. Can be the main
 *                    queue or a background queue.
 * @param delay     : The initial delay in seconds before first execution of 'block'
 *
 */
+ (MTLCPeriodicTask *)scheduleBlock:(TaskBlock)block
                 withPeriodSeconds:(NSTimeInterval)period
                           onQueue:(dispatch_queue_t)queue
                 afterDelaySeconds:(NSTimeInterval)delay;

/**
 * Use this method to setup a one-time task which runs on the specified queue.
 *
 * @param block     : The block which would be executed. The block should
 *                    ideally not contain strong references within.
 * @param queue     : The queue on which to run the task. Can be the main
 *                    queue or a background queue.
 * @param delay     : The delay after which 'block' is executed.
 *
 */
+ (MTLCPeriodicTask *)scheduleBlock:(TaskBlock)block
                           onQueue:(dispatch_queue_t)queue
                 afterDelaySeconds:(NSTimeInterval)delay;

// Asynchronously cancels the periodic task. If a task is currently executing, it is
// allowed to complete. Once cancelled, a task releases its internal references
// and thus cannot be rerun.
- (void)cancel;

// Returns YES if task is cancelled, NO otherwise
- (BOOL)isCancelled;

// Returns next execution date based on creationTime, initialDelay and period
- (NSDate *)nextExecutionDate;

@end
