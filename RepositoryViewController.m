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
#import "DocumnetViewController.h"

@interface RepositoryViewController () <UITextFieldDelegate, CoorinatorProtocol,NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSArray* documents;

@property (weak, nonatomic) IBOutlet UILabel *labelAskUserEnterNameRepository;
@property (weak, nonatomic) IBOutlet UITextField *textFildRepositoryName;

@property (weak, nonatomic) IBOutlet UIButton *buttonEditDone;
@property (weak, nonatomic) IBOutlet UITableView *tableViewDocuments;

@property (nonatomic,weak) DocumnetViewController *docViewController;


@end

@implementation RepositoryViewController

#pragma mark VIEW DID LOAD

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkNameRepository];
    //to dissmis view controller - need for password enter after background
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(appDidGoToBackground)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:[UIApplication sharedApplication]];
    //catch keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

-(void) appDidGoToBackground //переход на родителя для корректного появления контроллера верификации
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    [self userDidEndEditOrNotStart]; //юзер закончил печатать или не начиал - клавиатура ушла с поля/ Подтверждаем значение оставленное в поле ввода как имя хранилища? делаем изменения видов
}

//для показа документов используем табле вью - надо повернуть
-(void) viewDidLayoutSubviews{

    self.tableViewDocuments.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.tableViewDocuments.frame = CGRectMake(0, 129, 320, 395);
    [self.tableViewDocuments reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:[UIApplication sharedApplication]];
    
}

#pragma mark PROPERTIES SETUP

//если есть имя Хранилища запускам Fetcherа документов и становимся его делегатом
-(void)setRepository:(Repository *)repository{
    _repository = repository;
    id Comparator =^(Document* doc1, Document* doc2){
        return [doc1.numberOrdering compare:doc2.numberOrdering];
    };
    

    self.documents = [[repository.documents allObjects] sortedArrayUsingComparator:Comparator];
}

//call from main controller (fetcher did change)
-(void) repositoryDidChange {
    //NSLog(@"Repository did change");
    id Comparator =^(Document* doc1, Document* doc2){
        return [doc1.numberOrdering compare:doc2.numberOrdering];
    };
    self.documents = [[self.repository.documents allObjects] sortedArrayUsingComparator:Comparator];
    NSLog(@"NSset counts: %@",@(self.documents.count));
}

-(void) setDocuments:(NSArray *)documents{
    
    _documents = documents;
    [self resetLabelAskUserEnterNameRepositoryTextAccordingFetchedObjects];
    if(self.tableViewDocuments){
        [self.tableViewDocuments reloadData];
    }
}

#pragma mark ACTIONS

- (IBAction)backtoArchiveButtonTapped:(id)sender { //обратно
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)buttonEditDoneTapped:(UIButton *)sender { //для изменения пока только имени архива
    if([sender.titleLabel.text isEqualToString:@"Готово"]){
        [self newNameEnteredByUser]; // юзер нажал Готово - значит ввел новое имя, кнопка изменилась на "Править"
    } else {
        [self userWillEdid];// юзер собирается вводить имя - "Готово" для завершения
    }
}
- (IBAction)trashButtonTapped:(id)sender { //удаляем целиком раздел
    if(self.repository){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ВНИМАНИЕ! Все документы данной картотеки будут будут удалены"
                                                                   message:@"Вы уверены, что хотите продолжить удаление картотеки?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Да" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self deleteExistRepository];
                                                              }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Нет" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     nil; }];
    
        [alert addAction:defaultAction];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

-(void) deleteExistRepository
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.coordinatorCoreDate deleteRepository:self.repository];
    }];
}

//создание нового документа
//кнопкой табб бара
- (IBAction)plusTapBarButtonTapped:(id)sender {
    if(self.repository){
    [self createnewDocument:sender];
    }
}

//кнопкой в табл виде
-(void) createnewDocument:(id)sender
{
    if(self.repository){ //don't allow user make photo without repository name
        [self goToImageViewControllerWithDocument:nil];
    }
}

//идем в вид документа с названием ... если название Ноль - идем в тот же Вид, но создавать документ
-(void) goToImageViewControllerWithDocument: (Document*)document
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocumnetViewController *docViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DocumnetViewController"];
    docViewController.document = document;
    docViewController.nameRepository = self.repository.name;
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
        if(indexPath.row < self.documents.count){
            Document *document = [self.documents objectAtIndex:indexPath.row];
            [self goToImageViewControllerWithDocument:document];
        } else {
            [self goToImageViewControllerWithDocument:nil];
        }
    }
}

