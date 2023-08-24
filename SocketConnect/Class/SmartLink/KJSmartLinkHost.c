//
//  KJSmartLinkHost.c
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#include "KJSmartLinkHost.h"
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdbool.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <ifaddrs.h>

#define SMART_LINK_DEST_PORT 7000
#ifndef WIFI_TRACE
#define WIFI_TRACE(fmt, args...)   printf("[SMART LINK-%d] "fmt"\r\n", __LINE__, ##args)
#endif

char g_brcAddr[32] = {0};
int init = 0;

typedef struct KJ_SMART_LINK
{
    bool allowSend;
    bool isInit;
    int retErrno;
    int sockFd;
    struct sockaddr_in addrServ;
    emKJ_SMART_LINK_MODE smart_link_mode;
}stKJ_SMART_LINK, *lpKJ_SMART_LINK;
static stKJ_SMART_LINK m_smart_link;

static int smart_link_send_data(int sendbuf_length)
{
    int ret  = -1;
    char *socket_buffer = NULL;
    
    if(m_smart_link.allowSend == true){
        if((socket_buffer = malloc(sendbuf_length)) != NULL){
            ret = (int)sendto(m_smart_link.sockFd, socket_buffer, (size_t)sendbuf_length, 0, (struct sockaddr *)&m_smart_link.addrServ, sizeof(m_smart_link.addrServ));
            if(ret < 0){
                WIFI_TRACE("send error[%d]=%s", errno, strerror(errno));
                m_smart_link.retErrno = errno;
                m_smart_link.allowSend = false;
            }
            printf("ret=%d,len=%d ", ret,sendbuf_length);
        }
    }
    if(socket_buffer){
        free(socket_buffer);
    }
    
    return ret;
}

static void smart_link_send_header(int packet_num)
{
    smart_link_send_data( 276 );
    smart_link_send_data( 341 );
    smart_link_send_data( 276 );
    smart_link_send_data( 341 );
    smart_link_send_data( 276 );
    smart_link_send_data( 341 );
    smart_link_send_data( 342 + packet_num);
    smart_link_send_data( 1302 + packet_num );
    smart_link_send_data( 342 + packet_num );
    smart_link_send_data( 1302 + packet_num );
}

extern char g_brcAddr[32];
int kj_smart_link_init(lpKJ_SMART_LINK_INIT_ARG arg)
{
    int ret = -1, on = 1;
    char broad_addr[32];
    struct timeval tv = { .tv_sec = 2, .tv_usec = 0, };
    
    memcpy(broad_addr, g_brcAddr, strlen(g_brcAddr));
    
    memset(&m_smart_link, 0, sizeof(stKJ_SMART_LINK));
    do{
        if((m_smart_link.sockFd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)) <= 0){
            WIFI_TRACE("socket failed");
            break;
        }
        if(setsockopt(m_smart_link.sockFd, SOL_SOCKET, SO_BROADCAST, &on, sizeof(on)) != 0 ){
            WIFI_TRACE("setsockopt failed");
            break;
        }
        if(setsockopt(m_smart_link.sockFd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv)) != 0 ){
            WIFI_TRACE("setsockopt timeout failed");
            break;
        }
        m_smart_link.addrServ.sin_family = AF_INET;
        m_smart_link.addrServ.sin_addr.s_addr = inet_addr(broad_addr) ;
        m_smart_link.addrServ.sin_port = htons(SMART_LINK_DEST_PORT);
        m_smart_link.smart_link_mode = arg->mode;
        m_smart_link.isInit = true;
        ret = 0;
    }while(0);
    WIFI_TRACE("smart link init %s", ret == 0 ? "succeed" : "fail");
    return ret;
}

int kj_smart_link_deinit(void)
{
    m_smart_link.allowSend = false;
    if(m_smart_link.sockFd){
        close(m_smart_link.sockFd);
    }
    m_smart_link.isInit = false;
    init = 0;
    
    return 0;
}

