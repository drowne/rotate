//
//  UIArcSlider.m
//  Rotate!
//
//  Created by Movellas on 4/22/13.
//  Copyright (c) 2013 34BigThings. All rights reserved.
//

#import "UIArcSlider.h"

@interface UIArcSlider()

@property (nonatomic) CGPoint thumbCenterPoint;

#pragma mark - Init and Setup methods
- (void)setup;

#pragma mark - Thumb management methods
- (BOOL)isPointInThumb:(CGPoint)point;

#pragma mark - Drawing methods
- (CGFloat)sliderRadius;
- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context;
- (CGPoint)drawTheArcTrack:(float)track atPoint:(CGPoint)center withRadius:(CGFloat)radius AndColor:(Boolean) isWhite inContext:(CGContextRef)context;
- (CGPoint)drawTheLineTrack:(float)track withColor:(Boolean) isWhite inContext:(CGContextRef)context;

@end

#pragma mark -
@implementation UIArcSlider

@synthesize sliderStyle = _sliderStyle;

- (void)setSliderStyle:(UISliderStyle)sliderStyle {
    if (sliderStyle != _sliderStyle) {
        _sliderStyle = sliderStyle;
        [self setNeedsDisplay];
    }
}

@synthesize value = _value;
- (void)setValue:(float)value {
    if (value != _value) {
        if (value > self.maximumValue) { value = self.maximumValue; }
        if (value < self.minimumValue) { value = self.minimumValue; }
        _value = value;
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}
@synthesize minimumValue = _minimumValue;
- (void)setMinimumValue:(float)minimumValue {
    if (minimumValue != _minimumValue) {
        _minimumValue = minimumValue;
        if (self.maximumValue < self.minimumValue)  { self.maximumValue = self.minimumValue; }
        if (self.value < self.minimumValue)         { self.value = self.minimumValue; }
    }
}
@synthesize maximumValue = _maximumValue;
- (void)setMaximumValue:(float)maximumValue {
    if (maximumValue != _maximumValue) {
        _maximumValue = maximumValue;
        if (self.minimumValue > self.maximumValue)  { self.minimumValue = self.maximumValue; }
        if (self.value > self.maximumValue)         { self.value = self.maximumValue; }
    }
}

@synthesize thumbCenterPoint = _thumbCenterPoint;

/** @name Init and Setup methods */
#pragma mark - Init and Setup methods
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.value = 0.0;
    self.minimumValue = 0.0;
    self.maximumValue = 100.0;
    self.thumbCenterPoint = CGPointZero;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHappened:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHappened:)];
    panGestureRecognizer.maximumNumberOfTouches = panGestureRecognizer.minimumNumberOfTouches;
    [self addGestureRecognizer:panGestureRecognizer];
}

/** @name Drawing methods */
#pragma mark - Drawing methods
#define kLineWidth 22.0
#define kThumbRadius 20.0
#define kPadding 20.0

- (CGFloat)sliderRadius {
    CGFloat radius = self.bounds.size.width;
    radius -= MAX(kLineWidth + kPadding, kThumbRadius  + kPadding);
    return radius;
}

-(CGFloat)sliderWidth {
    return self.bounds.size.width - kThumbRadius*2;
}

- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, sliderButtonCenterPoint.x, sliderButtonCenterPoint.y);
    
    CGRect rect = CGRectMake(sliderButtonCenterPoint.x - kThumbRadius, sliderButtonCenterPoint.y - kThumbRadius, kThumbRadius*2, kThumbRadius*2);
    CGImageRef imageRef = [UIImage imageNamed:@"circle25.png"].CGImage;
    
    CGContextDrawImage(context, rect, imageRef);
    
    UIGraphicsPopContext();
}

