//
//  TLTabContainerController.h
//  TLTCPClient
//
//  Created by lichuanjun on 15/9/29.
//  Copyright © 2015年 lichuanjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLMacros.h"


@interface TLTabContainerController : UITabBarController

DEF_SINGLETON(TLTabContainerController);

@property (nonatomic, strong) UINavigationController *currentNavigationController;

@end
