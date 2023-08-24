//
//  KJStreamSocketConnectVC.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJStreamSocketConnectVC.h"
#import "KJStreamSocketConnectManager.h"

@interface KJStreamSocketConnectVC ()

@end

@implementation KJStreamSocketConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    //1、StreamSocket
    [[KJStreamSocketConnectManager sharedinstance] initNetworkCommunication:@"192.168.x.x" tcpPort:1111];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[KJStreamSocketConnectManager sharedinstance] stopConnect];
}


@end
