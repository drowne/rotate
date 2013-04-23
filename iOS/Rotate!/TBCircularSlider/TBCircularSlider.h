//
//  TBCircularSlider.h
//  TB_CircularSlider
//
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Parameters **/
#define TB_SLIDER_SIZE 320                          //The width and the heigth of the slider
#define TB_BACKGROUND_WIDTH 60                      //The width of the dark background
#define TB_LINE_WIDTH 40                            //The width of the active area (the gradient) and the width of the handle
#define TB_FONTSIZE 65                              //The size of the textfield font
#define TB_FONTFAMILY @"Futura-CondensedExtraBold"  //The font family of the textfield font
#define TB_SAFEAREA_PADDING 60

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )


@interface TBCircularSlider : UIControl
{
    @protected
    UITextField *_textField;
    int radius;

}

//the angle from 0 clockwise (in degrees)
@property (nonatomic,assign) int angle;

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint;
/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx;
/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt;

@end
