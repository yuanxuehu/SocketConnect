//
//  KJSmartLinkManager.h
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import <Foundation/Foundation.h>
#include "KJSmartLinkHost.h"

@interface KJSmartLinkManager : NSObject

+ (instancetype)sharedInstance;

- (void)startConnect;
- (void)stopConnect;

@end

