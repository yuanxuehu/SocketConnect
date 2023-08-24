//
//  KJStreamSocketConnectManager.h
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import <Foundation/Foundation.h>
#include "Global.h"

typedef enum tagWifiState WIFISTATE;

@interface KJStreamSocketConnectManager : NSObject<NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) WIFISTATE connectState;

+ (instancetype)sharedinstance;

- (void)initNetworkCommunication:(NSString *) ipAddress tcpPort:(NSInteger)tcpPortNo;

- (void)stopConnect;

@end

