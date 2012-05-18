//
//  DCTPullToRefreshController.m
//  Tweetopolis
//
//  Created by Daniel Tull on 11.01.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTPullToRefreshController.h"

void* DCTPullToRefreshControllerContext = &DCTPullToRefreshControllerContext;

@interface DCTPullToRefreshController ()
@property (nonatomic, assign) DCTPullToRefreshState state;
@property (nonatomic, assign) CGFloat pulledValue;
- (void)dctInternal_addRefreshView;
- (void)dctInternal_removeRefreshView;
- (void)dctInternal_addRefreshingView;
- (void)dctInternal_removeRefreshingViewCompletion:(void(^)())completion;
- (void)dctInternal_setupRefreshPlacement;
@end

@implementation DCTPullToRefreshController
@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize pulledValue = _pulledValue;
@synthesize scrollView = _scrollView;
@synthesize refreshView = _refreshView;
@synthesize refreshingView = _refreshingView;
@synthesize placement = _placement;

- (void)setScrollView:(UIScrollView *)sv {
	[_scrollView removeObserver:self forKeyPath:@"contentSize" context:DCTPullToRefreshControllerContext];
	_scrollView = sv;
	[_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:DCTPullToRefreshControllerContext];
	if (self.refreshView) [self dctInternal_addRefreshView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	if (context != DCTPullToRefreshControllerContext)
		return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	if (self.placement == DCTPullToRefreshPlacementBottom)
		[self dctInternal_setupRefreshPlacement];
}

- (void)setPlacement:(DCTPullToRefreshPlacement)newPlacement {
	
	if (_placement == newPlacement) return;
	
	_placement = newPlacement;
	[self dctInternal_setupRefreshPlacement];
}

- (void)setRefreshView:(UIView<DCTPullToRefreshControllerRefreshView> *)rv {
	_refreshView = rv;
	if (self.scrollView) [self dctInternal_addRefreshView];
}

- (void)dealloc {
	[_scrollView removeObserver:self forKeyPath:@"contentSize" context:DCTPullToRefreshControllerContext];
	dct_nil(delegate);
}

- (void)setPulledValue:(CGFloat)newPulledValue {
	
	if (_pulledValue == newPulledValue) return;
	
	_pulledValue = newPulledValue;
	
	if (self.state == DCTPullToRefreshStateIdle && _pulledValue > 0.0f)
		self.state = DCTPullToRefreshStatePulled;
		
	[self.refreshView pullToRefreshControllerDidChangePulledValue:self];	
}

- (void)setState:(DCTPullToRefreshState)newState {
	
	if (_state == newState) return;
	
	if (newState == DCTPullToRefreshStateRefreshing) {
		[self dctInternal_removeRefreshView];
		[self dctInternal_addRefreshingView];

	} else if (_state == DCTPullToRefreshStateRefreshing) {
		[self dctInternal_removeRefreshingViewCompletion:^{
			[self dctInternal_addRefreshView];
		}];
	}
	
	_state = newState;
	
	if ([self.delegate respondsToSelector:@selector(pullToRefreshControllerDidChangeState:)])
		[self.delegate pullToRefreshControllerDidChangeState:self];
}

- (void)startRefreshing {
	self.state = DCTPullToRefreshStateRefreshing;
}

- (void)stopRefreshing {
	self.state = DCTPullToRefreshStateIdle;
}

#pragma mark - UIScrollViewDelagate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat distanceRequired = -self.refreshView.bounds.size.height;
	CGFloat distanceMoved = self.scrollView.contentOffset.y;
	
	if (self.placement == DCTPullToRefreshPlacementBottom) {
		
		if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height)
			distanceMoved = -self.scrollView.contentOffset.y;
		else 
			distanceMoved = self.scrollView.contentSize.height - self.scrollView.bounds.size.height - self.scrollView.contentOffset.y;
	}
	
	self.pulledValue = distanceMoved/distanceRequired;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.pulledValue > 1.0f)
		self.state = DCTPullToRefreshStateRefreshing;
		
	else if (self.pulledValue > 0.0f)
		self.state = DCTPullToRefreshStateIdle;
}

#pragma mark - Internal

- (void)dctInternal_addRefreshView {
	CGRect newFrame = self.refreshView.frame;
	newFrame.size.width = self.scrollView.bounds.size.width;
	
	if (self.placement == DCTPullToRefreshPlacementTop)
		newFrame.origin.y = -newFrame.size.height;
	else
		newFrame.origin.y = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
	
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
		frame.origin.y = MAX(self.scrollView.contentSize.height, (self.scrollView.bounds.size.height - frame.size.height));
		insets.bottom += frame.size.height;
	}
		
	self.refreshingView.frame = frame;
	[self.scrollView addSubview:self.refreshingView];
	
	[UIView animateWithDuration:1.0f/3.0f animations:^{
		self.scrollView.contentInset = insets;
	}];	
}

- (void)dctInternal_removeRefreshingViewCompletion:(void(^)())completion {
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
		if (completion != NULL) completion();
	}];
}

- (void)dctInternal_setupRefreshPlacement {
		
	if (self.state == DCTPullToRefreshStateRefreshing) {
		[self dctInternal_removeRefreshingViewCompletion:NULL];
		[self dctInternal_addRefreshingView];	
	} else {
		[self dctInternal_removeRefreshView];
		[self dctInternal_addRefreshView];
	}
}

@end
