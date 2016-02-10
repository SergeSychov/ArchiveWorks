//
//  PassViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "PassViewController.h"
static NSString* notPasswordYet;


NSString *const Pass = @"Pass";

@interface PassViewController ()
@property (weak, nonatomic) IBOutlet UILabel *askingLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelPassTipingView;

@property (nonatomic) NSString* passwordString;
//@property (nonatomic) NSString *notPasswordYet;
@property (nonatomic) NSString* workString;

@end

@implementation PassViewController


-(void)setWorkString:(NSString *)workString
{
    _workString = workString;
    if(_workString.length == 4){
        if(self.passwordString){ //если пароль уже задан
            if([_workString isEqualToString:self.passwordString]){
                [self insertedCorrectPass];
            } else {
                [self insetredNotCorrectPass];
            }
        } else if(notPasswordYet.length == 4){
            if([_workString isEqualToString:notPasswordYet]){
                [[NSUserDefaults standardUserDefaults] setValue: notPasswordYet forKey:Pass];
                [self insertedCorrectPass];
            } else {
                [self notConfirmedInput];
            }
        } else {
            notPasswordYet = _workString;
            self.askingLabel.text = @"Подтвердите введенный пароль";
            self.labelPassTipingView.text = @"";
            _workString = @"";
        }
    }
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    //self.passwordString = [cloudStore objectForKey:@"myString"]? [cloudStore objectForKey:@"myString"]: nil;
    
    //or
    self.passwordString = [[NSUserDefaults standardUserDefaults] valueForKey:@"PASS"]?
    [[NSUserDefaults standardUserDefaults] valueForKey:@"PASS"]:nil;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
