//
//  CoordinatorCoreDate.m
//  PatrialTwo
//
//  Created by Serge Sychov on 07.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "CoordinatorCoreDate.h"

@interface CoordinatorCoreDate()
@property (nonatomic) UIManagedDocument* managedDocument; //need for saving core data
@property (nonatomic) NSManagedObjectContext* managedContext;


@end

@implementation CoordinatorCoreDate
#pragma mark OVERRIDED INITIALISATION
-(void) awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}
-(id)init {
    self = [super init];
    if(self){
        [self setup];
    }
    
    return self;
}

//открываем/создаем Манаджет документ
//open or create NSManagedDocumets, FetchedControllers, as results: setup public arrays and ask to renew catchers
-(void) setup {
    
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] lastObject];
    NSString* documentName = @"ArchiveDocumetn";
    
    NSURL *localStoreUrl =  [documentsDirectory URLByAppendingPathComponent:documentName];
    
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:localStoreUrl];
    
    NSDictionary *localOptions = @{
                                   //for possiblity future migration
                                   NSPersistentStoreRemoveUbiquitousMetadataOption:@YES,
                                   NSMigratePersistentStoresAutomaticallyOption:@YES,
                                   NSInferMappingModelAutomaticallyOption:@YES};
    document.persistentStoreOptions = localOptions;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[localStoreUrl path]]) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success){
                [self documentIsReady: document];
            } else {
                NSLog(@"Not succes with open");
            }
        }];
    } else {
        [document saveToURL:localStoreUrl forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  [self documentIsReady: document];
              } else {
                  NSLog(@"Not succes with create and save");
              }
          }];
    }
    
    
    
}

//if oppening or creaating UIManagedDocumetc successeful - work with fetchControllers
-(void) documentIsReady:(UIManagedDocument*) document
{
    if(document.documentState == UIDocumentStateNormal){
        //NSLog(@"Document state NORMAL");
        //need for iCloud migration function in bottom of file
        //self.managedContext = [self removeDuplicateRecordsFromHistoryContext:document.managedObjectContext];
        
        self.managedContext = document.managedObjectContext;
        [self.managedContext setRetainsRegisteredObjects:YES];
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"naumberOrdein" ascending:YES]];
        //setup repositoryes controller at start
        self.repFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                      managedObjectContext:document.managedObjectContext
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:@"cacheRepFetchcontroller"];

    } else {
        NSLog(@"Document state %lu", (unsigned long)document.documentState);
    }
}

#pragma mark PUBLI FUNCs

//создание новой картотеки
-(Repository*)addNewRepository:(NSString *)nameRepository {
    Repository* returRepository = [Repository createNewRepositoryWithName:nameRepository inContext:self.managedContext];
    if(returRepository){
        NSLog(@"New Repository was created succesefully");
    } else {

    }
    return returRepository;
}
//создание нового документа
-(Document*) addNewDocumentWith:(UIImage*)image name:(NSString*)name andRepositoryName:(NSString*)nameRepository{
    
    NSData *imageData = UIImagePNGRepresentation([image scaleImage:image toNeedSize:CGSizeMake(540, 960)]); //extention of uiImage according half of iPhone 6 plus size
    
    Document *doc = nil;
    doc = [Document createNewDocumentWithData:imageData name:name Repository:nameRepository inContext:self.managedContext];
    //setBigImage data for this document
    [self bigImageData:image ofDocument:doc];

    if(doc){
       // NSLog(@"New Document was created succesefully with repository name: %@", doc.repository.name);
    } else {
        //NSLog(@"Can't create new Document");
    }


    return doc;
}

//ассинхронно сохраняем оригинальное изображение в базеЮ доступ через ссылку
-(void) bigImageData:(UIImage*)image ofDocument:(Document*)doc{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *originalImageData = UIImagePNGRepresentation([image scaledImage:image ToRatio:1]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            doc.bigImageData.data = originalImageData;
            //[DataImageOfDocument createNewDataImageOfDocumentwith:originalImageData Document:doc inContext:self.managedContext];
        });

    });
}

//меняем название картотеки
-(void) changeNameRepositoryFrom:(NSString*)fromStr To:(NSString*)toStr{
    Repository *repositoryWithNameFromStr = nil;
    for(Repository *rep in self.repFetchController.fetchedObjects){
        if([rep.name isEqualToString:fromStr]){
            repositoryWithNameFromStr = rep;
            break;
        }
    }
    
    NSError *error;
    if(repositoryWithNameFromStr){
        repositoryWithNameFromStr.name = toStr;
        if([self.repFetchController performFetch:&error]){
           // NSLog(@"Ok changes is done");
        } else {
          //  NSLog(@"Repository finded but changes not implement");
        }
    } else {
       // NSLog(@"Repository not finded");
    }
}

