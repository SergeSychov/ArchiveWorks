//
//  RepositoryViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 07.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "RepositoryViewController.h"
#import "Document+patrial.h"
#import "PlusButton.h"
#import "HorizontalScrollerView.h"
#import "DocumnetViewController.h"

@interface RepositoryViewController () <UITextFieldDelegate, CoorinatorProtocol,NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelAskUserEnterNameRepository;
@property (weak, nonatomic) IBOutlet UITextField *textFildRepositoryName;

@property (weak, nonatomic) IBOutlet UIButton *buttonEditDone;
@property (weak, nonatomic) IBOutlet UITableView *tableViewDocuments;

@property (nonatomic,weak) DocumnetViewController *docViewController;


@end

@implementation RepositoryViewController
#pragma mark PROPERTIES SETUP


-(void)setCoordinatorCoreDate:(CoordinatorCoreDate *)coordinatorCoreDate{
    _coordinatorCoreDate = coordinatorCoreDate;
    _coordinatorCoreDate.delegatedByDocuments = self;
    /*
    for(Document *doc in _coordinatorCoreDate.docFetchController.fetchedObjects){
        NSLog(@"Document: %@", doc);
    }
     */
    //[self.horizontalScrollerView reload];
}
-(void) RepositoriesAreChanged {
    NSLog(@"RepositoriesAreChanged");
}
-(void)setNameRepository:(NSString *)nameRepository{
    _nameRepository = nameRepository;
    [self userDidEndEditOrNotStart];
}

#pragma mark ACTIONS
- (IBAction)backtoArchiveButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)buttonEditDoneTapped:(UIButton *)sender {
    if([sender.titleLabel.text isEqualToString:@"Готово"]){
        [self newNameEnteredByUser];
    } else {
        [self userWillEdid];
    }
}

/*
-(void) documentTappedAtIndex:(NSInteger)index
{
    [self goToImageViewControllerWithImage:self.coordinatorCoreDate.docFetchController.fetchedObjects[index]]
}
*/
-(void) createnewDocument:(id)sender
{
    if(self.nameRepository){ //don't allow user make photo without repository name
        [self goToImageViewControllerWithDocument:nil];
    }
}
-(void) goToImageViewControllerWithDocument: (Document*)document
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocumnetViewController *docViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DocumnetViewController"];
    docViewController.document = document;
    docViewController.nameRepository = self.nameRepository;
    docViewController.coordinatorCoreDate = self.coordinatorCoreDate;
    self.docViewController = docViewController;
    
    [self presentViewController:docViewController animated:YES completion:^{
        nil;
    }];
}
#pragma mark TABLE VIEW DATA SOURSE
-(void) tapCellGesturRecogniser:(id)sender{
    CGPoint tapLocation = [sender locationInView:self.tableViewDocuments];
    NSIndexPath *indexPath = [self.tableViewDocuments indexPathForRowAtPoint:tapLocation];
    if(indexPath){
        if(indexPath.row < self.coordinatorCoreDate.docFetchController.fetchedObjects.count){
            Document *document = [self.coordinatorCoreDate.docFetchController objectAtIndexPath:indexPath];
            [self goToImageViewControllerWithDocument:document];
        } else {
            [self goToImageViewControllerWithDocument:nil];
        }
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    UITableViewCell *cell = [self.tableViewDocuments dequeueReusableCellWithIdentifier:@"DocumentCell"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCellGesturRecogniser:)];
    [cell addGestureRecognizer:tapGesture];
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
    if(indexPath.row == [tableView numberOfRowsInSection: 0] - 1){
        //remove old subviews - was several mistakes
        NSArray *arraySubvews = cell.contentView.subviews;
        if(arraySubvews && (arraySubvews.count >0)){
            for (NSInteger i = 0; i < arraySubvews.count; i++){
                UIView* subView = arraySubvews[i];
                [subView removeFromSuperview];
            }
        }
        
        CGFloat defaultHeight = self.view.frame.size.height/13;
        PlusButton *addNewDocumentButton = [[PlusButton alloc] init];
        [addNewDocumentButton addTarget:self action:@selector(createnewDocument:) forControlEvents:UIControlEventTouchUpInside];
        

        addNewDocumentButton.frame = CGRectMake((cell.bounds.size.height - defaultHeight)/2,
                                                (cell.bounds.size.width - defaultHeight)/2,
                                                defaultHeight, defaultHeight);
        [cell.contentView addSubview:addNewDocumentButton];
        
        UILabel *addNewDocumentLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.height/10,
                                                                                 cell.bounds.size.width*0.7,
                                                                                 cell.bounds.size.height*8/10,
                                                                                 cell.bounds.size.width/3)];
        addNewDocumentLabel.textColor = [UIColor lightGrayColor];
        addNewDocumentLabel.backgroundColor = [UIColor clearColor];
        addNewDocumentLabel.adjustsFontSizeToFitWidth = YES;
        addNewDocumentLabel.numberOfLines = 0;
        addNewDocumentLabel.text = @"Создайте новый документ";
        
        [cell.contentView addSubview:addNewDocumentLabel];
        
    } else {

        //remove old subviews - was several mistakes
        NSArray *arraySubvews = cell.contentView.subviews;
        if(arraySubvews && (arraySubvews.count >0)){
            for (NSInteger i = 0; i < arraySubvews.count; i++){
                UIView* subView = arraySubvews[i];
                [subView removeFromSuperview];
            }
        }
       
        UIImageView *imageView = [[UIImageView alloc] init];//WithFrame:CGRectInset(cell.bounds, 10., 10.)];
        Document *docObj = [self.coordinatorCoreDate.docFetchController.fetchedObjects objectAtIndex:indexPath.row];
        UIImage *docImage = [UIImage imageWithData:docObj.dataDocumnet];
        imageView.image = docImage;// [UIImage imageWithData:docObj.dataDocumnet];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        CGRect rctNotTransformed = CGRectInset(cell.bounds, 10., 10.);
        imageView.frame = CGRectMake(10.,
                                     10.,
                                     rctNotTransformed.size.height,
                                     rctNotTransformed.size.width);
        imageView.center = CGPointMake(cell.bounds.size.height/2, cell.bounds.size.height/2);
        [cell.contentView addSubview:imageView];
        UILabel *labelCreateNewDoc = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.height/10,
                                                                               cell.bounds.size.width*0.7,
                                                                               cell.bounds.size.height*8/10,
                                                                               cell.bounds.size.width/3)];
        
        labelCreateNewDoc.text = docObj.name;
        labelCreateNewDoc.textColor = [UIColor darkTextColor];
        labelCreateNewDoc.adjustsFontSizeToFitWidth = YES;
        labelCreateNewDoc.numberOfLines = 0;
        labelCreateNewDoc.textAlignment = NSTextAlignmentCenter;
        
        [cell.contentView addSubview:labelCreateNewDoc];

        return cell;

    }
    //cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
    return cell;
}

