//
//  RepositoryViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 07.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "RepositoryViewController.h"

@interface RepositoryViewController () <UITextFieldDelegate, CoorinatorProtocol, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelAskUserEnterNameRepository;
@property (weak, nonatomic) IBOutlet UITextField *textFildRepositoryName;

@property (weak, nonatomic) IBOutlet UIButton *buttonEditDone;
@property (weak, nonatomic) IBOutlet UIStackView *stackViewOfDocuments;


@end

@implementation RepositoryViewController
#pragma mark PROPERTIES SETUP


-(void)setCoordinatorCoreDate:(CoordinatorCoreDate *)coordinatorCoreDate{
    _coordinatorCoreDate = coordinatorCoreDate;
    _coordinatorCoreDate.delegatedByDocuments = self;
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
                                                                         handler:^(UIAlertAction * action) {[self enterEnotherName];}];
            
            [alert addAction:defaultAction];
            [alert addAction:enterOtherNameAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [self userDidEndEditOrNotStart];
    }
}
-(void) enterEnotherName {
    [self checkNameRepository:nil];
}
-(void)checkNameRepository:(NSString *)nameRepository {
    _nameRepository = nameRepository;
    if(nameRepository == nil){ //there is new repository screen
        self.textFildRepositoryName.text =[self.coordinatorCoreDate getPossibleNameFromRepositoryWithInitial: @"Самое Важное"];
        self.textFildRepositoryName.textColor = [UIColor lightGrayColor];
        self.textFildRepositoryName.enabled = YES;
        [self.textFildRepositoryName becomeFirstResponder];
        
        self.buttonEditDone.titleLabel.text = @"Готово";
        
        self.labelAskUserEnterNameRepository.text = @"Введите имя раздела";
    } else { //there is exsist repository screen
        self.textFildRepositoryName.text = nameRepository;
        [self userDidEndEditOrNotStart];

    }
}
-(void) userDidEndEditOrNotStart{


    if(self.textFildRepositoryName){ //if views are loaded
        self.textFildRepositoryName.textColor = [UIColor darkTextColor];
        self.textFildRepositoryName.enabled = NO;
        [self.textFildRepositoryName resignFirstResponder];
        
        self.buttonEditDone.titleLabel.text = @"Править";
        
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
    self.buttonEditDone.titleLabel.text = @"Готово";
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
    [self checkNameRepository:self.nameRepository];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString *lasSymbol = [inputStr substringToIndex:(inputStr.length -1)];
    NSString *preLastSymbol = [inputStr substringWithRange:NSMakeRange((inputStr.length -2), 1)];
    
    NSSet* aSet = [[NSSet alloc] initWithObjects:@"1",@"2",@"3",@"4", nil];
    if([aSet containsObject:lasSymbol] && ![preLastSymbol isEqualToString:@"1"]){
        outStr = [inputStr stringByAppendingString:@" документа"];
    } else {
        outStr = [inputStr stringByAppendingString:@" документов"];
    }
    
    
    
    return outStr;
}

@end