#define KJ_SMART_LINK_SEND_HEADER(megLen)    smart_link_send_header(megLen - 1)
int kj_smart_link_send(char *message)
{
    int i, message_len;
    char il;
    int message_int[90];
    char message_cun[45];
    
    if(m_smart_link.isInit != true || message == NULL){
        return -1;
    }
    memset(message_int, 0, sizeof(message_int));
    snprintf(message_cun, sizeof(message_cun), "%s", message);
    message_len = (int)strlen(message_cun);
    
    printf("\n start send:%s \n", message_cun);
    for(i = 0; i < message_len * 2; i += 2 ){
        il = message_cun[ i/2 ];
        message_int[i] = ( il - 32 ) / 10;
        message_int[i+1] = ( il - 32 ) % 10;
    }
    m_smart_link.allowSend = true;
    m_smart_link.retErrno = 0;
    KJ_SMART_LINK_SEND_HEADER( message_len );
    for(i = 0; i < message_len * 2; i += 2 ){
        smart_link_send_data( 402 + 20 * ( i / 2 ) + message_int[i] );
        smart_link_send_data( 402 + 20 * ( i / 2 ) + message_int[i] );
        smart_link_send_data( 402 + 20 * ( i / 2 ) + 10 + message_int[ i + 1 ] );
        smart_link_send_data( 402 + 20 * ( i / 2 ) + 10 + message_int[ i + 1 ] );
    }
    printf("\n end send");
    
    return m_smart_link.retErrno;
}

int kj_smart_link_start(char *essid, char *password, lpKJ_SMART_LINK_INIT_ARG arg)
{
    char buffer[100];
    int ret = -1;
    static unsigned int times;
    
    if(arg == NULL || essid == NULL || password == NULL){
        return -1;
    }
    do{
        if(m_smart_link.isInit != true){
            times = 0;
            if(kj_smart_link_init(arg) != 0)
                break;
        }
        
        switch(m_smart_link.smart_link_mode){
            case KJ_SMART_LINK_DEFAULT:
                snprintf(buffer, sizeof(buffer), "20##&#&WNVR");
                WIFI_TRACE("default id pwd");
                break;
                
            case KJ_SMART_LINK_NORMAL:
                snprintf(buffer, sizeof(buffer), "20#%s#&%s#&WNVR", essid, password);
                WIFI_TRACE("send all");
                break;
                
            case KJ_SMART_LINK_LEVEL:
                snprintf(buffer, sizeof(buffer), "20#%s#&%s#&WNVR%d", essid, password, arg->signalLevel); //add a char behind WNVR as the limit sinal level
                WIFI_TRACE("product match code(%d)", arg->signalLevel);
                break;
                
            default:
                WIFI_TRACE("unknown wifi essid mode");
                break;
        }
        
        ret = kj_smart_link_send(buffer);
        times++;
        WIFI_TRACE("[%d]smart link send %s, buffer=%s", times, ret == 0 ? "succeed" : "fail", buffer);
    }while(0);
    
    return ret;
}

int kj_smart_link_stop(void)
{
    return kj_smart_link_deinit();
}
/*
 * this function is use on phone, it is useless on nvr,please note that
 */
void smart_link_send_ack(void)
{
    smart_link_send_data( 275 );
    smart_link_send_data( 340 );
    usleep(100000);
    smart_link_send_data( 275 );
    smart_link_send_data( 340 );
}

char createCrc(const char* data, int len){
    char CRC = 0;
    int genPoly = 0x107;
    for(int i = 0;i < len;i++){
        CRC ^= data[i];
        for(int j = 0;j < 8;j++){
            if((CRC & 0x80) != 0){
                CRC = (char) ((CRC << 1) ^ genPoly);
            }else{
                CRC <<= 1;
            }
        }
    }
    //转为16进制的字符串
//    String tmp = Integer.toHexString((CRC));
    return CRC;
}

int smart_link_init(){
    stKJ_SMART_LINK_INIT_ARG stSmartLink;
    memset((void*)&stSmartLink, 0 , sizeof(stKJ_SMART_LINK_INIT_ARG));
    stSmartLink.netdev = "wlan0";
    stSmartLink.mode = 0;
    stSmartLink.signalLevel = 1;
    return kj_smart_link_init(&stSmartLink);
}

//封装API
int quicksmartlink(char* message,const char *brcAddr) {
    int sendRet = -1;
    
    memcpy(g_brcAddr, brcAddr, strlen(brcAddr));
    
    printf("## msg:%s brcAddr:%s \n",message,brcAddr);
    
    if(init || smart_link_init() == 0){
        sendRet = kj_smart_link_send(message);
        init = 1;
    }
    return sendRet;
}
