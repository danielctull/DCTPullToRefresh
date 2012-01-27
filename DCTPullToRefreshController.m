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


- (void)setScrollView:(UIScrollView *)sv {
	scrollView = sv;
	if (self.refreshView) [self dctInternal_addRefreshView];
}

- (void)setRefreshView:(UIView<DCTPullToRefreshControllerRefreshView> *)rv {
	refreshView = rv;
	if (self.scrollView) [self dctInternal_addRefreshView];
}

- (void)dealloc {
	dct_nil(delegate);
}

- (void)setPulledValue:(CGFloat)newPulledValue {
	
	if (pulledValue == newPulledValue) return;
	
	pulledValue = newPulledValue;
		
	if (self.state == DCTPullToRefreshControllerStateUp && pulledValue > 0.0f)
		self.state = DCTPullToRefreshControllerStatePulledDown;
		
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
	self.state = DCTPullToRefreshControllerStateUp;
}

#pragma mark - UIScrollViewDelagate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	CGFloat distanceRequired = -self.refreshView.bounds.size.height;
	CGFloat distanceMoved = self.scrollView.contentOffset.y;
	self.pulledValue = distanceMoved/distanceRequired;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.pulledValue > 1.0f)
		self.state = DCTPullToRefreshControllerStateRefreshing;
		
	else if (self.pulledValue > 0.0f)
		self.state = DCTPullToRefreshControllerStateUp;
}

#pragma mark - Internal

- (void)dctInternal_addRefreshView {
	CGRect newFrame = self.refreshView.frame;
	newFrame.size.width = self.scrollView.bounds.size.width;
	newFrame.origin.y = -newFrame.size.height;
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
	frame.origin.y = -frame.size.height;
	UIEdgeInsets insets = self.scrollView.contentInset;
	insets.top += frame.size.height;
	self.refreshingView.frame = frame;
	[self.scrollView addSubview:self.refreshingView];
	
	[UIView animateWithDuration:1.0f/3.0f animations:^{
		self.scrollView.contentInset = insets;
	}];	
}

- (void)dctInternal_removeRefreshingView {
	CGRect frame = self.refreshingView.bounds;
	UIEdgeInsets insets = self.scrollView.contentInset;
	insets.top -= frame.size.height;
	[UIView animateWithDuration:1.0f/3.0f animations:^{
		self.scrollView.contentInset = insets;
	} completion:^(BOOL finished) {
		[self.refreshingView removeFromSuperview];
	}];
}

@end
