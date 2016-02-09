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

@interface RepositoryViewController () <UITextFieldDelegate, CoorinatorProtocol,HorizontalScrollerDelegate,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelAskUserEnterNameRepository;
@property (weak, nonatomic) IBOutlet UITextField *textFildRepositoryName;

@property (weak, nonatomic) IBOutlet UIButton *buttonEditDone;
@property (weak, nonatomic) IBOutlet HorizontalScrollerView *horizontalScrollerView;

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
    [self.horizontalScrollerView reload];
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
    [self goToImageViewControllerWithDocument:nil];
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
#pragma mark HORIZONTAL SCROLLER DELEGATE
-(void) horizontalScroller:(HorizontalScrollerView *)scroller clickedViewAtIndex:(NSInteger)index{
    if(index < self.coordinatorCoreDate.docFetchController.fetchedObjects.count){
        [self goToImageViewControllerWithDocument:self.coordinatorCoreDate.docFetchController.fetchedObjects[index]];
    } else {
        [self goToImageViewControllerWithDocument:nil];
    }
}

-(NSInteger)numberOfViewForHorizontalScroller:(HorizontalScrollerView *)scroller{
    NSInteger number = 1;
    if(self.coordinatorCoreDate.docFetchController){
        number = self.coordinatorCoreDate.docFetchController.fetchedObjects.count +1;
    }
    return number;
}
-(UIView*)horizontalScroller:(HorizontalScrollerView *)scroller viewAtIndex:(NSInteger)index{
    if(index < self.coordinatorCoreDate.docFetchController.fetchedObjects.count){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.horizontalScrollerView.bounds, 50, 50)];
        Document *docObj = [self.coordinatorCoreDate.docFetchController.fetchedObjects objectAtIndex:index];
        //imageView.image = [UIImage imageWithData:docObj.dataDocumnet];
        UILabel *labelCreateNewDoc = [[UILabel alloc] initWithFrame:CGRectMake(imageView.bounds.size.width/10,
                                                                               imageView.bounds.size.height*0.9,
                                                                               imageView.bounds.size.width*8/10,
                                                                               imageView.bounds.size.height/3)];
        labelCreateNewDoc.text = docObj.nameDocument;
        labelCreateNewDoc.textColor = [UIColor lightGrayColor];
        labelCreateNewDoc.adjustsFontSizeToFitWidth = YES;
        labelCreateNewDoc.numberOfLines = 0;
        labelCreateNewDoc.textAlignment = NSTextAlignmentCenter;
        
        [imageView addSubview:labelCreateNewDoc];
        return imageView;

    } else {
        UIView *viewNewDoc = [[UIView alloc] initWithFrame:CGRectInset(self.horizontalScrollerView.bounds, 50., 50.)];
        viewNewDoc.autoresizesSubviews = YES;
        viewNewDoc.clipsToBounds = NO;
        viewNewDoc.backgroundColor = [UIColor colorWithWhite:.9 alpha:0.5];
        viewNewDoc.layer.shadowColor =[UIColor blackColor].CGColor;
        viewNewDoc.layer.shadowOffset = CGSizeMake(5., 5.);
        viewNewDoc.layer.shadowRadius = 5.;
        viewNewDoc.layer.shadowOpacity = 0.5;
        
        
        
        //add pluss button
        
        PlusButton *plusButton = [[PlusButton alloc] initWithFrame:CGRectMake(0, 0, 80., 80.)];
        [plusButton addTarget:self action:@selector(createnewDocument:) forControlEvents:UIControlEventTouchUpInside];
        [viewNewDoc addSubview:plusButton];
        plusButton.center = CGPointMake(viewNewDoc.bounds.size.width/2, viewNewDoc.bounds.size.height/2);
        
       
        UILabel *labelCreateNewDoc = [[UILabel alloc] initWithFrame:CGRectMake(viewNewDoc.bounds.size.width/10,
                                                                               viewNewDoc.bounds.size.height*0.9,
                                                                               viewNewDoc.bounds.size.width*8/10,
                                                                               viewNewDoc.bounds.size.height/3)];
        labelCreateNewDoc.text = @"Добавить новый документ";
        labelCreateNewDoc.textColor = [UIColor lightGrayColor];
        labelCreateNewDoc.adjustsFontSizeToFitWidth = YES;
        labelCreateNewDoc.numberOfLines = 0;
        labelCreateNewDoc.textAlignment = NSTextAlignmentCenter;
        
        [viewNewDoc addSubview:labelCreateNewDoc];

        return viewNewDoc;
    }
}

#pragma mark COORDINATOR DELEGATE
-(NSString*)documentsRepositoryName{
    return self.nameRepository;
}

-(void) DocumentsAreChanged
{
    
}
#pragma mark FETCHED RESULT CONTROLLER DELEGATE


#pragma mark TEXT EDID FUNCTIONS
-(void)newNameEnteredByUser{
    self.textFildRepositoryName.textColor = [UIColor darkTextColor];
    //check symbol spase at the end. if is - remove it
    NSString *userOfferedName = [self checkAndRemoveSpasesAtTheEndOfString:self.textFildRepositoryName.text];
    NSString *oldRepositoryName = self.nameRepository;
    if(![userOfferedName isEqualToString:oldRepositoryName]){
        
        NSString* offeredByCoordinatorStr = [self.coordinatorCoreDate getPossibleNameFromRepositoryWithInitial:userOfferedName];
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
        self.textFildRepositoryName.text =[self.coordinatorCoreDate getPossibleNameFromRepositoryWithInitial: @"Самое Важное"];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkNameRepository];
    self.horizontalScrollerView.delegate = self;
    [self.horizontalScrollerView reload];
    // Do any additional setup after loading the view.

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
