//
//  KJULinkManager.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJULinkManager.h"

@implementation KJULinkManager

+ (instancetype)sharedInstance {
    static KJULinkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KJULinkManager alloc] init];
    });
    
    return manager;
}

- (void)startConnect
{
    self.ulinkSender = [[KJUlinkSender alloc] init];
    [self.ulinkSender setDelegate:self];
    
    NSString *autoToken = @"111";

    NSString *mSSID = @"TestWiFi";
    NSData *ssidData = [mSSID dataUsingEncoding:NSUTF8StringEncoding];
    NSString *bsae64SSID = [ssidData base64EncodedStringWithOptions:0];

    NSString *mPsk = @"TestPSW";
    NSData *pwdData = [mPsk dataUsingEncoding:NSUTF8StringEncoding];
    NSString *bsae64Psk = [pwdData base64EncodedStringWithOptions:0];

    NSString *Keyyy = [NSString stringWithFormat:@"%@#&%@#&%@",bsae64SSID,bsae64Psk,autoToken];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.ulinkSender send:[Keyyy dataUsingEncoding:NSUTF8StringEncoding]];
    });
}

- (void)stopConnect
{
    [self.ulinkSender stop];
}


#pragma mark - ulink delegate
- (void)sendStart:(id)sender
{
    NSLog(@"ulink--sendStart:");
}

- (void)sendStop:(id)sender
{
    NSLog(@"ulink--sendStop:");
}

@end
