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
#pragma mark PUBLI FUNCs
-(void)addNewRepository:(NSString *)nameRepository {
    if([Repository createNewRepositoryWithName:nameRepository inContext:self.managedContext]){
        NSLog(@"New Repository was created succesefully");
    } else {
        NSLog(@"Can't create new repository");
    }
    //renew documetnFetch according doccument in exactly repository
    //[self resetDocumetFetchResultController];
}

-(Document*) addNewDocumentWith:(UIImage*)image name:(NSString*)name andRepositoryName:(NSString*)nameRepository{
    
    image = [image scaledImage:image ToRatio:0.1];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    Document *doc = nil;
    doc = [Document createNewDocumentWithData:imageData name:name Repository:nameRepository inContext:self.managedContext];
    
    if(doc){
        NSLog(@"New Document was created succesefully with repository name: %@", doc.repository.name);
    } else {
        NSLog(@"Can't create new Document");
    }
    return doc;
}

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
            NSLog(@"Ok changes is done");
        } else {
            NSLog(@"Repository finded but changes not implement");
        }
    } else {
        NSLog(@"Repository not finded");
    }
    //renew documetnFetch according doccument in exactly repository
    //[self resetDocumetFetchResultController];
}

-(void) resetDocumetFetchResultController {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Document"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numberOrdering" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"repository.name = %@", [self.delegatedByDocuments documentsRepositoryName]];
    
    self.docFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                  managedObjectContext:self.managedContext
                                                                    sectionNameKeyPath:nil
                                                                             cacheName:@"cacheDocFetchController"];

    self.docFetchController.delegate = _delegatedByDocuments;
}
-(NSString*)getPossibleDocumentNameWithInitial:(NSString*)initStr{
     return [self getPossibleNameWithInitial:initStr onEntity:@"Document"];
}

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
// test

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

-(void) setup {
    //open or create NSManagedDocumets, FetchedControllers, as results: setup public arrays and ask to renew catchers
    

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
        NSLog(@"Document state NORMAL");
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
        
        
        //documents fetch controller will setup at hase Delegate

       
        
    } else {
        NSLog(@"Document state %lu", (unsigned long)document.documentState);
    }
}

#pragma mark SETTERS 



-(void) setDelegatedByDocuments:(id)delegatedByDocuments {
    _delegatedByDocuments = delegatedByDocuments;
    //renew documetnFetch according doccument in exactly repository
    [self resetDocumetFetchResultController];
}

//right setup delegate and delegator
//there is two case:
//1. can be fetchcontroller without delegatedcontroller, not create yet
//2. can be delegatedController but fetchcontroller not created still
-(void) setDocFetchController:(NSFetchedResultsController *)docFetchController{
    NSFetchedResultsController *oldfrc = _docFetchController;
    if(oldfrc != docFetchController){
        _docFetchController = docFetchController;
        
        if(_docFetchController){
            NSLog(@"There is repFetchController");
            NSError *error;
            [_docFetchController performFetch:&error];
        }
        if(self.delegatedByRepository){
            //if there is delegated controller - renew it
            NSLog(@"delegated was create previosly");
            _docFetchController.delegate = self.delegatedByDocuments;
            [self.delegatedByDocuments DocumentsAreChanged];
        }
    }
}

-(void) setRepFetchController:(NSFetchedResultsController *)repFetchController{
    NSFetchedResultsController *oldfrc = _repFetchController;
    if(oldfrc != repFetchController){
        _repFetchController = repFetchController;
        
        if(_repFetchController){
            NSLog(@"There is repFetchController");
            NSError *error;
            [_repFetchController performFetch:&error];
        }
        if(self.delegatedByRepository){
            //if there is delegated controller - renew it
            NSLog(@"delegated was create previosly");
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
         NSLog(@"fetchController was create previosly");
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
