//
//  MVRCircularInfiniteSlider.m
//  Rotate!
//
//  Created by Movellas on 4/21/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import "MVRCircularInfiniteSlider.h"

@interface MVRCircularInfiniteSlider ()

@property (nonatomic, assign) NSInteger lastAngle;

@end
@implementation MVRCircularInfiniteSlider

@synthesize currentAccumulationValue = _currentAccumulationValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _textField.adjustsFontSizeToFitWidth = YES;
        _textField.minimumFontSize = 7;
        
        _currentAccumulationValue = 0;
        _lastAngle = self.angle;
        _textField.text =  [NSString stringWithFormat:@"%.f", self.currentAccumulationValue];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)reset
{
    _currentAccumulationValue = 0;
    self.lastAngle = self.angle;

    [self setNeedsDisplay];
}

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    
    [super movehandle:lastPoint];
    
    //NSLog(@"last %d", self.lastAngle);
    
    CGFloat delta = abs(self.angle - self.lastAngle);
    delta = delta/360.0f*8;
    
    //NSLog(@"delta %f", delta);

    _currentAccumulationValue += delta;
    self.lastAngle = self.angle;
    
    _textField.text =  [NSString stringWithFormat:@"%.f", self.currentAccumulationValue];
    
    //Redraw
    [self setNeedsDisplay];
}

//Use the draw rect to draw the Background, the Circle and the Handle
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /** Draw the Background **/
    
    //Create the path
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI *2, 0);
    
    //Set the stroke color to black
    [[UIColor blackColor]setStroke];
    
    //Define line width and cap
    CGContextSetLineWidth(ctx, TB_BACKGROUND_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //** Draw the circle (using a clipped gradient) **/
    
    /** Create THE MASK Image **/
    UIGraphicsBeginImageContext(CGSizeMake(TB_SLIDER_SIZE,TB_SLIDER_SIZE));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
    CGFloat currentAngle = self.angle;
#warning fix (100 should depend on the rotation)
    if (_currentAccumulationValue >= 100) {
        currentAngle = 360;
    }
    
    CGContextAddArc(imageCtx, self.frame.size.width/2  , self.frame.size.height/2, radius, 0, ToRad(currentAngle), 0);
    [[UIColor redColor]set];
    
    //Use shadow to create the Blur effect
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), self.angle/20, [UIColor blackColor].CGColor);
    
    //define the path
    CGContextSetLineWidth(imageCtx, TB_LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    
    
    /** Clip Context to the mask **/
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    
    
    /** THE GRADIENT **/
    
    CGFloat red = 0, green = 0, blue = 0;
#warning make it proper
    CGFloat maxValue = 100;
    
    if (_currentAccumulationValue == 0) {
        red = 0;
        green = 0.1;
        blue = 0;
    } else {
        red += (_currentAccumulationValue * 0.175),
        green += _currentAccumulationValue * 0.125,
        blue += _currentAccumulationValue * 0.161;
        NSLog(@"PREcomponents: %f %f %f (%f)", red, green, blue, _currentAccumulationValue);
        //normalize between 0..1
        red = (red) / (maxValue);
        green = (green) / (maxValue);
        blue = (blue) / (maxValue);
        
        NSLog(@"components: %f %f %f (%f)", red, green, blue, _currentAccumulationValue);
    }
    
    //list of components
    CGFloat components[8] = {
        red*0.5, green, blue, 1.0,     // Start color - R,G,B,Alpha
        red, green, blue*0.5, 1.0 };   // End color - R,G,B,Alpha
    
//    NSLog(@"components: %f %f %f", red, green, blue);
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(ctx);
    
    
    /** Add some light reflection effects on the background circle**/
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //Draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius+TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius-TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    /** Draw the handle **/
    [super drawTheHandle:ctx];
    
}

@end
