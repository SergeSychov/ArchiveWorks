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
    [self resetDocumetFetchResultController];
}
-(void) changeNameRepositoryFrom:(NSString*)fromStr To:(NSString*)toStr{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
    request.predicate = [NSPredicate predicateWithFormat:@"nameRepository = %@", fromStr];
    
    NSError *error;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    if([matches count]>0) {
        Repository *repObj = matches[0];
        repObj.nameRepository = toStr;
    } else {
        NSLog(@"Can't fetch this repository");
    }
    //renew documetnFetch according doccument in exactly repository
    [self resetDocumetFetchResultController];
}

-(void) resetDocumetFetchResultController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Document"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numberOrdering" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"nameDocument == %@",[_delegatedByDocuments documentsRepositoryName]];
    self.docFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                  managedObjectContext:self.managedContext
                                                                    sectionNameKeyPath:nil
                                                                             cacheName:nil];

    self.docFetchController.delegate = _delegatedByDocuments;
}

-(NSString*)getPossibleNameFromRepositoryWithInitial:(NSString*)initStr {
    NSString *retStr = initStr;
    while ([self isRepositoriesHasName:retStr]) {
        NSString* numberedString = [retStr substringToIndex:initStr.length];
        NSInteger intFromStr = [numberedString integerValue];
        intFromStr++;
        retStr = [initStr stringByAppendingString:[@" " stringByAppendingString:[@(intFromStr) stringValue]]];
    }
    return retStr;
}

-(BOOL) isRepositoriesHasName:(NSString*)str
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
    request.predicate = [NSPredicate predicateWithFormat:@"nameRepository = %@", str];
    
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
        //need for iCloud migration
        //function in bottom of file
        //self.managedContext = [self removeDuplicateRecordsFromHistoryContext:document.managedObjectContext];
        self.managedContext = document.managedObjectContext;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"naumberOrdein" ascending:YES]];
        self.repFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:document.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
        /*
        request = [NSFetchRequest fetchRequestWithEntityName:@"Document"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numberOrdering" ascending:YES]];
        self.docFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                      managedObjectContext:document.managedObjectContext
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
         */
        
    } else {
        NSLog(@"Document state %lu", (unsigned long)document.documentState);
    }
}

#pragma mark SETTERS 

/*
-(void) setDocFetchController:(NSFetchedResultsController *)docFetchController{
    NSFetchedResultsController *oldfrc = _docFetchController;
    if(oldfrc != docFetchController){
        _docFetchController = docFetchController;
        if(self.delegatedByDocuments){
            //if there is delegated controller - setupDelegation
             NSLog(@"delegated was create previosly");
            _docFetchController.delegate = self.delegatedByDocuments;
        }
        
        if(_docFetchController){
            NSLog(@"There is docFetchController");
            NSError *error;
            [_docFetchController performFetch:&error];
        }
        if(self.delegatedByDocuments){
                //if there is delegated controller - renew it
            [self.delegatedByDocuments DocumentsAreChanged];
        }
    }
}
*/


-(void) setDelegatedByDocuments:(id)delegatedByDocuments {
    _delegatedByDocuments = delegatedByDocuments;
    //renew documetnFetch according doccument in exactly repository
    [self resetDocumetFetchResultController];
}

//right setup delegate and delegator
//there is two case:
//1. can be fetchcontroller without delegatedcontroller, not create yet
//2. can be delegatedController but fetchcontroller not created still

-(void) setRepFetchController:(NSFetchedResultsController *)repFetchController{
    NSFetchedResultsController *oldfrc = _repFetchController;
    if(oldfrc != repFetchController){
        _repFetchController = repFetchController;
        if(self.delegatedByRepository){
            //if there is delegated controller - setupDelegation
            _repFetchController.delegate = self.delegatedByRepository;
            NSLog(@"delegated was create previosly");
        }
        
        if(_repFetchController){
            NSLog(@"There is repFetchController");
            NSError *error;
            [_repFetchController performFetch:&error];
        }
        if(self.delegatedByRepository){
            //if there is delegated controller - renew it
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