- (CGPoint)drawTheArcTrack:(float)track atPoint:(CGPoint)center withRadius:(CGFloat)radius AndColor:(Boolean) isWhite inContext:(CGContextRef)context
{
    static CGFloat const kArcThickness = kLineWidth;
    CGPoint arcCenter = center;
    CGFloat arcRadius = radius;
    
    float angleFromTrack = translateValueFromSourceIntervalToDestinationInterval(track, self.minimumValue, self.maximumValue, 0, M_PI/3);// 2*M_PI
    
    CGFloat startAngle = (4*M_PI)/3;
    CGFloat endAngle = startAngle + angleFromTrack;
    
    UIBezierPath *arc = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:arcRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    CGPathRef shape = CGPathCreateCopyByStrokingPath(arc.CGPath, NULL, kArcThickness, kCGLineCapRound, kCGLineJoinRound, 10.0f);
    CGMutablePathRef shapeInverse = CGPathCreateMutableCopy(shape);
    CGPathAddRect(shapeInverse, NULL, CGRectInfinite);
    
    CGPoint arcEndPoint = [arc currentPoint];
    
    CGContextBeginPath(context);
    CGContextAddPath(context, shape);
    
    if (isWhite) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:.9 alpha:1].CGColor);
    } else {//70,172, 220
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:70/255.0 green:172/255.0 blue:220/255.0 alpha:1].CGColor);
    }
    
    CGContextFillPath(context);
    
    CGContextSaveGState(context); {
        CGContextBeginPath(context);
        CGContextAddPath(context, shape);
        CGContextClip(context);
        if (isWhite) {
            CGContextSetShadowWithColor(context, CGSizeZero, 7, [UIColor colorWithWhite:0 alpha:.25].CGColor);
        } else {
            CGContextSetShadowWithColor(context, CGSizeZero, 7, [UIColor colorWithRed:85/255.0 green:183/255.0 blue:230/255.0 alpha:.25].CGColor);
        }
        CGContextBeginPath(context);
        CGContextAddPath(context, shapeInverse);
        CGContextFillPath(context);
    } CGContextRestoreGState(context);
    
    if (isWhite) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:.75 alpha:1].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:62/255.0 green:135/255.0 blue:169/255.0 alpha:1].CGColor);
    }
    
    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextBeginPath(context);
    CGContextAddPath(context, shape);
    CGContextStrokePath(context);
    
    CGPathRelease(shape);
    CGPathRelease(shapeInverse);
    
    return arcEndPoint;
}


- (CGPoint)drawTheLineTrack:(float)track withColor:(Boolean) isWhite inContext:(CGContextRef)context
{
    CGFloat sliderWidth = [self sliderWidth];
    CGFloat xStart = self.bounds.origin.x + (self.bounds.size.width - sliderWidth)/2;
    CGFloat lineRectX = (self.bounds.size.width - sliderWidth)/2;
    CGFloat lineThickness = kLineWidth/2;
    CGFloat lineRectY = (self.bounds.size.height - lineThickness)/2;
    
    CGFloat xPoint = translateValueToPoint(track, xStart, self.maximumValue, sliderWidth);
    sliderWidth = xPoint;
    
    CGRect lineRect = CGRectMake(lineRectX, lineRectY, sliderWidth, lineThickness);
    UIBezierPath *line = [UIBezierPath bezierPathWithRoundedRect:lineRect cornerRadius:lineThickness/2];
    
    CGPathRef shape = CGPathCreateCopyByStrokingPath(line.CGPath, NULL, lineThickness, kCGLineCapRound, kCGLineJoinRound, 10.0f);
    CGMutablePathRef shapeInverse = CGPathCreateMutableCopy(shape);
    CGPathAddRect(shapeInverse, NULL, CGRectInfinite);
    
    CGPoint arcEndPoint = CGPointMake(lineRectX + xPoint, lineRectY + (lineThickness/2));
    
    CGContextBeginPath(context);
    CGContextAddPath(context, shape);
    
    if (isWhite) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:.9 alpha:1].CGColor);
    } else {//70,172, 220
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:70/255.0 green:172/255.0 blue:220/255.0 alpha:1].CGColor);
    }
    
    CGContextFillPath(context);
    
    CGContextSaveGState(context); {
        CGContextBeginPath(context);
        CGContextAddPath(context, shape);
        CGContextClip(context);
        if (isWhite) {
            CGContextSetShadowWithColor(context, CGSizeZero, 7, [UIColor colorWithWhite:0 alpha:.25].CGColor);
        } else {
            CGContextSetShadowWithColor(context, CGSizeZero, 7, [UIColor colorWithRed:85/255.0 green:183/255.0 blue:230/255.0 alpha:.25].CGColor);
        }
        CGContextBeginPath(context);
        CGContextAddPath(context, shapeInverse);
        CGContextFillPath(context);
    } CGContextRestoreGState(context);
    
    if (isWhite) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:.75 alpha:1].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:62/255.0 green:135/255.0 blue:169/255.0 alpha:1].CGColor);
    }
    
    CGRect outlineRect = CGRectMake(lineRectX - (lineThickness/2), lineRectY - (lineThickness/2), sliderWidth + lineThickness, lineThickness * 2);
    UIBezierPath *outline = [UIBezierPath bezierPathWithRoundedRect:outlineRect cornerRadius:lineThickness];
    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinBevel);
    CGContextBeginPath(context);
    CGContextAddPath(context, outline.CGPath);
    CGContextStrokePath(context);
    
    CGPathRelease(shape);
    CGPathRelease(shapeInverse);
    
    return arcEndPoint;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint middlePoint;
    
    switch (self.sliderStyle) {
        case UISliderStyleLine:
            
            [self drawTheLineTrack:self.maximumValue withColor:YES inContext:context];
            self.thumbCenterPoint = [self drawTheLineTrack:self.value withColor:NO inContext:context];
            
            [self drawThumbAtPoint:self.thumbCenterPoint inContext:context];
            break;
            
        case UISliderStyleArc:
        default:
            middlePoint.x = self.bounds.origin.x + self.bounds.size.width/2;
            middlePoint.y = self.bounds.origin.y + self.bounds.size.width;
            
            CGFloat radius = [self sliderRadius];
            [self drawTheArcTrack:self.maximumValue atPoint:middlePoint withRadius:radius AndColor:YES inContext:context];
            
            self.thumbCenterPoint = [self drawTheArcTrack:self.value atPoint:middlePoint withRadius:radius AndColor:NO inContext:context];
            
            [self drawThumbAtPoint:self.thumbCenterPoint inContext:context];
            break;
    }
}

