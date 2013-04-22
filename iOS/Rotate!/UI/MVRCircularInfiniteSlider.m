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
@property (nonatomic, assign) BOOL rotatingClockwise;
@property (nonatomic, assign) CGFloat rotationChangeAngle;

//represent the distance travelled in the opposite direction of the current rotation state
@property (nonatomic, assign) long long distanceInTheOppositeDirection;

@end

// has to be in the interval 1..360
#define kMVRStepsPerCompleteSlide 200

#define kMVRMinDistanceForRotationChange 10

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
        _rotatingClockwise = YES;
        
        self.layer.shouldRasterize = YES;
        self.layer.shadowOpacity = 0.01;
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
    _distanceInTheOppositeDirection = 0;
    self.lastAngle = self.angle;

    [self setNeedsDisplay];
}

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = calculateAngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floorf(currentAngle);
    
    
    //NSLog(@"last %d", self.lastAngle);
    
    CGFloat delta = currentAngle - self.lastAngle;
    BOOL rotationIsChanged = NO;
    
    //adjust delta considering the amount of steps per complete lap
    delta = delta/360.0f*kMVRStepsPerCompleteSlide;
    
    if (abs(delta) > 360.0f/kMVRStepsPerCompleteSlide) {
        CGFloat d = 360.0f/kMVRStepsPerCompleteSlide;
        if (delta < 0)
            d *= -1;
        delta = d;
    }else{
        if (delta != 0) {
            BOOL clockWise = delta > 0;
            if (self.rotatingClockwise != clockWise) {
                //rotating in the opposite direction
                self.distanceInTheOppositeDirection ++;
            }else{
                //reset when continues in the current direction
                self.distanceInTheOppositeDirection = 0;
            }
            
            //when reaching the conditions for the change to happen apply it
            if (self.rotatingClockwise != clockWise &&
                self.distanceInTheOppositeDirection >= kMVRMinDistanceForRotationChange)
            {
                self.rotatingClockwise = clockWise;
                self.distanceInTheOppositeDirection = 0;
                rotationIsChanged = YES;
            }
        }
    }
        
    NSLog(@"delta %.f\t current %.f\t last %.f \t%@", delta, floor(currentAngle), floor(self.lastAngle), self.rotatingClockwise? @"~>":@"<~" );

    self.angle = 360 - angleInt;
    _currentAccumulationValue += delta;
    self.lastAngle = angleInt;
    if (rotationIsChanged) {
        self.rotationChangeAngle = self.angle;
    }
    
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
    
    CGContextAddArc(imageCtx, self.frame.size.width/2, self.frame.size.height/2, radius,  ToRad(self.angle)+M_PI_2*3, ToRad(self.angle), self.rotatingClockwise);
    
    CGFloat amount = self.angle/20, maxAmount = 360 / 20;
    CGFloat blurSize = self.rotatingClockwise ? maxAmount - amount : amount;
    //Use shadow to create the Blur effect
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), blurSize, [UIColor blackColor].CGColor);

    //define the path
    CGContextSetLineWidth(imageCtx, TB_LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    
//    /** Clip Context to the mask and draw the internal**/
//    CGContextSaveGState(ctx);
//    {
//        CGContextClipToMask(ctx, self.bounds, mask);
//        CGImageRelease(mask);
//        
//        
//        /** THE GRADIENT **/
//        CGFloat components[8] = {
//            1.0, 1.0, 0.0, 0.0,     // Start color - Blue
//            0.8, 0.8, 0.0, 1.0 };   // endcolor
//        
//        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
//        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
//        CGColorSpaceRelease(baseSpace), baseSpace = NULL;
//        
//        //Gradient direction
//        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//        if (self.rotatingClockwise) {
//            CGPoint tempPoint = startPoint;
//            startPoint = endPoint;
//            endPoint = tempPoint;
//        }
//        
//        
//        
//        //Draw the gradient
//        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
//        CGGradientRelease(gradient), gradient = NULL;
//        
//        
//    } CGContextRestoreGState(ctx);
    
    /** Clip Context to the mask **/
    CGContextSaveGState(ctx);
    {
        CGContextClipToMask(ctx, self.bounds, mask);
        CGImageRelease(mask);
        
        
        /** THE GRADIENT **/
        
        CGFloat components[8] = {
        0.0, 0.0, 1.0, 0.0,     // Start color - Blue
        1.0, 0.0, 0.0, 1.0 };   // endcolor
        
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
        CGColorSpaceRelease(baseSpace), baseSpace = NULL;
        
        //Gradient direction
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        if (self.rotatingClockwise) {
            CGPoint tempPoint = startPoint;
            startPoint = endPoint;
            endPoint = tempPoint;
        }
        
        
        
        //Draw the gradient
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
        CGGradientRelease(gradient), gradient = NULL;
        

    } CGContextRestoreGState(ctx);
    
    
    
    
//
//    
//    /** Add some light reflection effects on the background circle**/
//    
//    CGContextSetLineWidth(ctx, 1);
//    CGContextSetLineCap(ctx, kCGLineCapRound);
//    
//    //Draw the outside light
//    CGContextBeginPath(ctx);
//    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius+TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
//    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
//    CGContextDrawPath(ctx, kCGPathStroke);
//    
//    //draw the inner light
//    CGContextBeginPath(ctx);
//    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius-TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
//    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
//    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    /** Draw the handle **/
    [self drawTheHandle:ctx];
    
}

//
//        CGFloat red = 0, green = 0, blue = 0;
//#warning make it proper
//        CGFloat maxValue = 10000;
//
//        if (_currentAccumulationValue == 0) {
//            red = 0;
//            green = 0.1;
//            blue = 0;
//        } else {
//            red += (_currentAccumulationValue * 0.175),
//            green += _currentAccumulationValue * 0.125,
//            blue += _currentAccumulationValue * 0.161;
//            //        NSLog(@"PREcomponents: %f %f %f (%f)", red, green, blue, _currentAccumulationValue);
//
//            //normalize between 0..1
//            red = (red) / (maxValue);
//            green = (green) / (maxValue);
//            blue = (blue) / (maxValue);
//
//            //        NSLog(@"components: %f %f %f (%f)", red, green, blue, _currentAccumulationValue);
//        }

//list of components
//        CGFloat components[8] = {
//            red, green, blue, 1.0,     // Start color - R,G,B,Alpha
//            0.1, 0.1, 0.1, 1.0 };   // End color - R,G,B,Alpha

//    NSLog(@"components: %f %f %f", red, green, blue);


//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float calculateAngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

@end
