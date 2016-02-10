//
//  DataImageOfDocument+patrial.h
//  PatrialTwo
//
//  Created by Serge Sychov on 10.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "DataImageOfDocument.h"

@interface DataImageOfDocument (patrial)
+(DataImageOfDocument*)createNewDataImageOfDocumentwith:(NSData*)data Document:(Document*)doc inContext:(NSManagedObjectContext*)context;


@end
