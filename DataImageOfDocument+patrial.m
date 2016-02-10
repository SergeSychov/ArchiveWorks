//
//  DataImageOfDocument+patrial.m
//  PatrialTwo
//
//  Created by Serge Sychov on 10.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "DataImageOfDocument+patrial.h"

@implementation DataImageOfDocument (patrial)
+(DataImageOfDocument*)createNewDataImageOfDocumentwith:(NSData*)data Document:(Document*)doc inContext:(NSManagedObjectContext*)context{
    DataImageOfDocument *newDataImageOfDocument = nil;
    newDataImageOfDocument = [NSEntityDescription insertNewObjectForEntityForName:@"DataImageOfDocument" inManagedObjectContext:context];
    newDataImageOfDocument.data = data;
    newDataImageOfDocument.document = doc;
    
    return newDataImageOfDocument;
}

@end
