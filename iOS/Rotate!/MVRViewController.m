//
//  MVRViewController.m
//  Rotate!
//
//  Created by Movellas on 4/21/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import "MVRViewController.h"
#import "TBCircularSlider.h"
#import "MVRCircularInfiniteSlider.h"
#import "UIArcSlider.h"

@interface MVRViewController ()

@end

@implementation MVRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    //Create the Circular Slider
    _circularSlider = [[MVRCircularInfiniteSlider alloc]initWithFrame:self.sliderContainer.frame];
    
//    id arc = [[UIArcSlider alloc] initWithFrame:self.sliderContainer.frame];
//    [self.sliderContainer addSubview:arc];
    
    //Define Target-Action behaviour
    [_circularSlider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.sliderContainer addSubview:_circularSlider];
    
    
}

//Called when Circular slider value changes
-(void)newValue:(id)sender{
    TBCircularSlider *slider = (TBCircularSlider*)sender;
    //NSLog(@"Slider Value %d",slider.angle);
}


@end
