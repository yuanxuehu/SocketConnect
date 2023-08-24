//
//  KJULinkManager.h
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import <Foundation/Foundation.h>
#import "KJUlinkSender.h"

@interface KJULinkManager : NSObject <KJUlinkSenderDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, strong) KJUlinkSender *ulinkSender;

- (void)startConnect;
- (void)stopConnect;

@end

