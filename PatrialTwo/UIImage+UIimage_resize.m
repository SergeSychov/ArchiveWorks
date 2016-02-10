//
//  UIImage+UIimage_resize.m
//  PatrialTwo
//
//  Created by Serge Sychov on 10.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "UIImage+UIimage_resize.h"

@implementation UIImage (UIimage_resize)

-(UIImage*) scaledImage:(UIImage*)img ToRatio:(CGFloat)ratio{
    CGSize inputSize = img.size;
    CGSize newSize;
    newSize.width = inputSize.width*ratio;
    newSize.height = inputSize.height*ratio;
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
