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

@interface MVRViewController ()

@end

@implementation MVRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //Create the Circular Slider
    TBCircularSlider *slider = [[MVRCircularInfiniteSlider alloc]initWithFrame:CGRectMake(0, 60, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
    
    //Define Target-Action behaviour
    [slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:slider];
    
}

//Called when Circular slider value changes
-(void)newValue:(id)sender{
    TBCircularSlider *slider = (TBCircularSlider*)sender;
    NSLog(@"Slider Value %d",slider.angle);
}


@end
