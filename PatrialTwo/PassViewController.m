//
//  PassViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "PassViewController.h"
static NSString* notPasswordYet; //строка для промежуточного пароля/ Юзер ввел первый раз = ждем повторого введения пароля


NSString *const Pass = @"Pass";

@interface PassViewController ()
@property (weak, nonatomic) IBOutlet UILabel *askingLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelPassTipingView;

@property (nonatomic) NSString* passwordString; //сам пароль? при первом входе nil.от него и пляшем

@property (nonatomic) NSString* workString; //рабочая строка для проверки пароля

@end

@implementation PassViewController
#pragma mark VIEW DID LOAD
- (void)viewDidLoad {
    [super viewDidLoad];
    //NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    //self.passwordString = [cloudStore objectForKey:@"myString"]? [cloudStore objectForKey:@"myString"]: nil;
    
    //or
    //паорль из дефолта
    self.passwordString = [[NSUserDefaults standardUserDefaults] valueForKey:Pass]?
    [[NSUserDefaults standardUserDefaults] valueForKey:Pass]:nil; //если не в дефолте, не было пароля - nil
    

    if(!self.passwordString){
        self.askingLabel.text = @"Для работы с архивом создайте пароль";
    } else {
        self.askingLabel.text = @"Введите пароль";
    }
    self.labelPassTipingView.text = @"";
    
    self.workString = @"";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BUTTON TAPED ACTION AN REACTION

- (IBAction)buttonTapped:(UIButton *)sender {
    NSString* symbolString = sender.titleLabel.text;
    if([symbolString isEqualToString:@"C"]){
        self.workString = @"";
        self.labelPassTipingView.text = @"";
    }else if([symbolString isEqualToString:@"⌫"]){
        if(self.workString.length > 0){
            self.workString = [self.workString substringToIndex:self.workString.length-1];
            self.labelPassTipingView.text = [self.labelPassTipingView.text substringToIndex:self.labelPassTipingView.text.length-1];
        }
    } else {
        self.labelPassTipingView.text = [self.labelPassTipingView.text stringByAppendingString:@"*"];
        self.workString = [self.workString stringByAppendingString:symbolString];
        
    }
}

//!проверочная функция
-(void)setWorkString:(NSString *)workString
{
    _workString = workString;
    if(_workString.length == 4){//только после введения 4 символов
        if(self.passwordString){ //если пароль уже задан
            if([_workString isEqualToString:self.passwordString]){ //проверка существующего пароля
                [self insertedCorrectPass];
            } else {
                [self insetredNotCorrectPass];
            }
        } else if(notPasswordYet.length == 4){
            if([_workString isEqualToString:notPasswordYet]){ //установка пароля
                [[NSUserDefaults standardUserDefaults] setValue: notPasswordYet forKey:Pass];
                [self insertedCorrectPass];
            } else {
                [self notConfirmedInput]; //не
            }
        } else {
            notPasswordYet = _workString;
            self.askingLabel.text = @"Подтвердите введенный пароль";
            self.labelPassTipingView.text = @"";
            _workString = @"";
        }
    }
}


-(void) insertedCorrectPass{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)insetredNotCorrectPass {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Введен не коректный пароль!"
                                                                   message:@"Пожалуйста, повторите ввод пароля"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              self.workString = @"";
                                                              self.labelPassTipingView.text = @"";
                                                          }];

    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}

-(void) notConfirmedInput {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Не верно"
                                                                   message:@"Пожалуйста, создайте пароль еще раз"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              self.askingLabel.text = @"Для работы с архивом создайте пароль";
                                                              self.workString = @"";
                                                              notPasswordYet = @"";
                                                              self.labelPassTipingView.text = @"";
                                                          }];
    
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
