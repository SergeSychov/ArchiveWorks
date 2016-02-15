//
//  CoordinatorCoreDate.h
//  PatrialTwo
//
//  Created by Serge Sychov on 07.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//
/* 
 works with core data
 setup needed access to UIManaged document and FetchedController
 return data source aarays 
 
 protocol to catch sourse changes
 
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Document+patrial.h"
#import "Repository+patrial.h"
#import "UIImage+UIimage_resize.h"
#import "DataImageOfDocument+patrial.h"


@protocol CoorinatorProtocol <NSObject>


@optional
-(void) RepositoriesAreChanged;
-(void) DocumentsAreChanged;
-(NSString*)documentsRepositoryName; //need onle for delegatedByDocuments!!! But make requaried to avoid error


@end


@interface CoordinatorCoreDate : NSObject

@property (nonatomic) NSFetchedResultsController* repFetchController;
//@property (nonatomic) NSFetchedResultsController* docFetchController;

-(void) changeNameRepositoryFrom:(NSString*)fromStr To:(NSString*)toStr;
-(NSString*)getPossibleRepositoryNameWithInitial:(NSString*)initStr;
-(NSString*)getPossibleDocumentNameWithInitial:(NSString*)initStr;

-(Repository*) addNewRepository:(NSString*)nameRepository;
-(Document*) addNewDocumentWith:(UIImage*)image name:(NSString*)name andRepositoryName:(NSString*)nameRepository;
-(void) deleteDocumetn:(Document*)document;
-(void) deleteRepository:(Repository*)repository;
-(void) rotateImageofDocument:(Document*)document otOrientatiom:(UIImageOrientation)orientation;



@property (nonatomic,weak) id <CoorinatorProtocol, NSFetchedResultsControllerDelegate> delegatedByRepository;
@property (nonatomic,weak) id <CoorinatorProtocol, NSFetchedResultsControllerDelegate> delegatedByDocuments;

@end
