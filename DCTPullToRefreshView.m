//
//  DCTPullToRefreshView.m
//  Tweetopolis
//
//  Created by Daniel Tull on 11.01.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTPullToRefreshView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DCTPullToRefreshView
@synthesize rotatingView;

- (void)pullToRefreshController:(DCTPullToRefreshController *)controller changedPulledValue:(CGFloat)pulledValue {
	
	if (pulledValue < 0.5)
		pulledValue = 0.0f;
	else if (pulledValue > 1.0f)
		pulledValue = 1.0f;
	else
		pulledValue = 2*(pulledValue-0.5f);
	
	self.rotatingView.layer.transform = CATransform3DMakeRotation(M_PI*pulledValue, 0.0f, 0.0f, 1.0f);
}

@end
