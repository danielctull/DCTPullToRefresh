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
    DCTPullToRefreshStatePulled,
    DCTPullToRefreshStateRefreshing,
} typedef DCTPullToRefreshState;

enum {
	DCTPullToRefreshPlacementTop = 0,
	DCTPullToRefreshPlacementBottom
} typedef DCTPullToRefreshPlacement;

@protocol DCTPullToRefreshControllerDelegate;
@protocol DCTPullToRefreshControllerRefreshView;



@interface DCTPullToRefreshController : NSObject <UIScrollViewDelegate>

@property (nonatomic, dct_weak) IBOutlet id<DCTPullToRefreshControllerDelegate> delegate;

@property (nonatomic, readonly) DCTPullToRefreshState state;
@property (nonatomic, readonly) CGFloat pulledValue;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView<DCTPullToRefreshControllerRefreshView> *refreshView;
@property (nonatomic, strong) IBOutlet UIView *refreshingView;
@property (nonatomic, assign) DCTPullToRefreshPlacement placement;

- (void)startRefreshing;
- (void)stopRefreshing;

// UIScrollViewDelegate methods. If this class isn't the delegate of it's scrollView property (for example when attached to a table view), call these methods from whatever is the scroll view's delegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate;

@end



@protocol DCTPullToRefreshControllerRefreshView <NSObject>
- (void)pullToRefreshController:(DCTPullToRefreshController *)controller changedPulledValue:(CGFloat)pulledValue;

@optional
@property (nonatomic, assign) DCTPullToRefreshPlacement placement;
@end



@protocol DCTPullToRefreshControllerDelegate <NSObject>
- (void)pullToRefreshControllerDidChangeState:(DCTPullToRefreshController *)controller;
@end
