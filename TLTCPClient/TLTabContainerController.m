//
//  TLTabContainerController.m
//  TLTCPClient
//
//  Created by lichuanjun on 15/9/29.
//  Copyright © 2015年 lichuanjun. All rights reserved.
//

#import "TLTabContainerController.h"

#import "TCPSocketViewController.h"
#import "UDPSocketViewController.h"

@interface TLTabContainerController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) NSArray *tabNavsArr;

@end

@implementation TLTabContainerController

IMP_SINGLETON(TLTabContainerController);

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    TCPSocketViewController *tcpController = [[TCPSocketViewController alloc] init];
    UDPSocketViewController *udpController = [[UDPSocketViewController alloc] init];
    
    UINavigationController *navi_0 = [[UINavigationController alloc] initWithRootViewController:tcpController];
    UINavigationController *navi_1 = [[UINavigationController alloc] initWithRootViewController:udpController];
  
    self.tabNavsArr = [NSArray arrayWithObjects:navi_0, navi_1, nil];
    
    navi_0.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"TCP" image:[UIImage imageNamed:@"tab_home.png"] selectedImage:[UIImage imageNamed:@"tab_home_selected.png"]];
    navi_1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"UDP" image:[UIImage imageNamed:@"tab_home.png"] selectedImage:[UIImage imageNamed:@"tab_home_selected.png"]];
  
    navi_0.tabBarItem.tag = 0;
    navi_1.tabBarItem.tag = 1;
    
    [self setViewControllers:[NSArray arrayWithObjects:navi_0, navi_1 ,nil]];
   
    self.tabBar.translucent = YES;
    self.tabBar.tintColor = [UIColor grayColor];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UINavigationController *)currentNavigationController
{
    return [self.tabNavsArr objectAtIndex:self.selectedIndex];
}

@end
