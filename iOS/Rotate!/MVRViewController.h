//
//  MVRViewController.h
//  Rotate!
//
//  Created by Movellas on 4/21/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MVRCircularInfiniteSlider;

@interface MVRViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *sliderContainer;

@property (strong, nonatomic) MVRCircularInfiniteSlider *circularSlider;

@end
