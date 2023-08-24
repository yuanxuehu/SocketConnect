//
//  KJGCDAsyncSocketConnectManager.h
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import <Foundation/Foundation.h>
#include "Global.h"
#import "GCDAsyncSocket.h"

@interface KJGCDAsyncSocketConnectManager : NSObject<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *aSocket;
@property (nonatomic, assign) WIFISTATE connectState;

+ (instancetype)sharedInstance;

- (void)connectServerHost:(NSString *) ipAddress tcpPort:(NSInteger)tcpPortNo;

- (void)stopConnect;

@end

