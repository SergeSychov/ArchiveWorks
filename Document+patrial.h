//
//  Document+patrial.h
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "Document.h"

@interface Document (patrial)
+(Document*)createNewRepositoryWithName:(NSString*)name documetnData:(NSData*)docDate Repository:(NSString*) repositoryName inContext:(NSManagedObjectContext *)context;
@end
