//
//  Document+CoreDataProperties.h
//  PatrialTwo
//
//  Created by Serge Sychov on 14.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Document.h"

NS_ASSUME_NONNULL_BEGIN

@interface Document (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *dataDocumnet;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *numberOrdering;
@property (nullable, nonatomic, retain) DataImageOfDocument *bigImageData;
@property (nullable, nonatomic, retain) Repository *repository;

@end

NS_ASSUME_NONNULL_END
