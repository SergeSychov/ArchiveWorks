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
    
    return [self scaledImage:img ToRatio:ratio];
}

-(UIImage*)rotateUIImage:(UIImage*)inputImage withOrientation:(UIImageOrientation)orientation{    CGSize size = inputImage.size;
    CGFloat width;
    CGFloat height;
    switch (orientation) {
        case UIImageOrientationLeft:
            width =size.height;
            height = size.width;
            break;
        case UIImageOrientationRight:
            width = size.height;
            height = size.width;
            break;
            
        default:
            width = size.width;
            height = size.height;
            break;
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [[UIImage imageWithCGImage:[inputImage CGImage] scale:1.0 orientation:orientation] drawInRect:CGRectMake(0,0,width ,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
