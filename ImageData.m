//
//  ImageData.m
//  PatrialTwo
//
//  Created by Serge Sychov on 10.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "ImageData.h"

@implementation ImageData
+(ImageData*)createNewDatawith:(NSData*)data inContext:(NSManagedObjectContext*)context {
    ImageData *newImageData = nil;
    newImageData = [NSEntityDescription insertNewObjectForEntityForName:@"ImageData" inManagedObjectContext:context];
    newImageData.data = data;
    
    return newImageData;
}

// Insert code here to add functionality to your managed object subclass

@end
