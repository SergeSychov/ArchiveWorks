//
//  documnetViewController.h
//  PatrialTwo
//
//  Created by Serge Sychov on 08.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoordinatorCoreDate.h"
#import "Document+patrial.h"


@interface DocumnetViewController : UIViewController

@property (nonatomic) CoordinatorCoreDate* coordinatorCoreDate;
@property (nonatomic) Document *document;
@property (nonatomic) NSString *nameRepository;

@end
