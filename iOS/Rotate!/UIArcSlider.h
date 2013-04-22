//
//  UIArcSlider.h
//  Rotate!
//
//  Created by Movellas on 4/22/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, UISliderStyle) {
    UISliderStyleLine,
    UISliderStyleArc
};
@interface UIArcSlider : UIControl

@property (nonatomic, assign) UISliderStyle sliderStyle;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;

float translateValueFromSourceIntervalToDestinationInterval(float sourceValue,
                                                            float sourceIntervalMinimum,
                                                            float sourceIntervalMaximum,
                                                            float destinationIntervalMinimum,
                                                            float destinationIntervalMaximum);
float translateValueToPoint(float value, float xStart, float maximum, float width);
float translatePointToValue(float point, float xStart, float maximum, float width);
CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2);

@end
