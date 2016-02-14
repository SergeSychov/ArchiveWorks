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
    
    //изменяем картинки до необходимого размера
    //надо будет поменять в зависимости от пришдших - пока просто уменьшение
    CGSize inputSize = img.size;
    //NSLog(@"ImageSize inputSize.width: %f, inputSize.height:%f",inputSize.width,inputSize.height );
    CGSize newSize;
    newSize.width = inputSize.width*ratio;
    newSize.height = inputSize.height*ratio;
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


-(UIImage*) scaleImage:(UIImage*)img toNeedSize:(CGSize)needSize{
    
    //изменяем картинки до необходимого размера
    //надо будет поменять в зависимости от пришдших - пока просто уменьшение
    CGSize inputSize = img.size;
    
    CGFloat ratio = (needSize.width/inputSize.width)> (needSize.height/inputSize.height) ? needSize.height/inputSize.height : needSize.width/inputSize.width;
    
    return [img scaledImage:img ToRatio:ratio];
}


@end
