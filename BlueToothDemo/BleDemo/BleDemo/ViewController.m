//
//  ViewController.m
//  BleDemo
//
//  Created by linguomao on 2017/11/20.
//  Copyright © 2017年 lin_gm. All rights reserved.
//

#import "ViewController.h"
#import "BeCentralVewController.h"
#import "BePeripheralViewController.h"

@interface ViewController (){
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (IBAction)beCentral:(id)sender {
    BeCentralVewController *vc = [[BeCentralVewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)bePeripheral:(id)sender {
    BePeripheralViewController *vc = [[BePeripheralViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