#pragma mark TABLE VIEW DELEGATE
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections;
    if(self.coordinatorCoreDate.docFetchController && [[self.coordinatorCoreDate.docFetchController sections] count] > 0){
        sections = [[self.coordinatorCoreDate.docFetchController sections] count];
    } else {
        sections = 1 ;
    }
    return sections;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSInteger rows = 1;
    
    if (self.coordinatorCoreDate.docFetchController && [[self.coordinatorCoreDate.docFetchController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.coordinatorCoreDate.docFetchController sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects]+1;
    }
    return rows;
}

#pragma mark COORDINATOR DELEGATE
-(NSString*)documentsRepositoryName{
    return self.nameRepository;
}

-(void) DocumentsAreChanged
{
    [self.tableViewDocuments reloadData];
}

#pragma mark FETCHED RESULT CONTROLLER DELEGATE

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableViewDocuments beginUpdates];
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
            [self.tableViewDocuments insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationBottom];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableViewDocuments deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationBottom];
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
            [self.tableViewDocuments insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tableViewDocuments deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:{
            [self.tableViewDocuments reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableViewDocuments deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableViewDocuments insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableViewDocuments endUpdates];
}




#pragma mark TEXT EDID FUNCTIONS
-(void)newNameEnteredByUser{
    self.textFildRepositoryName.textColor = [UIColor darkTextColor];
    //check symbol spase at the end. if is - remove it
    NSString *userOfferedName = [self checkAndRemoveSpasesAtTheEndOfString:self.textFildRepositoryName.text];
    NSString *oldRepositoryName = self.nameRepository;
    if(![userOfferedName isEqualToString:oldRepositoryName]){
        
        NSString* offeredByCoordinatorStr = [self.coordinatorCoreDate getPossibleRepositoryNameWithInitial:userOfferedName];
        //check if there is the same name in repository
        //if coordinator offer the same string - so it not repository with this name
        //if no - ok create new repository or rename existing
        if([offeredByCoordinatorStr isEqualToString:userOfferedName]){
            self.nameRepository = userOfferedName;
            if(oldRepositoryName){ //if not nel - was existing repostory
                [self.coordinatorCoreDate changeNameRepositoryFrom:oldRepositoryName To:self.nameRepository];
                NSLog(@"Name repository was chnged");
            } else { //create ne repository
                [self.coordinatorCoreDate addNewRepository:self.nameRepository];
            }
        } else { //if Yes - show allert controller to change it name
            self.textFildRepositoryName.text = offeredByCoordinatorStr;
            NSString *offerUser = @"Предлагаю: ";
            offerUser = [offerUser stringByAppendingString:offeredByCoordinatorStr];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Такое имя уже присвоено одному из Ваших разделов"
                                                                           message:offerUser
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {[self newNameEnteredByUser];}];
            UIAlertAction* enterOtherNameAction = [UIAlertAction actionWithTitle:@"Ввести другое имя раздела" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {[self enterAnotherName];}];
            
            [alert addAction:defaultAction];
            [alert addAction:enterOtherNameAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [self userDidEndEditOrNotStart];
    }
}
-(void) enterAnotherName {
    self.nameRepository = nil;
    [self checkNameRepository];
}
-(void)checkNameRepository {
    
    if(self.nameRepository == nil){ //there is new repository screen
        self.textFildRepositoryName.text =[self.coordinatorCoreDate getPossibleRepositoryNameWithInitial: @"Самое Важное"];
        [self userWillEdid];
        
        self.labelAskUserEnterNameRepository.text = @"Введите имя раздела";
    } else { //there is exsist repository screen
        self.textFildRepositoryName.text = self.nameRepository;
        [self userDidEndEditOrNotStart];

    }
}
-(void) userDidEndEditOrNotStart{


    if(self.textFildRepositoryName){ //if views are loaded
        self.textFildRepositoryName.textColor = [UIColor darkTextColor];
        self.textFildRepositoryName.enabled = NO;
        [self.textFildRepositoryName resignFirstResponder];
        
        [self.buttonEditDone setTitle:@"Правка" forState:UIControlStateNormal];
        
        NSString *countStr = [@(self.coordinatorCoreDate.docFetchController.fetchedObjects.count) stringValue];
        
        //right grammar
        countStr = [self letterAddition:countStr];
        NSString *labelStr = @"В разделе ";
        labelStr = [labelStr stringByAppendingString:countStr];
        self.labelAskUserEnterNameRepository.text = labelStr;
    }
}

-(void) userWillEdid {
    self.textFildRepositoryName.textColor = [UIColor lightGrayColor];
    self.textFildRepositoryName.enabled = YES;
    [self.textFildRepositoryName becomeFirstResponder];
    [self.buttonEditDone setTitle:@"Готово" forState:UIControlStateNormal];

    self.labelAskUserEnterNameRepository.text = @"Введите имя раздела";
}
#pragma mark TEXT FILD DELEGATE
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"]){
        [self newNameEnteredByUser];
    } else {
        //check if user would not ordered name at try to set new name
        //delete old name and change text color
        if((range.length == 0) && (range.location == 0)&& (textField.text.length >0)){
            textField.text = @"";
            textField.textColor = [UIColor darkTextColor];
        }
        string = [string uppercaseString];
    }
    return YES;
}



