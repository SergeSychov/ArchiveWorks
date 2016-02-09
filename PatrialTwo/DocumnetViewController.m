//
//  documnetViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 08.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "DocumnetViewController.h"

@interface DocumnetViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CoorinatorProtocol,NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *buttonMakePhoto;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImagePickerController *pickerController;

@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UITextField *textFildDocumetnName;
@property (weak, nonatomic) IBOutlet UILabel *labelAskUserEnterName;

@property (nonatomic) NSString *documentName;

@end

@implementation DocumnetViewController
#pragma mark ACTION

- (IBAction)makePhotoButtonTouched:(UIButton *)sender {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Камера не доступна"
                                                                       message:@"Воспользуйтесь изображениями из медиатеки программы Фото"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {self.buttonMakePhoto.enabled = NO;}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.showsCameraControls = YES;
        self.pickerController = pickerController;
        
        
        [self presentViewController:self.pickerController animated:YES completion:nil];
    }
}
- (IBAction)chooseGalleryButtonTapped:(UIButton *)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.pickerController = pickerController;
    [self presentViewController:self.pickerController animated:YES completion:nil];
}
- (IBAction)backToRepositoryButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

#pragma mark SET EDIT OR PICKERS VIEWS
-(void) setupPickerView {
    self.pickerContainerView.alpha = 1.;
    self.pickerContainerView.hidden = NO;
}
-(void) setupEditViews{
    self.pickerContainerView.alpha = 0.;
    self.pickerContainerView.hidden = YES;
}
#pragma mark SETTERS
-(void) setDocument:(Document *)document{
    _document = document;
    
    if(document == nil){
        [self setupPickerView];
        _documentName = nil;
    } else {
        [self setupEditViews];
        _documentName = document.nameDocument;
        
    }
    self.imageView.image = [UIImage imageWithData:document.dataDocumnet];
}

-(void) setCoordinatorCoreDate:(CoordinatorCoreDate *)coordinatorCoreDate{
    _coordinatorCoreDate = coordinatorCoreDate;
    //_coordinatorCoreDate.delegatedByDocuments = self;
}
#pragma mark COORDINATOR DELEGATE
-(NSString*)documentsRepositoryName{
    return self.documentsRepositoryName;
}

#pragma IMAGE PICKER DELEGATE
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.imageView setImage:image];
    [self.coordinatorCoreDate addNewDocumentWith:image name:self.nameRepository andRepositoryName:self.nameRepository];
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
    [self setupEditViews];
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TEXT EDID FUNCTIONS
//1. проверим имя документа: если nil - предложим ввсести новое, предварительно установив возможное имя
//проверку возможного имени осуществим в координаторе
-(void)checkNameDocument{
    
    if(self.documentName == nil){ //there is new repository screen
        self.textFildDocumetnName.text =[self.coordinatorCoreDate getPossibleNameFromRepositoryWithInitial: @"Самое Важное"];
        [self userWillEdid];
        
        self.labelAskUserEnterName.text = @"Введите имя документа";
    } else { //there is exsist repository screen
        self.textFildDocumetnName.text = self.documentName;
        [self userDidEndEditOrNotStart];
        
    }
}
-(void)newNameEnteredByUser{
    self.textFildDocumetnName.textColor = [UIColor darkTextColor];
    //check symbol spase at the end. if is - remove it
    NSString *userOfferedName = [self checkAndRemoveSpasesAtTheEndOfString:self.textFildDocumetnName.text];
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
            self.textFildDocumetnName.text = offeredByCoordinatorStr;
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
    self.documentName = nil;
    [self checkNameDocument:nil];
}
-(void)checkNameDocument{

    if(self.documentName == nil){ //there is new repository screen
        self.textFildDocumetnName.text =[self.coordinatorCoreDate getPossibleNameFromRepositoryWithInitial: @"Самое Важное"];
        [self userWillEdid];
        
        self.labelAskUserEnterName.text = @"Введите имя документа";
    } else { //there is exsist repository screen
        self.textFildDocumetnName.text = nameRepository;
        [self userDidEndEditOrNotStart];
        
    }
}
-(void) userDidEndEditOrNotStart{
    
    
    if(self.textFildDocumetnName){ //if views are loaded
        self.textFildDocumetnName.textColor = [UIColor darkTextColor];
        self.textFildDocumetnName.enabled = NO;
        [self.textFildDocumetnName resignFirstResponder];
        
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
    self.textFildDocumetnName.textColor = [UIColor lightGrayColor];
    self.textFildDocumetnName.enabled = YES;
    [self.textFildDocumetnName becomeFirstResponder];
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


- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(appDidGoToBackground)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    


    // Do any additional setup after loading the view.
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

@end
