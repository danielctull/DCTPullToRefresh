//
//  DCTPullToRefreshController.h
//  Tweetopolis
//
//  Created by Daniel Tull on 11.01.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dct_weak.h"

enum {
    DCTPullToRefreshStateIdle = 0,
    DCTPullToRefreshStatePulling,
	DCTPullToRefreshStatePulled,
    DCTPullToRefreshStateRefreshing
} typedef DCTPullToRefreshState;

enum {
	DCTPullToRefreshPlacementTop = 0,
	DCTPullToRefreshPlacementBottom
} typedef DCTPullToRefreshPlacement;

@protocol DCTPullToRefreshControllerDelegate;
@protocol DCTPullToRefreshControllerRefreshView;



@interface DCTPullToRefreshController : NSObject

@property (nonatomic, dct_weak) IBOutlet id<DCTPullToRefreshControllerDelegate> delegate;

@property (nonatomic, readonly) DCTPullToRefreshState state;
@property (nonatomic, readonly) CGFloat pulledValue;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView<DCTPullToRefreshControllerRefreshView> *refreshView;
@property (nonatomic, strong) IBOutlet UIView *refreshingView;
@property (nonatomic, assign) DCTPullToRefreshPlacement placement;

- (void)startRefreshing;
- (void)stopRefreshing;

@end



@protocol DCTPullToRefreshControllerRefreshView <NSObject>
- (void)pullToRefreshControllerDidChangePulledValue:(DCTPullToRefreshController *)controller;
@end



@protocol DCTPullToRefreshControllerDelegate <NSObject>
- (void)pullToRefreshControllerDidChangeState:(DCTPullToRefreshController *)controller;
@end
