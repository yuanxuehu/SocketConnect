//
//  KJSmartLinkConnectVC.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJSmartLinkConnectVC.h"
#import "KJSmartLinkManager.h"

@interface KJSmartLinkConnectVC ()

@end

@implementation KJSmartLinkConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    //3、SmartLink
    [[KJSmartLinkManager sharedInstance] startConnect];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[KJSmartLinkManager sharedInstance] stopConnect];
}

@end
