//
//  ViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "ViewController.h"
#import "PassViewController.h"
#import "Repository+patrial.h"
#import "Document+patrial.h"
#import "CoordinatorCoreDate.h"

//impotr button views
#import "PlusButton.h"

@interface ViewController () <CoorinatorProtocol,NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) CoordinatorCoreDate *coordinatorCoreDate;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRepositories;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItem;

//for checking fetchcontroller
@property (nonatomic) NSMutableArray* testMutArray;


@end

@implementation ViewController

-(NSMutableArray*)testMutArray {
    if(!_testMutArray){
       _testMutArray = [[NSMutableArray alloc] initWithObjects:@"Паспорт",
                                                                @"Снилс",
                                                                @"Инн",
                                                                @"Свидетельство",
                                                                @"Документ",
                                                                @"Права",
                                                                @"Страховка",
                                                                @"Диплом",
                                                                @"Курсы",
                                                                @"Дети",nil];
    }
    return _testMutArray;
    
}
#pragma mark CREATE NEW REPOSITORY
- (IBAction)addBarrButtonTapped:(id)sender {
    if(self.testMutArray.count >0){
        [self.coordinatorCoreDate addNewRepository:[self.testMutArray firstObject]];
        [self.testMutArray removeObjectAtIndex:0];
    } else {
        NSLog(@"Mut array is empty");
    }
    
    //[self addNewPerpositoryButtonTapped:sender];
}

-(void)addNewPerpositoryButtonTapped:(id)sender{
    NSLog(@"add new repositay button tapped");
}

#pragma mark COORDINATOR DELEGATE
-(void) RepositoriesAreChanged {
    NSInteger quant = self.coordinatorCoreDate.repFetchController.fetchedObjects.count;
    NSLog(@"Repositories changed with quantity %ld",(long)quant);
    if(quant > 0){
        for(Repository *rep in self.coordinatorCoreDate.repFetchController.fetchedObjects){
            NSLog(@"Obj: %@, order %@",rep.nameRepository, rep.naumberOrdein);
        }
    }
    [self.tableViewRepositories reloadData];
    
    
    quant = self.coordinatorCoreDate.docFetchController.fetchedObjects.count;
    NSLog(@"Documents changed with quantity %ld",(long)quant);
}
#pragma mark FETCHED CONTROLLER DELEGATE
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableViewRepositories beginUpdates];
    //make dictionary heights according number of row
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableViewRepositories insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationBottom];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableViewRepositories deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationBottom];
            break;
            
        case NSFetchedResultsChangeMove:
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            
            break;
            
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    // NSLog(@"IndexPatch - %ld", (long)indexPath.row);
    // NSLog(@"NewIndexPatch - %ld", (long)newIndexPath.row);
    switch(type)
    {
        case NSFetchedResultsChangeInsert:{
            [self.tableViewRepositories insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tableViewRepositories deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:{
            [self.tableViewRepositories reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableViewRepositories deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableViewRepositories insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableViewRepositories endUpdates];
}


#pragma mark TABLE VIEW DATA SOURSE
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableViewRepositories dequeueReusableCellWithIdentifier:@"RepositoyCell"];

        if(indexPath.row == [tableView numberOfRowsInSection: 0] - 1){
            CGFloat defaultHeight = self.view.frame.size.height/13;
            PlusButton *addNewRepositoryButton = [[PlusButton alloc] init];
            [addNewRepositoryButton addTarget:self action:@selector(addNewPerpositoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            addNewRepositoryButton.frame = CGRectMake(20, 0, defaultHeight, defaultHeight);
            addNewRepositoryButton.titleLabel.textColor = [UIColor greenColor];
            [cell.contentView addSubview:addNewRepositoryButton];
            
            UILabel *addNewRepositoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + defaultHeight,
                                                                                      0,
                                                                                      cell.bounds.size.width - (40 + defaultHeight),
                                                                                      defaultHeight)];
            addNewRepositoryLabel.textColor = [UIColor lightGrayColor];
            addNewRepositoryLabel.backgroundColor = [UIColor clearColor];
            addNewRepositoryLabel.text = @"Создайте новый раздел";
            
            [cell.contentView addSubview:addNewRepositoryLabel];

        } else {
            NSIndexPath *fetchPatch = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            Repository *repository = [self.coordinatorCoreDate.repFetchController objectAtIndexPath:fetchPatch];
            
            cell.textLabel.text = repository.nameRepository;
        }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections;
    if(self.coordinatorCoreDate.repFetchController && [[self.coordinatorCoreDate.repFetchController sections] count] > 0){
        sections = [[self.coordinatorCoreDate.repFetchController sections] count];
    } else {
        sections = 1 ;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return one more rows than in fatched result controller
    NSInteger rows = 1;
    
    if (self.coordinatorCoreDate.repFetchController && [[self.coordinatorCoreDate.repFetchController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.coordinatorCoreDate.repFetchController sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects]+1;
    }
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.view.frame.size.height/13;
    //for cell NEW repository set height to whole screen
    if (self.coordinatorCoreDate.repFetchController && [[self.coordinatorCoreDate.repFetchController sections] count] > 0){
        
        if(indexPath.row == self.coordinatorCoreDate.repFetchController.fetchedObjects.count){
            height = self.view.frame.size.height;
        }
    } else {
        height = self.view.frame.size.height;
    }
    return height;
}


#pragma mark VIEW DID LOAD
- (void)viewDidLoad {
    [super viewDidLoad];
    //init coordinator
    CoordinatorCoreDate *coordinatorCoreDate = [[CoordinatorCoreDate alloc] init];
    coordinatorCoreDate.delegatedByRepository = self;
    self.coordinatorCoreDate = coordinatorCoreDate;

    //to ask user pass each time as App appears
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(appDidGoToForeground)
                                                   name:UIApplicationDidBecomeActiveNotification
                                                 object:[UIApplication sharedApplication]];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) appDidGoToForeground {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PassViewController *passViewController = [storyBoard instantiateViewControllerWithIdentifier:@"PassViewController"];
    [self presentViewController:passViewController animated:NO completion:^{
        nil;
    }];
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
