//
//  TCPSocketViewController.m
//  TLTCPClient
//
//  Created by lichuanjun on 15/9/29.
//  Copyright © 2015年 lichuanjun. All rights reserved.
//

#import "TCPSocketViewController.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
#import <Masonry/Masonry.h>
#import <Mantle/EXTScope.h>

@interface TCPSocketViewController ()<UITextFieldDelegate>
{
    AsyncSocket *socket;
    int nClickFlag;
}

@property (nonatomic, strong) UITextView *receiveDataView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITextField *clientIPAddrText;
@property (nonatomic, strong) UITextField *sendMessageText;

@end


@implementation TCPSocketViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"TCP网络测试";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initInterface];
    
    self.receiveDataView.editable=NO;
    
    self.clientIPAddrText.delegate=self;
    [self.clientIPAddrText setTag:1];
    self.sendMessageText.delegate=self;
    [self.sendMessageText setTag:2];
    nClickFlag = 0;
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationPortrait;
}

// 初始化界面
-(void) initInterface {
    self.receiveDataView = [[UITextView alloc] init];
    [self.view addSubview:self.receiveDataView];
    
    UILabel *labelStatus = [UILabel new];
    labelStatus.text = @"Status: ";
    [self.view addSubview:labelStatus];
    self.statusLabel = [UILabel new];
    [self.view addSubview:self.statusLabel];
    
    UILabel *clientIPAddrLabel = [UILabel new];
    clientIPAddrLabel.text = @"Client IP: ";
    [self.view addSubview:clientIPAddrLabel];
    self.clientIPAddrText = [UITextField new];
    self.clientIPAddrText.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.clientIPAddrText];
    
    UIButton *connectButton = [UIButton new];
    [connectButton setTitle:@"connect" forState:UIControlStateNormal];
    [connectButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    connectButton.backgroundColor = [UIColor whiteColor];
    connectButton.layer.borderWidth = 1;
    connectButton.layer.borderColor = [[UIColor brownColor] CGColor];
    [connectButton addTarget:self action:@selector(connectServer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectButton];
    
    self.sendMessageText = [UITextField new];
    self.sendMessageText.backgroundColor = [UIColor colorWithWhite:0.38 alpha:8.000];
    [self.view addSubview:self.sendMessageText];
    
    UIButton *sendButton = [UIButton new];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    sendButton.layer.borderColor = [[UIColor brownColor] CGColor];
    sendButton.layer.borderWidth = 1;
    [sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    @weakify(self);
    
    //将图层的边框设置为圆脚
    self.receiveDataView.layer.cornerRadius = 5;
    self.receiveDataView.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    self.receiveDataView.layer.borderWidth = 1;
    self.receiveDataView.layer.borderColor = [[UIColor colorWithWhite:0.521 alpha:1.000] CGColor];
    self.receiveDataView.backgroundColor = [UIColor grayColor];
    
    [self.receiveDataView mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.top.equalTo(self.view.mas_top).with.offset(70);
        make.left.equalTo(self.view).with.offset(10);
        make.right.equalTo(self.view).with.offset(-10);
        make.height.equalTo(self.view).dividedBy(2.5);
    }];
    
    [labelStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.receiveDataView);
        make.top.equalTo(self.receiveDataView.mas_bottom).with.offset(10);
        make.width.equalTo(self.receiveDataView).with.dividedBy(4.8f/1.f);
    }];
    
    self.statusLabel.text = @"Linking...";
    self.statusLabel.textColor = [UIColor redColor];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(labelStatus.mas_right);
        make.top.equalTo(labelStatus);
        make.right.equalTo(self.receiveDataView);
        make.bottom.equalTo(labelStatus);
    }];
    
    [clientIPAddrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(labelStatus);
        make.top.equalTo(labelStatus.mas_bottom).with.offset(10);
        make.width.equalTo(self.receiveDataView).with.dividedBy(4.8f/1.f);
    }];
    [self.clientIPAddrText mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(clientIPAddrLabel.mas_right);
        make.top.equalTo(clientIPAddrLabel);
        make.width.equalTo(self.receiveDataView).with.dividedBy(1.7f/1.f);
        make.bottom.equalTo(clientIPAddrLabel);
    }];
    [connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.clientIPAddrText.mas_right).offset(5);
        make.top.equalTo(clientIPAddrLabel);
        make.right.equalTo(self.statusLabel.mas_right);
        make.bottom.equalTo(clientIPAddrLabel);
    }];
    
    
    self.sendMessageText.text = @"hello world!";
    [self.sendMessageText mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.receiveDataView);
        make.top.equalTo(self.clientIPAddrText.mas_bottom).with.offset(10);
        make.width.equalTo(self.receiveDataView);
        make.height.equalTo(@50);
    }];
    
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.receiveDataView);
        make.top.equalTo(self.sendMessageText.mas_bottom).with.offset(10);
        make.width.equalTo(self.receiveDataView);
        make.height.equalTo(@40);
    }];
    
}



#pragma mark - hundle event

-(void) connectServer {
    NSLog(@"Connecct server!!!");
}

-(void) sendMessage {
    NSLog(@"send Message!!!");
}

#pragma mark - text delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField tag] == 2)
    {
        [self viewUp];
        nClickFlag = 2;
    }
    
    if ([textField tag] == 1) {
        nClickFlag = 1;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    if([textField tag] == 2)
    {
        [self viewDown];
        nClickFlag = 2;
    }
    
    if ([textField tag] == 1) {
        nClickFlag = 1;
    }
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //隐藏键盘
    if (nClickFlag == 1) {
        [self.clientIPAddrText resignFirstResponder];
    }
    
    if (nClickFlag == 2) {
        [self.sendMessageText resignFirstResponder];
        [self viewDown];
    }
}

- (void) viewUp
{
    CGRect frame=self.view.frame;
    frame.origin.y=frame.origin.y-190;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame=frame;
    [UIView commitAnimations];
}

- (void) viewDown
{
    CGRect frame=self.view.frame;
    frame.origin.y=frame.origin.y+190;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame=frame;
    [UIView commitAnimations];
}

@end
