//
//  DCTPullToRefreshController.m
//  Tweetopolis
//
//  Created by Daniel Tull on 11.01.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTPullToRefreshController.h"

@interface DCTPullToRefreshController ()
@property (nonatomic, assign) DCTPullToRefreshControllerState state;
@property (nonatomic, assign) CGFloat pulledValue;
- (void)dctInternal_addRefreshView;
- (void)dctInternal_removeRefreshView;
- (void)dctInternal_addRefreshingView;
- (void)dctInternal_removeRefreshingView;
@end

@implementation DCTPullToRefreshController
@synthesize delegate;
@synthesize state;
@synthesize pulledValue;
@synthesize scrollView;
@synthesize refreshView;
@synthesize refreshingView;
@synthesize placement;

- (void)setScrollView:(UIScrollView *)sv {
	scrollView = sv;
	if (self.refreshView) [self dctInternal_addRefreshView];
}

- (void)setPlacement:(DCTPullToRefreshPlacement)newPlacement {
	placement = newPlacement;
	
	if ([self.refreshView respondsToSelector:@selector(setPlacement:)])
		self.refreshView.placement = placement;
	
	if (self.state == DCTPullToRefreshControllerStateIdle) {
		[self dctInternal_removeRefreshView];
		[self dctInternal_addRefreshView];
	}
}

- (void)setRefreshView:(UIView<DCTPullToRefreshControllerRefreshView> *)rv {
	refreshView = rv;
	
	if ([refreshView respondsToSelector:@selector(setPlacement:)])
		refreshView.placement = placement;
	
	if (self.scrollView) [self dctInternal_addRefreshView];
}

- (void)dealloc {
	dct_nil(delegate);
}

- (void)setPulledValue:(CGFloat)newPulledValue {
	
	if (pulledValue == newPulledValue) return;
	
	pulledValue = newPulledValue;
	
	if (self.state == DCTPullToRefreshControllerStateIdle && pulledValue > 0.0f)
		self.state = DCTPullToRefreshControllerStatePulled;
		
	[self.refreshView pullToRefreshController:self changedPulledValue:pulledValue];	
}

- (void)setState:(DCTPullToRefreshControllerState)newState {
	
	if (state == newState) return;
	
	if (newState == DCTPullToRefreshControllerStateRefreshing) {
		[self dctInternal_removeRefreshView];
		[self dctInternal_addRefreshingView];

	} else if (state == DCTPullToRefreshControllerStateRefreshing) {
		[self dctInternal_removeRefreshingView];
		[self dctInternal_addRefreshView];
	}
	
	state = newState;
	
	if ([self.delegate respondsToSelector:@selector(pullToRefreshController:didChangeToState:)])
		[self.delegate pullToRefreshController:self didChangeToState:state];
}

- (void)startRefreshing {
	self.state = DCTPullToRefreshControllerStateRefreshing;
}

- (void)stopRefreshing {
	self.state = DCTPullToRefreshControllerStateIdle;
}

#pragma mark - UIScrollViewDelagate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat distanceRequired = -self.refreshView.bounds.size.height;
	CGFloat distanceMoved = self.scrollView.contentOffset.y;
	
	if (self.placement == DCTPullToRefreshPlacementBottom)
		distanceMoved = self.scrollView.contentSize.height - self.scrollView.bounds.size.height - self.scrollView.contentOffset.y;
	
	self.pulledValue = distanceMoved/distanceRequired;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.pulledValue > 1.0f)
		self.state = DCTPullToRefreshControllerStateRefreshing;
		
	else if (self.pulledValue > 0.0f)
		self.state = DCTPullToRefreshControllerStateIdle;
}

#pragma mark - Internal

- (void)dctInternal_addRefreshView {
	CGRect newFrame = self.refreshView.frame;
	newFrame.size.width = self.scrollView.bounds.size.width;
	
	if (self.placement == DCTPullToRefreshPlacementTop)
		newFrame.origin.y = -newFrame.size.height;
	else
		newFrame.origin.y = self.scrollView.contentSize.height;
	
	self.refreshView.frame = newFrame;
	self.refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.scrollView addSubview:self.refreshView];
}

- (void)dctInternal_removeRefreshView {
	[self.refreshView removeFromSuperview];
}

- (void)dctInternal_addRefreshingView {
	CGRect frame = self.refreshingView.bounds;
	frame.size.width = self.scrollView.bounds.size.width;
	UIEdgeInsets insets = self.scrollView.contentInset;
	
	if (self.placement == DCTPullToRefreshPlacementTop) {
		frame.origin.y = -frame.size.height;
		insets.top += frame.size.height;
	} else {
		frame.origin.y = self.scrollView.contentSize.height;
		insets.bottom += frame.size.height;
	}
		
	self.refreshingView.frame = frame;
	[self.scrollView addSubview:self.refreshingView];
	
	[UIView animateWithDuration:1.0f/3.0f animations:^{
		self.scrollView.contentInset = insets;
	}];	
}

- (void)dctInternal_removeRefreshingView {
	CGRect frame = self.refreshingView.bounds;
	UIEdgeInsets insets = self.scrollView.contentInset;
	
	if (self.placement == DCTPullToRefreshPlacementTop)
		insets.top -= frame.size.height;
	else
		insets.bottom -= frame.size.height;
	
	[UIView animateWithDuration:1.0f/3.0f animations:^{
		self.scrollView.contentInset = insets;
	} completion:^(BOOL finished) {
		[self.refreshingView removeFromSuperview];
	}];
}

@end