/** @name Thumb management methods */
#pragma mark - Thumb management methods
- (BOOL)isPointInThumb:(CGPoint)point {
    CGRect thumbTouchRect = CGRectMake(self.thumbCenterPoint.x - kThumbRadius, self.thumbCenterPoint.y - kThumbRadius, kThumbRadius*2, kThumbRadius*2);
    return CGRectContainsPoint(thumbTouchRect, point);
}

/** @name UIGestureRecognizer management methods */
#pragma mark - UIGestureRecognizer management methods
- (void)panGestureHappened:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint tapLocation = [panGestureRecognizer locationInView:self];
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateChanged: {
            
            CGFloat radius;
            CGPoint sliderCenter;
            CGPoint sliderStartPoint;
            CGFloat angle;
            
            
            CGFloat xStart;
            CGFloat maximumValue;
            CGFloat sliderWidth;
            CGFloat point;
            
            switch (self.sliderStyle) {
                case UISliderStyleLine:
                    
                    sliderWidth = [self sliderWidth];
                    xStart = self.bounds.origin.x + (self.bounds.size.width - sliderWidth)/2;
                    maximumValue = self.maximumValue;
                    point = tapLocation.x;
                    
                    self.value = translatePointToValue(point, xStart, maximumValue, sliderWidth);
                    
                    break;
                    
                case UISliderStyleArc:
                default:
                    
                    radius = [self sliderRadius];
                    sliderCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.width);
                    sliderStartPoint = CGPointMake(sliderCenter.x - (radius * 1.15), sliderCenter.y - (radius * 2.1) );
                    angle = angleBetweenThreePoints(sliderCenter, sliderStartPoint, tapLocation);
                    
                    if (angle < 0) {
                        angle = -angle;
                    }
                    else {
                        angle = 0.0;
                        //angle = M_PI/3 - angle;
                    }
                    
                    self.value = translateValueFromSourceIntervalToDestinationInterval(angle, 0, M_PI/3, self.minimumValue, self.maximumValue);
                    break;
            }
        }
        default:
            break;
    }
}
- (void)tapGestureHappened:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint tapLocation = [tapGestureRecognizer locationInView:self];
        if ([self isPointInThumb:tapLocation]) {
            // do something on tap
        }
        else {
        }
    }
}

@end

/** @name Utility Functions */
#pragma mark - Utility Functions
float translateValueFromSourceIntervalToDestinationInterval(float sourceValue, float sourceIntervalMinimum, float sourceIntervalMaximum, float destinationIntervalMinimum, float destinationIntervalMaximum) {
    float a, b, destinationValue;
    
    a = (destinationIntervalMaximum - destinationIntervalMinimum) / (sourceIntervalMaximum - sourceIntervalMinimum);
    b = destinationIntervalMaximum - a*sourceIntervalMaximum;
    
    destinationValue = a*sourceValue + b;
    
    return destinationValue;
}

float translateValueToPoint(float value, float xStart, float maximum, float width)
{
    float point = (width * value) / maximum;
    //
    //    point = xStart + point;
    //
    return point;
}

float translatePointToValue(float point, float xStart, float maximum, float width)
{
    float value = (point) * maximum;
    value = value / width;
    
    return value;
}


CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2) {
    CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
    CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
    
    CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
    
    return angle;
}