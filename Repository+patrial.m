//
//  Repository+patrial.m
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "Repository+patrial.h"
#import "Repository.h"

@implementation Repository (patrial)

+(Repository*)createNewRepositoryWithName:(NSString*)name inContext:(NSManagedObjectContext *)context
{
    Repository *newRepository = nil;
    
    //check repositoies with this name
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if(!matches || error){
       // NSLog(@"Can't get matches");
    }  else if ([matches count] > 0){
        newRepository = matches.firstObject;
    } else {
        newRepository = [NSEntityDescription insertNewObjectForEntityForName:@"Repository" inManagedObjectContext:context];
        newRepository.name = name;
        //set numberOrdering accordin whhole quantity of repository< as last number
            request = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
            matches = [context executeFetchRequest:request error:&error];
        newRepository.naumberOrdein = [NSDate date];
        newRepository.documents = [[NSSet alloc] init];
       // newRepository.naumberOrdein = [NSNumber numberWithInteger:order];
    }

    return newRepository;
}


@end
