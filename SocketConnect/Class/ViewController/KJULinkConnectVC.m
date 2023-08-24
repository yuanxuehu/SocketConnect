//
//  KJULinkConnectVC.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJULinkConnectVC.h"
#import "KJULinkManager.h"

@interface KJULinkConnectVC ()

@end

@implementation KJULinkConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    //4、ULink
    [[KJULinkManager sharedInstance] startConnect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[KJULinkManager sharedInstance] stopConnect];
}


@end