-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"Did begin editing");
    UITextPosition *positionBeginning = [textField beginningOfDocument];
    UITextRange *textRange =[textField textRangeFromPosition:positionBeginning
                                                  toPosition:positionBeginning];
    [textField setSelectedTextRange:textRange];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"Did end edditing");
}


#pragma mark VIEW DID LOAD
-(void) viewDidLayoutSubviews{
    self.tableViewDocuments.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.tableViewDocuments.frame = CGRectMake(0, 129, 320, 395);
    [self.tableViewDocuments reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkNameRepository];
    /*
    self.tableViewDocuments.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.tableViewDocuments.frame = CGRectMake(0, 129, 320, 395);
    [self.tableViewDocuments reloadData];
    */

    //to dissmis view controller - need for password enter after background
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(appDidGoToBackground)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:[UIApplication sharedApplication]];
    
}

-(void) appDidGoToBackground
{
   [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    [self userDidEndEditOrNotStart];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSString*)checkAndRemoveSpasesAtTheEndOfString:(NSString*)inputStr{
    NSString *outStr = @"";
    if([[inputStr substringFromIndex:(inputStr.length-1)] isEqualToString:@" "]){
        outStr = [self checkAndRemoveSpasesAtTheEndOfString:[inputStr substringToIndex:(inputStr.length-1)]];
    } else {
        outStr = inputStr;
    }
    return outStr;
}
-(NSString*) letterAddition:(NSString*)inputStr{
    NSString *outStr = @"";
    NSString *lasSymbol = [inputStr substringToIndex:(inputStr.length)];
    NSString *preLastSymbol = [inputStr substringWithRange:NSMakeRange((inputStr.length -2), 1)];
    
    NSSet* aSet = [[NSSet alloc] initWithObjects:@"2",@"3",@"4", nil];
    if([lasSymbol isEqualToString:@"1"] && (![preLastSymbol isEqualToString:@"1"])){
        outStr = [inputStr stringByAppendingString:@" документ"];
    } else if([aSet containsObject:lasSymbol] && ![preLastSymbol isEqualToString:@"1"]){
        outStr = [inputStr stringByAppendingString:@" документа"];
    } else {
        outStr = [inputStr stringByAppendingString:@" документов"];
    }

    return outStr;
}

@end