//берем уникальную строчку
//для картотеки документов
//------------------------------------------
-(NSString*)getPossibleDocumentNameWithInitial:(NSString*)initStr{
     return [self getPossibleNameWithInitial:initStr onEntity:@"Document"];
}
//для архива
-(NSString*)getPossibleRepositoryNameWithInitial:(NSString*)initStr {
    
    return [self getPossibleNameWithInitial:initStr onEntity:@"Repository"];
}
-(NSString*)getPossibleNameWithInitial:(NSString*)initStr onEntity:(NSString*)entityName {
    NSString *retStr = initStr;
    while ([self isEntity:entityName HasName:retStr]) {
        NSString* numberedString = [retStr substringFromIndex:(initStr.length)];
        NSInteger intFromStr = [numberedString integerValue];
        intFromStr++;
        retStr = [initStr stringByAppendingString:[@" " stringByAppendingString:[@(intFromStr) stringValue]]];
    }
    return retStr;
}


-(BOOL) isEntity:(NSString*)entityName HasName:(NSString*)str
{
    NSFetchRequest *request;

    request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", str];

    NSError *error;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    if([matches count]>0) {
        return YES;
    } else {
        return NO;
    }
}
//-----------------------------------------------------------------------


-(void) deleteDocumetn:(Document*)document{
    [self.managedContext deleteObject:document];
}
-(void) deleteRepository:(Repository*)repository{

    [self.managedContext deleteObject:repository];
    
    [self saveContext];


}

-(void) rotateImageofDocument:(Document*)document otOrientatiom:(UIImageOrientation)orientation {
    
    UIImage* scaledImage = [UIImage imageWithData:document.dataDocumnet];
    UIImage* rotadedScaledImage = [scaledImage rotateUIImage:scaledImage withOrientation:orientation] ;
    
    //create the same document and replace previous - need for fetch this changes
    Document* newDoc = [Document createNewDocumentWithData:UIImagePNGRepresentation(rotadedScaledImage)
                                                      name:document.name
                                                Repository:document.repository.name
                                                 inContext:self.managedContext];
    newDoc.numberOrdering = document.numberOrdering;
    
    //before take image
    UIImage* originalImage = [UIImage imageWithData:document.bigImageData.data];
    
    //document = newDoc;
    [self.managedContext deleteObject:document];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        document.bigImageData.data = nil;
        UIImage * rotadedOriginalImage = [originalImage rotateUIImage:originalImage withOrientation:orientation];
        NSData *rotadedOriginalImageData = UIImagePNGRepresentation(rotadedOriginalImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            newDoc.bigImageData.data = rotadedOriginalImageData;
            //[DataImageOfDocument createNewDataImageOfDocumentwith:rotadedOriginalImageData Document:newDoc inContext:self.managedContext];
            
        });
        
    });
    
}


#pragma mark SETTERS 

-(void) setRepFetchController:(NSFetchedResultsController *)repFetchController{
    NSFetchedResultsController *oldfrc = _repFetchController;
    if(oldfrc != repFetchController){
        _repFetchController = repFetchController;
        
        if(_repFetchController){
            //NSLog(@"There is repFetchController");
            NSError *error;
            [_repFetchController performFetch:&error];
        }
        if(self.delegatedByRepository){
            //if there is delegated controller - renew it
            //NSLog(@"delegated was create previosly");
            _repFetchController.delegate = self.delegatedByRepository;
            [self.delegatedByRepository RepositoriesAreChanged];
        }
    }
}


-(void)setDelegatedByRepository:(id)delegatedByRepository{
    _delegatedByRepository = delegatedByRepository;
    //othervise if fetchController was create previosly
    if(self.repFetchController){
        self.repFetchController.delegate = delegatedByRepository;
         //NSLog(@"fetchController was create previosly");
    }
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end

/* for future - need to migrate iCloud
 -(NSManagedObjectContext*)removeDuplicateRecordsFromHistoryContext:(NSManagedObjectContext*) internalContext
 {
 //choose u uniq property for button - Name
 NSManagedObjectContext *context = internalContext;
 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Entity name"];
 request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
 
 NSError *error;
 NSArray *matches = [context executeFetchRequest:request error:&error];
 
 //choose winner
 History *prevObject;
 for(History *duplicate in matches){
 // NSLog(@"Duplicate name %@ vs previosName %@", duplicate.UNIC_PROPERTY, prevObject.UNIC_PROPERTY);
 
 if([duplicate.UNIC_PROPERTY ate isEqualToDate:prevObject.UNIC_PROPERTY]){
 [context deleteObject:prevObject];
 prevObject = duplicate;
 } else {
 prevObject = duplicate;
 }
 }
 return context;
 }
 */
