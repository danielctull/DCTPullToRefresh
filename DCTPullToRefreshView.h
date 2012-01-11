//
//  DCTPullToRefreshView.h
//  Tweetopolis
//
//  Created by Daniel Tull on 11.01.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dct_weak.h"
#import "DCTPullToRefreshController.h"

@interface DCTPullToRefreshView : UIView <DCTPullToRefreshControllerRefreshView>
@property (nonatomic, dct_weak) IBOutlet UIView *rotatingView;
@end
