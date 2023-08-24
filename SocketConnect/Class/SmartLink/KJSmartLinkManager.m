//
//  KJSmartLinkManager.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "KJSmartLinkManager.h"

@interface KJSmartLinkManager ()

@property (nonatomic, strong) dispatch_source_t checkTimer;

@end

@implementation KJSmartLinkManager

+ (instancetype)sharedInstance {
    static KJSmartLinkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KJSmartLinkManager alloc] init];
    });
    
    return manager;
}


- (void)startConnect
{
    NSString *autoToken = @"100";

    NSString *mSSID = @"TestWiFi";
    NSData *ssidData = [mSSID dataUsingEncoding:NSUTF8StringEncoding];
    NSString *bsae64SSID = [ssidData base64EncodedStringWithOptions:0];

    NSString *mPsk = @"TestPSW";
    NSData *pwdData = [mPsk dataUsingEncoding:NSUTF8StringEncoding];
    NSString *bsae64Psk = [pwdData base64EncodedStringWithOptions:0];

    NSString *Keyyy = [NSString stringWithFormat:@"20#%@#&%@#&%@",bsae64SSID,bsae64Psk,autoToken];

    const char *msg = [Keyyy UTF8String];

    unsigned char crc = createCrc(msg, (int)Keyyy.length);
    char crcStr[8] = {0};
    sprintf(crcStr, "%X", crc);
    //    NSString * string3 = @"20#RWRpV2lGaQ==#&d3d3d3d3d3c=#&100#&72#&1";
    NSString *string3 = [NSString stringWithFormat:@"%@#&%s#&1", Keyyy,crcStr];

    //把得到的目标ip 最后的数字更换为255（意思是搜索全部的）
    NSArray *strArr = [@"192.168.123.124" componentsSeparatedByString:@"."];//[[self getIPAddress] componentsSeparatedByString:@"."];
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:strArr];
    [muArr replaceObjectAtIndex:(strArr.count-1) withObject:@"255"];
    NSString *finalStr = [muArr componentsJoinedByString:@"."];//目标ip

    __block const char *brcAddr = [finalStr UTF8String];

    // gcd
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    self.checkTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.checkTimer, start, interval, 0);


    __block BOOL isEnd = YES;

    dispatch_source_set_event_handler(self.checkTimer, ^{
        const char *msgg = [string3 UTF8String];
                    char msgTo[128] = {0};
                    memcpy(msgTo, msgg, strlen(msgg));

        if (isEnd) {
            isEnd = NO;
            NSLog(@"-----开始重新来一遍");

            for (int i = 0; i<15; i++) {
                quicksmartlink(msgTo,brcAddr);
            }
            for (int j = 0; j<10; j++) {
                smart_link_send_ack();
            }
            isEnd = YES;
            NSLog(@"-----跑完一遍");
        }
    });

    dispatch_resume(self.checkTimer);
}


- (void)stopConnect
{
    if (self.checkTimer) {
        dispatch_cancel(self.checkTimer);
    }
    kj_smart_link_stop();
}


@end
