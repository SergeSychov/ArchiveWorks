//
//  Document+patrial.h
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "Document.h"

@interface Document (patrial)
//+(Document*)createNewDocumentWithData:(NSData*)docData name:(NSString*)name Repository:(NSString*)repositoryName inContext:(NSManagedObjectContext *)context;
+(Document*)createNewDocumentWithData:(NSData*)docData BigImageData:(NSData*) bigData name:(NSString*)name Repository:(NSString*)repositoryName inContext:(NSManagedObjectContext *)context;
@end
