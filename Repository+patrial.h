//
//  Repository+patrial.h
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "Repository.h"

@interface Repository (patrial)
+(Repository*)createNewRepositoryWithName:(NSString*)name inContext:(NSManagedObjectContext*)context;
@end
