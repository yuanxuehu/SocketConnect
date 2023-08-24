//
//  Global.h
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#ifndef Global_h
#define Global_h

enum tagWifiState{
    WIFI_TCP_NONE,
    WIFI_TCP_CONNECTING,
    WIFI_TCP_SUCCESS,
    WIFI_TCP_DISCONNECT,
    WIFI_TCP_CONNECT_FAIL
};

typedef enum tagWifiState WIFISTATE;

#endif /* Global_h */
