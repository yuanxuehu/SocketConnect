//
//  KJGCDAsyncSocketConnectManager.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJGCDAsyncSocketConnectManager.h"

@implementation KJGCDAsyncSocketConnectManager

+ (instancetype)sharedInstance {
    static KJGCDAsyncSocketConnectManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KJGCDAsyncSocketConnectManager alloc] init];
    });
    
    return manager;
}

- (void)connectServerHost:(NSString *) ipAddress tcpPort:(NSInteger)tcpPortNo
{
    //change state
    if(self.connectState == WIFI_TCP_CONNECTING) return;

    //save
    self.connectState = WIFI_TCP_CONNECTING;

    // init Socket
    self.aSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    NSError *error = nil;
    [self.aSocket connectToHost:ipAddress onPort:(uint16_t)tcpPortNo error:&error];

    if (error) {
        NSLog(@"连接失败error: %@", error.description);
    } else {
        NSLog(@"----------------连接服务器成功----------------");
        
        //change state
        if (self.connectState != WIFI_TCP_SUCCESS) {
            self.connectState = WIFI_TCP_SUCCESS;
        }
    }
}

- (void)stopConnect
{
    [self.aSocket disconnect];
    
}

# pragma mark - GCDAsyncSocket delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"======didConnectToHost======, %@", sock);

    self.connectState = WIFI_TCP_SUCCESS;

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"======didReadData======");

    [self.aSocket readDataWithTimeout:-1 tag:0];

    NSString *strOutput = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];


}



@end
