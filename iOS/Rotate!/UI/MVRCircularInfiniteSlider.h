//
//  MVRCircularInfiniteSlider.h
//  Rotate!
//
//  Created by Movellas on 4/21/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import "TBCircularSlider.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MVRCircularInfiniteSlider : TBCircularSlider

@property (nonatomic, readonly, assign) CGFloat currentAccumulationValue;

- (void)reset;

@end
