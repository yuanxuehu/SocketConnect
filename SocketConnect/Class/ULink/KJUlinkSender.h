//
//  KJUlinkSender.h
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import <Foundation/Foundation.h>

@protocol KJUlinkSenderDelegate<NSObject>

- (void) sendStart:(id)sender;

- (void) sendStop:(id)sender;

@end

@interface KJUlinkSender : NSObject

@property(readonly) BOOL isRunning;

@property(nonatomic) id<KJUlinkSenderDelegate> delegate;

- (KJUlinkSender *) init;

- (void)dealloc;

- (void) send:(NSData *)data atIndex:(NSInteger) index ofLength:(NSInteger)length;

- (void) send:(NSData *)data;

- (void) stop;

@end

