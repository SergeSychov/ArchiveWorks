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

+(Document*)createNewRepositoryWithName:(NSString*)name documetnData:(NSData*)docDate Repository:(NSString*) repositoryName inContext:(NSManagedObjectContext *)context
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
        newDoc.nameDocument = name;
        newDoc.dataDocumnet = docDate;
        newDoc.numberOrdering = [NSNumber numberWithInteger:matches.count];
        newDoc.repository = [Repository createNewRepositoryWithName:repositoryName inContext:context];
    }
    
    return newDoc;
}
@end
