//
//  KJGCDAsyncSocketConnectVC.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJGCDAsyncSocketConnectVC.h"
#import "KJGCDAsyncSocketConnectManager.h"

@interface KJGCDAsyncSocketConnectVC ()

@end

@implementation KJGCDAsyncSocketConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;

    //2、GCDAsyncSocket
    [[KJGCDAsyncSocketConnectManager sharedInstance] connectServerHost:@"192.168.x.x" tcpPort:1111];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[KJGCDAsyncSocketConnectManager sharedInstance] stopConnect];
}


@end
