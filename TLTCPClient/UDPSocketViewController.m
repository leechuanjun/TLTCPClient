//
//  UDPSocketViewController.m
//  TLTCPClient
//
//  Created by lichuanjun on 15/9/29.
//  Copyright © 2015年 lichuanjun. All rights reserved.
//

#import "UDPSocketViewController.h"

@implementation UDPSocketViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"UDP网络测试";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
