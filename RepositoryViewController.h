//
//  RepositoryViewController.h
//  PatrialTwo
//
//  Created by Serge Sychov on 07.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoordinatorCoreDate.h"
@interface RepositoryViewController : UIViewController //<UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic,weak) CoordinatorCoreDate *coordinatorCoreDate; //получаем от родителя в наследство - не создаем
@property (nonatomic,strong) NSString* nameRepository;//вместе с родителем и имя хранилища в котором работать

@end
