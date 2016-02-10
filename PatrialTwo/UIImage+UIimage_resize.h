//
//  UIImage+UIimage_resize.h
//  PatrialTwo
//
//  Created by Serge Sychov on 10.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIimage_resize)
-(UIImage*) scaledImage:(UIImage*)img ToRatio:(CGFloat)ratio;
@end
