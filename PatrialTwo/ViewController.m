//
//  ViewController.m
//  PatrialTwo
//
//  Created by Serge Sychov on 06.02.16.
//  Copyright © 2016 Sergey Sychov. All rights reserved.
//

#import "ViewController.h"
#import "PassViewController.h"

@interface ViewController ()
@property (nonatomic,weak) PassViewController *passViewController;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //load pass view controller
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void) viewDidAppear:(BOOL)animated
{
    PassViewController *passViewController = [[PassViewController alloc] initWithNibName:@"PassController" bundle:nil];
    self.passViewController = passViewController;
    [self presentViewController:self.passViewController animated:NO completion:^{
        nil;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
