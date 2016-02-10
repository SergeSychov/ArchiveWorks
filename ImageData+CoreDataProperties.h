//
//  ImageData+CoreDataProperties.h
//  PatrialTwo
//
//  Created by Serge Sychov on 10.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ImageData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) Document *document;

@end

NS_ASSUME_NONNULL_END
