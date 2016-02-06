//
//  Repository+CoreDataProperties.h
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Repository.h"

NS_ASSUME_NONNULL_BEGIN

@interface Repository (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *nameRepository;
@property (nullable, nonatomic, retain) NSNumber *naumberOrdein;
@property (nullable, nonatomic, retain) NSSet<Document *> *documents;

@end

@interface Repository (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(Document *)value;
- (void)removeDocumentsObject:(Document *)value;
- (void)addDocuments:(NSSet<Document *> *)values;
- (void)removeDocuments:(NSSet<Document *> *)values;

@end

NS_ASSUME_NONNULL_END
