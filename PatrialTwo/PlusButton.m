//
//  PlusButton.m
//  ITSCalc
//
//  Created by Serge Sychov on 12.08.15.
//  Copyright (c) 2015 Sergey Sychov. All rights reserved.
//

#import "PlusButton.h"

#define IS_IPAD ([[UIDevice currentDevice].model hasPrefix:@"iPad"])

@interface PlusButton();
@property (nonatomic,strong) UIColor* storkeColor;
@end

@implementation PlusButton

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0.15;
    }];
    
    return [super beginTrackingWithTouch:touch withEvent:event];
    
}

-(void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.;
    }];
    
    [super endTrackingWithTouch:touch
                      withEvent:event];
}

-(void) cancelTrackingWithEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.;
    }];
    [super cancelTrackingWithEvent:event];
    
}


-(UIColor*) normalColor{
    
    if(self.state != UIControlStateDisabled){
        _normalColor = self.tintColor;
    } else {
        _normalColor = [UIColor grayColor];
    }
    return _normalColor;
}

-(UIColor*) touchedColor{
    if(self.state == UIControlStateNormal){
        if(!_touchedColor){
            _touchedColor = [UIColor colorWithWhite:0.95 alpha:1];
        }
    } else {
        _touchedColor = [UIColor grayColor];
    }
    return _touchedColor;
    
}
-(UIColor*) storkeColor
{
    
    if(!_storkeColor){
        _storkeColor = self.normalColor;
    }
    
    return _storkeColor;
}

-(void) drawHistoryTrashWithContect:(CGContextRef)contex inRect:(CGRect)rect
{
    //calculate border width
    CGFloat borderWidth;
    CGFloat radiusCorner;
    CGFloat borderVsRadius = 6.2;
    if(IS_IPAD){
        radiusCorner = ((rect.size.height)/1.2)/ 3.;
        
        borderWidth = radiusCorner / 4.9;//9.2;
    } else {
        radiusCorner = ((rect.size.height)/1.2)/ 3.2;
        
        borderWidth = radiusCorner / borderVsRadius;
    }
    
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    UIBezierPath *patch = [UIBezierPath bezierPath];
    
    CGPathRef pathOfRect;

    CGContextSetLineWidth(contex, borderWidth);
    UIColor *fillColor = [UIColor clearColor];
    CGContextSetLineCap(contex, kCGLineCapRound);
    CGContextSetFillColorWithColor(contex, fillColor.CGColor);
    
    UIColor *storkecolor = self.storkeColor;
    CGContextSetStrokeColorWithColor(contex, storkecolor.CGColor);

    CGFloat plusPart = rect.size.width/3;
    
    CGPoint pointOne = CGPointMake(center.x, center.y-plusPart);
    CGPoint pointTwo = CGPointMake(center.x, center.y+plusPart);
    CGPoint pointThree = CGPointMake(center.x-plusPart, center.y);
    CGPoint pointFour = CGPointMake(center.x+plusPart, center.y);
    
    [patch moveToPoint:pointOne];
    [patch addLineToPoint:pointTwo];
    [patch moveToPoint:pointThree];
    [patch addLineToPoint:pointFour];
    pathOfRect = patch.CGPath;
    
    CGFloat shadowBlur = 0.5;
    UIColor *shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    CGSize shadowOffset = CGSizeMake(1, 1);
    
    CGContextSetShadowWithColor(contex, shadowOffset, shadowBlur, shadowColor.CGColor);
    CGContextAddPath(contex, pathOfRect);
    CGContextDrawPath(contex, kCGPathFillStroke);

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawHistoryTrashWithContect:context inRect:rect];


    
    
}
@end

