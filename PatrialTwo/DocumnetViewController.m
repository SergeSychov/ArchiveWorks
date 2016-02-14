//
//  documnetViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 08.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "DocumnetViewController.h"

@interface DocumnetViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CoorinatorProtocol, UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *buttonMakePhoto;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImage;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImagePickerController *pickerController;

@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UITextField *textFildDocumetnName;
@property (weak, nonatomic) IBOutlet UILabel *labelAskUserEnterName;

@property (nonatomic) NSString *documentName;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditDone;

@end

@implementation DocumnetViewController
#pragma mark VIEW DID LOAD
- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkNameDocument];
    if(!self.document){
        [self setupPickerView];
    } else {
        [self setupEditViews];
        if(self.document.bigImageData){ //if there is big data, strored - ok run it
            self.imageView.image = [UIImage imageWithData:self.document.bigImageData.data];
        } else { //if no use scaled version
            self.imageView.image = [UIImage imageWithData:self.document.dataDocumnet];
        }
        
    }
    self.textFildDocumetnName.delegate = self;
    
    
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
-(void) appDidGoToBackground
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    [self userDidEndEditOrNotBegunEdit];
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:[UIApplication sharedApplication]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark INITIAL SETUP
-(void) setDocument:(Document *)document{
    _document = document;
    
    if(!document){
        //[self setupPickerView]; not works fronm here - is no vuews YEt
        _documentName = nil;
    } else {
        //[self setupEditViews]; not works fronm here - is no vuews YEt
        _documentName = document.name;
        [self userDidEndEditOrNotBegunEdit];
    }

}
-(void) setupPickerView {
    self.pickerContainerView.alpha = 1.;
    self.pickerContainerView.hidden = NO;
    
}
-(void) setupEditViews{
    self.pickerContainerView.alpha = 0.;
    self.pickerContainerView.hidden = YES;

}

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
- (IBAction)trashButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.coordinatorCoreDate deleteDocumetn:self.document];
    }];
}
- (IBAction)rotationButtonTaped:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    } completion:^(BOOL finished) {
        [self.coordinatorCoreDate rotateImageofDocument:self.document];
    }];
}


/*
-(void) setCoordinatorCoreDate:(CoordinatorCoreDate *)coordinatorCoreDate{
    _coordinatorCoreDate = coordinatorCoreDate;
    //_coordinatorCoreDate.delegatedByDocuments = self;
}
*/
#pragma mark SCROLL VIEW DELEGATE
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}
#pragma mark COORDINATOR DELEGATE
-(NSString*)documentsRepositoryName{
    return self.documentsRepositoryName;
}

#pragma IMAGE PICKER DELEGATE
//получаем картинки и идем присваивать имя - документ пока не создаем
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.imageView setImage:image];

    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
    [self userWillEdid];
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
        self.textFildDocumetnName.text =[self.coordinatorCoreDate getPossibleRepositoryNameWithInitial: self.nameRepository];
       // [self userWillEdid];
        
        self.labelAskUserEnterName.text = @"Введите имя документа";
    } else { //there is exsist repository screen
        self.textFildDocumetnName.text = self.documentName;
        [self userDidEndEditOrNotBegunEdit];
        
    }
}
//2. действия при установке пользователем нового имени
//  Если совпадает с уже существующим - ничего не делаем? завершаем режим правки
// Если имя не уникальное предлагет выбрать из предложенного или ввести заново
-(void)newNameEnteredByUser{

    self.textFildDocumetnName.textColor = [UIColor darkTextColor];
    //check symbol spase at the end. if is - remove it
    NSString *userOfferedName = [self checkAndRemoveSpasesAtTheEndOfString:self.textFildDocumetnName.text];
    NSString *oldDocumetName = self.documentName;
    if(![userOfferedName isEqualToString:oldDocumetName]){
        
        NSString* offeredByCoordinatorStr = [self.coordinatorCoreDate getPossibleDocumentNameWithInitial:userOfferedName];
        //check if there is the same name in repository
        //if coordinator offer the same string - so it not repository with this name
        //if no - ok create new repository or rename existing
        if([offeredByCoordinatorStr isEqualToString:userOfferedName]){
            self.documentName = userOfferedName;
            if(oldDocumetName){ //if not nel - was existing repostory

            } else { //create ne repository
               
                self.document =[self.coordinatorCoreDate addNewDocumentWith:self.imageView.image name:self.documentName andRepositoryName:self.nameRepository];
                /* ... Do whatever you need to do ... */
                
                                

            }
        } else { //if Yes - show allert controller to change it name
            self.textFildDocumetnName.text = offeredByCoordinatorStr;
            NSString *offerUser = @"Предлагаю: ";
            offerUser = [offerUser stringByAppendingString:offeredByCoordinatorStr];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Такое имя уже присвоено одному из Ваших документов"
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
        [self userDidEndEditOrNotBegunEdit];
    }
}
-(void) enterAnotherName {
    self.documentName = nil;
    [self checkNameDocument];
}
-(void) userDidEndEditOrNotBegunEdit{
    
    
    if(self.textFildDocumetnName){ //if views are loaded
        self.textFildDocumetnName.textColor = [UIColor darkTextColor];
        self.textFildDocumetnName.enabled = NO;
        [self.textFildDocumetnName resignFirstResponder];
        
        self.labelAskUserEnterName.hidden = YES;
    }
}

-(void) userWillEdid {
    self.textFildDocumetnName.textColor = [UIColor lightGrayColor];
    self.textFildDocumetnName.enabled = YES;
    [self.textFildDocumetnName becomeFirstResponder];
 
    self.labelAskUserEnterName.text = @"Введите имя документа";
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
   // NSLog(@"Did begin editing");
    UITextPosition *positionBeginning = [textField beginningOfDocument];
    UITextRange *textRange =[textField textRangeFromPosition:positionBeginning
                                                  toPosition:positionBeginning];
    [textField setSelectedTextRange:textRange];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"Did end edditing");
}




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
