//
//  KJStreamSocketConnectManager.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJStreamSocketConnectManager.h"

//define data
NSString * const str_Key_Token          = @"token";
NSString * const str_Key_MsgID          = @"msg_id";

//id define
enum tagCmdType{
    CMD_NONE                    = 0,
    CMD_GET_SETTING             = 1,
    CMD_SET_SETTING             = 2,
    CMD_GET_ALL_SETTING         = 3,
    CMD_GET_DEVINFO             = 4,
    CMD_START_SESSION           = 5,
    CMD_NOTIFICATION            = 6
    
};
typedef enum tagCmdType KJCmdType;

// interface
@interface KJStreamSocketConnectManager ()

@property (nonatomic, strong) NSMutableArray *lstSend;

@end

@implementation KJStreamSocketConnectManager

#pragma mark - init

+ (instancetype)sharedinstance
{
    static KJStreamSocketConnectManager *sharedStore;
    
    // Do I need to create a sharedStore?
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

// Here is the real (secret) initializer
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        self.connectState = WIFI_TCP_NONE;
        self.lstSend = [[NSMutableArray alloc] init];
    }
    return self;
}

// If a programmer calls [[BNRItemStore alloc] init], let him know the error of his ways
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[KJStreamSocketConnectManager sharedinstance]"
                                 userInfo:nil];
    return nil;
}

- (void) initNetworkCommunication:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo
{
    //change state
    if(self.connectState == WIFI_TCP_CONNECTING) return;
    
    //save
    self.connectState = WIFI_TCP_CONNECTING;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge  NSOutputStream *)writeStream;
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //open stream
    [self.inputStream open];
    [self.outputStream open];
}

- (void)stopConnect
{
    NSLog(@"--- closeNetwork...............");
    //close stream
    [self.inputStream close];
    [self.outputStream close];
}

#pragma mark - rev 接收消息

- (void)revCmd:(uint8_t *)pBuffer withLen:(NSInteger)nLen
{
    //output string
    NSData *output = [NSData dataWithBytes:pBuffer length:nLen];
    NSString *strOutput = [[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding];
    
    //解析数据
    NSString *lastString = @"test data";//字典字符串
    
    //analyze json
    NSData *data = [lastString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    if(jsonResponse == nil) return;

    //analyze
    [self analyzeJson:jsonResponse];
    
    //last
    [self popSendDate];
}

- (void)analyzeJson:(NSArray *)jsonDict
{
    //check
    if(jsonDict == nil) return;
    if(jsonDict.count == 0) return;
    
    //search dict
    NSInteger nCount = jsonDict.count;
    
    //start analyze
    for (int nCtr = 0; nCtr < nCount; nCtr++) {
        
        //get element
        NSDictionary *elemDict = (NSDictionary *)(jsonDict[nCtr]);
        
        //get message id
        NSString *strMsgID = [elemDict objectForKey:str_Key_MsgID];
        
        //session
        int nID = [strMsgID intValue];
        if(nID == 0) break;
        
        //go pick cmd
        [self goPickCmd:nID withDict:elemDict];
    }
}

- (void)goPickCmd:(int)nID withDict:(NSDictionary *)elemDict
{
    NSLog(@"--- goPickCmd: %d ",nID);

    switch (nID) {
        case CMD_GET_ALL_SETTING:
//            [self goGetAllSetting:elemDict];
            break;
            
        case CMD_START_SESSION:
//            [self goSessionStart:elemDict];
            break;
            
        case CMD_GET_DEVINFO:
//            [self goGetDevInfo:elemDict];
            break;
            
        case CMD_NOTIFICATION:
//            [self goNotification:elemDict];
            break;
            
        case CMD_GET_SETTING:
//            [self goAppState:elemDict];
            break;
            
        default:
            break;
    }
}

- (void)popSendDate
{
    //check
    if (self.lstSend.count <= 0) return;
    
    //check
    NSDictionary *dict = [self.lstSend objectAtIndex:0];
    if (dict == nil) return;
    
    //send data
    NSError *writeError = nil;
    NSInteger bytesWritten = [NSJSONSerialization writeJSONObject:dict
                                                         toStream:self.outputStream
                                                          options:kNilOptions
                                                            error:&writeError];
    if (bytesWritten <= 0)
    {
        NSLog(@"Error Writing JSON to outStream");
    }

    //last
    [self.lstSend removeObjectAtIndex:0];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
    NSLog(@"---rev.....%lu",(unsigned long)streamEvent);
    switch (streamEvent)
    {
        //connect success
        case NSStreamEventOpenCompleted:
        {
            //change state
            if (self.connectState != WIFI_TCP_SUCCESS) {
                //change state
                self.connectState = WIFI_TCP_SUCCESS;
                
                //notify controller
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_NET_CONNECTED object:nil];
            }
        }
        break;
        
        //data rev
        case NSStreamEventHasBytesAvailable:
        {
            NSLog(@"rev.......");
            if (aStream == self.inputStream) {
                while ([self.inputStream hasBytesAvailable]) {
                    //rev data
                    uint8_t buffer[1024];
                    memset(buffer, 0x00, 1024 * sizeof(uint8_t));
                    NSInteger len = [self.inputStream read:buffer maxLength:(1024 * sizeof(uint8_t))];
                    if (len > 0) [self revCmd:buffer withLen:len];
                }
            }
        }
        break;
        
        //connect fail
        case NSStreamEventErrorOccurred:
        {
            //change state
            if (self.connectState == WIFI_TCP_SUCCESS) {
                //change state
                self.connectState = WIFI_TCP_DISCONNECT;
            } else if (self.connectState == WIFI_TCP_CONNECTING) {
                //change state
                self.connectState = WIFI_TCP_CONNECT_FAIL;
            }
            
            //notify
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_NET_DISCONNECTED object:nil];
        }
        break;
            
        //stream end
        case NSStreamEventEndEncountered:
        {
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_NET_DISCONNECTED object:nil];
        }
        break;
            
        default:
            break;
    }
}

@end
