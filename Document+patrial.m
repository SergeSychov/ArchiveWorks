//
//  Document+patrial.m
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "Document+patrial.h"
#import "Repository+patrial.h"

@implementation Document (patrial)

+(Document*)createNewDocumentWithData:(NSData*)docData name:(NSString*)name Repository:(NSString*)repositoryName inContext:(NSManagedObjectContext *)context;
{
    Document *newDoc = nil;

    //count all documents
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Document"];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    
    
    if(!matches || error){
        NSLog(@"Can't get matches");
    } else {
   
        newDoc = [NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:context];
        newDoc.name = name;
        newDoc.dataDocumnet = docData;
        newDoc.numberOrdering = [NSDate date];
        newDoc.repository = [Repository createNewRepositoryWithName:repositoryName inContext:context];
 
        newDoc.bigImageData = nil;
    }
    
    return newDoc;
}
@end