#pragma mark TABLE VIEW DATA SOURSE
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [self.tableViewDocuments dequeueReusableCellWithIdentifier:@"DocumentCell"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCellGesturRecogniser:)];
    [cell addGestureRecognizer:tapGesture]; //к каждой строчке добавляю тап гестура (или заходим а документ или создаем новый
    
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2); //важно - равернул табле вью? надо вращать обратно
    
    
    if(indexPath.row == [tableView numberOfRowsInSection: 0] - 1){ //последняя строчка, создание новго документа кнопка и лейба
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
        addNewDocumentButton.center = CGPointMake(cell.frame.size.height/2, cell.frame.size.width/2 -50);
        [cell.contentView addSubview:addNewDocumentButton];
        
        UILabel *addNewDocumentLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.height/10,
                                                                                 cell.bounds.size.width*0.7,
                                                                                 cell.bounds.size.height*8/10,
                                                                                 cell.bounds.size.width/3)];
        addNewDocumentLabel.textColor = [UIColor lightGrayColor];
        addNewDocumentLabel.backgroundColor = [UIColor clearColor];
        addNewDocumentLabel.adjustsFontSizeToFitWidth = YES;
        addNewDocumentLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        addNewDocumentLabel.numberOfLines = 0;
        addNewDocumentLabel.text = @"Создайте новый документ";
        
        [cell.contentView addSubview:addNewDocumentLabel];
        
    } else { //остальное берем из CoreData через Фетч контроллера

        //remove old subviews - was several mistakes
        NSArray *arraySubvews = cell.contentView.subviews;
        if(arraySubvews && (arraySubvews.count >0)){
            for (NSInteger i = 0; i < arraySubvews.count; i++){
                UIView* subView = arraySubvews[i];
                [subView removeFromSuperview];
            }
        }
       //Вид из Имаджа
        UIImageView *imageView = [[UIImageView alloc] init];//WithFrame:CGRectInset(cell.bounds, 10., 10.)];
        Document *document = [self.documents objectAtIndex:indexPath.row];

        UIImage *documentImage = [UIImage imageWithData:document.dataDocumnet];
        imageView.image = documentImage;// [UIImage imageWithData:docObj.dataDocumnet];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        CGRect rctNotTransformed = CGRectInset(cell.bounds, 10., 10.);
        imageView.frame = CGRectMake(10.,
                                     10.,
                                     rctNotTransformed.size.height,
                                     rctNotTransformed.size.width);
        imageView.center = CGPointMake(cell.frame.size.height/2, cell.frame.size.width/2 -50);
        [cell.contentView addSubview:imageView];
        UILabel *labelCreateNewDoc = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.height/10,
                                                                               cell.bounds.size.width*0.7,
                                                                               cell.bounds.size.height*8/10,
                                                                               cell.bounds.size.width/3)];
        //Лейба и названия документа
        labelCreateNewDoc.text = document.name;
        labelCreateNewDoc.textColor = [UIColor darkTextColor];
        labelCreateNewDoc.adjustsFontSizeToFitWidth = YES;
        labelCreateNewDoc.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        labelCreateNewDoc.numberOfLines = 0;
        labelCreateNewDoc.textAlignment = NSTextAlignmentCenter;
        
        [cell.contentView addSubview:labelCreateNewDoc];

        return cell;

    }
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSInteger rows = 1;
    
    if(self.repository){
        rows = [self.repository.documents count]+1;
    }
    return rows;
}

#pragma mark TEXT EDID FUNCTIONS
-(void)newNameEnteredByUser{
    self.textFildRepositoryName.textColor = [UIColor darkTextColor];
    //check symbol spase at the end. if is - remove it
    NSString *userOfferedName = [self checkAndRemoveSpasesAtTheEndOfString:self.textFildRepositoryName.text];
    NSString *oldRepositoryName;
    if(self.repository){
       oldRepositoryName = self.repository.name;
    } else {
        oldRepositoryName = nil;
    }
    if(![userOfferedName isEqualToString:oldRepositoryName]){
        
        NSString* offeredByCoordinatorStr = [self.coordinatorCoreDate getPossibleRepositoryNameWithInitial:userOfferedName];
        //check if there is the same name in repository
        //if coordinator offer the same string - so it not repository with this name
        //if no - ok create new repository or rename existing
        if([offeredByCoordinatorStr isEqualToString:userOfferedName]){

            if(oldRepositoryName){ //if not nil - was existing repostory

                self.repository.name = userOfferedName;
            } else { //create ne repository
                self.repository = [self.coordinatorCoreDate addNewRepository:userOfferedName];
            }
            [self userDidEndEditOrNotStart];
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
                                                                         handler:^(UIAlertAction * action) {//self.repository = nil;
                                                                                                            [self checkNameRepository];}];
            
            [alert addAction:defaultAction];
            [alert addAction:enterOtherNameAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [self userDidEndEditOrNotStart];
    }
}

-(void)checkNameRepository {
    
    if(self.repository == nil){ //there is new repository screen
        self.textFildRepositoryName.text =[self.coordinatorCoreDate getPossibleRepositoryNameWithInitial: @"Самое Важное"];
        [self userWillEdid];
        
        self.labelAskUserEnterNameRepository.text = @"Введите имя раздела";
    } else { //there is exsist repository screen
        self.textFildRepositoryName.text = self.repository.name;
        [self userDidEndEditOrNotStart];

    }
}
-(void) userDidEndEditOrNotStart{


    if(self.textFildRepositoryName){ //if views are loaded
        self.textFildRepositoryName.textColor = [UIColor darkTextColor];
        self.textFildRepositoryName.enabled = NO;
        [self.textFildRepositoryName resignFirstResponder];
        
        [self.buttonEditDone setTitle:@"Правка" forState:UIControlStateNormal];
        
        [self resetLabelAskUserEnterNameRepositoryTextAccordingFetchedObjects];
    }
}

-(void) resetLabelAskUserEnterNameRepositoryTextAccordingFetchedObjects {
    NSString *countStr = [@(self.repository.documents.count) stringValue];
    
    //right grammar
    countStr = [self letterAddition:countStr];
    NSString *labelStr = @"В разделе ";
    labelStr = [labelStr stringByAppendingString:countStr];
    self.labelAskUserEnterNameRepository.text = labelStr;
}

-(void) userWillEdid {
    self.textFildRepositoryName.textColor = [UIColor lightGrayColor];
    self.textFildRepositoryName.enabled = YES;
    [self.textFildRepositoryName becomeFirstResponder];
    [self.buttonEditDone setTitle:@"Готово" forState:UIControlStateNormal];

    self.labelAskUserEnterNameRepository.text = @"Введите имя раздела";
}


#pragma mark TEXT FILD DELEGATE
//обработка ввода текста пользователем
//после завершения появляется имя хранилища (создаем новый или переименовываем)
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
    //NSLog(@"Did begin editing");
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
