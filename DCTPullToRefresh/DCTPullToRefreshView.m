//
//  DCTPullToRefreshView.m
//  Tweetopolis
//
//  Created by Daniel Tull on 11.01.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTPullToRefreshView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DCTPullToRefreshView {
	CGFloat _lastPulledValue;
}

- (void)dealloc {
	_rotatingView = nil;
}

- (void)pullToRefreshControllerDidChangePulledValue:(DCTPullToRefreshController *)controller {
	
	CGFloat pulledValue = controller.pulledValue;
	
	if (pulledValue < 0.0f && _lastPulledValue < 0.0f) return;
	if (pulledValue > 1.0f && _lastPulledValue > 1.0f) return;
	
	_lastPulledValue = pulledValue;
	
	if (pulledValue < 0.5)
		pulledValue = 0.0f;
	else if (pulledValue > 1.0f)
		pulledValue = 1.0f;
	else
		pulledValue = 2*(pulledValue-0.5f);
	
	if (controller.placement == DCTPullToRefreshPlacementBottom)
		pulledValue += 1.0f;
	
	self.rotatingView.layer.transform = CATransform3DMakeRotation(M_PI*pulledValue, 0.0f, 0.0f, 1.0f);
}

@end
