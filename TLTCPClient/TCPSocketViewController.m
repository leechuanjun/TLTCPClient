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
    BOOL bDownUp;
}

@property (nonatomic, strong) UITextView *receiveDataView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITextField *clientIPAddrText;
@property (nonatomic, strong) UITextField *clientPortText;
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
    self.clientPortText.delegate = self;
    [self.clientPortText setTag:2];
    self.sendMessageText.delegate=self;
    [self.sendMessageText setTag:3];
    
    self.clientIPAddrText.text = @"127.0.0.1";
    self.clientPortText.text = @"22533";
    
    nClickFlag = 0;
    bDownUp = NO;
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

-(void)scrollOutputToBottom {
    CGPoint p = [self.receiveDataView contentOffset];
    [self.receiveDataView setContentOffset:p animated:NO];
    [self.receiveDataView scrollRangeToVisible:NSMakeRange([self.receiveDataView.text length], 0)];
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
    
    // IP地址
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
    
    // 端口号
    UILabel *clientPortLabel = [UILabel new];
    clientPortLabel.text = @"Client Port: ";
    [self.view addSubview:clientPortLabel];
    self.clientPortText = [UITextField new];
    self.clientPortText.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.clientPortText];
    
    // 发送文本
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
        make.width.equalTo(self.receiveDataView).with.dividedBy(3.7f/1.f);
    }];
    [self.clientIPAddrText mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(clientIPAddrLabel.mas_right);
        make.top.equalTo(clientIPAddrLabel);
        make.width.equalTo(self.receiveDataView).with.dividedBy(2.0f/1.f);
        make.bottom.equalTo(clientIPAddrLabel);
    }];
    
    [clientPortLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(clientIPAddrLabel);
        make.top.equalTo(clientIPAddrLabel.mas_bottom).with.offset(10);
        make.width.equalTo(self.receiveDataView).with.dividedBy(3.7f/1.f);
    }];
    [self.clientPortText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(clientPortLabel.mas_right);
        make.top.equalTo(clientPortLabel);
        make.right.equalTo(self.clientIPAddrText);
        make.height.equalTo(self.clientIPAddrText);
        make.bottom.equalTo(clientPortLabel);
    }];
    
    [connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.clientPortText.mas_right).offset(5);
        make.top.equalTo(clientPortLabel);
        make.right.equalTo(self.statusLabel.mas_right);
        make.bottom.equalTo(clientPortLabel);
    }];
    
    self.sendMessageText.text = @"";
    [self.sendMessageText mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.receiveDataView);
        make.top.equalTo(self.clientPortText.mas_bottom).with.offset(10);
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
    NSLog(@"start Connecct server!!!");
    if(socket==nil)
    {
        socket=[[AsyncSocket alloc] initWithDelegate:self];
        NSError *error=nil;
        if(![socket connectToHost:self.clientIPAddrText.text onPort:[self.clientPortText.text intValue] error:&error])
        {
            self.statusLabel.text=@"连接服务器失败!";
        }
        else
        {
            self.statusLabel.text=@"已连接!";
        }
    }
    else
    {
        self.statusLabel.text=@"已连接!";
    }
}

-(void) sendMessage {
    if(![self.sendMessageText.text isEqualToString:@""] && ![self.clientIPAddrText.text isEqualToString:@""])
    {
        NSString *message=[NSString stringWithFormat:@"%@:%@",self.clientIPAddrText.text,self.sendMessageText.text];
        if(socket==nil)
        {
            socket=[[AsyncSocket alloc] initWithDelegate:self];
        }
        NSString *content=[message stringByAppendingString:@"\r\n"];
        [socket writeData:[content dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        
        
        NSString *strChatContent = [NSString stringWithFormat:@"me:%@\r\n",self.sendMessageText.text];
    
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:strChatContent];
        NSRange numberRange = [strChatContent rangeOfString:@"me:"];
        NSUInteger intergerLen = (numberRange.location == NSNotFound) ? [strChatContent length] : numberRange.location;
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(intergerLen, numberRange.length)];
        
        [[self.receiveDataView textStorage] appendAttributedString:attriString];
        [self scrollOutputToBottom];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Waring" message:@"Please input Message!" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            // 回调在block里面
            return ;
        }];
        [alert addAction:actionOK];
    }
    
}

#pragma mark - text delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField tag] == 1) {
        nClickFlag = 1;
    }
    
    if([textField tag] == 2)
    {
        nClickFlag = 2;
    }
    
    if ([textField tag] == 3) {
        nClickFlag = 3;
    }
    
    if (!bDownUp) {
        [self viewUp];
        bDownUp = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    
    if ([textField tag] == 1) {
        nClickFlag = 1;
    }
    
    if([textField tag] == 2)
    {
        nClickFlag = 2;
    }
    
    if ([textField tag] == 3) {
        nClickFlag = 3;
    }
    
    if (bDownUp) {
        [self viewDown];
        bDownUp = NO;
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
        [self.clientPortText resignFirstResponder];
    }
    
    if (nClickFlag == 3) {
        [self.sendMessageText resignFirstResponder];
    }
    
    if (bDownUp) {
        [self viewDown];
        bDownUp = NO;
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


#pragma AsyncScoket Delagate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu",sock,host,port);
    
    [sock readDataWithTimeout:1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];  // 这句话仅仅接收\r\n的数据
    
    [sock readDataWithTimeout: -1 tag: 0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Hava received datas is :%@",aStr);
    
    NSString *strChatContent = [NSString stringWithFormat:@"%@",aStr];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:strChatContent];
    NSRange numberRange = [strChatContent rangeOfString:@":"];
    NSUInteger intergerLen = (numberRange.location == NSNotFound) ? [strChatContent length] : numberRange.location;
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,intergerLen)];
    
    [[self.receiveDataView textStorage] appendAttributedString:attriString];
    [self scrollOutputToBottom];
    
    [socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
    NSString *msg = @"Sorry this connect is failure";
    self.statusLabel.text=msg;
    socket = nil;
}


@end
