//
//  ImageData.h
//  PatrialTwo
//
//  Created by Serge Sychov on 10.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Document.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageData : Document
+(ImageData*)createNewDatawith:(NSData*)data inContext:(NSManagedObjectContext*)context;
// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "ImageData+CoreDataProperties.h"
