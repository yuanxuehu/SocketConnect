//
//  KJSmartLinkHost.h
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#ifndef KJSmartLinkHost_h
#define KJSmartLinkHost_h

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef enum{
        KJ_SMART_LINK_NORMAL,
        KJ_SMART_LINK_DEFAULT,
        KJ_SMART_LINK_LEVEL
    }emKJ_SMART_LINK_MODE;
    
    typedef struct KJ_SMART_LINK_INIT_ARG
    {
        char *netdev;
        emKJ_SMART_LINK_MODE mode;
        int signalLevel;
    }stKJ_SMART_LINK_INIT_ARG, *lpKJ_SMART_LINK_INIT_ARG;
    
    /* smart_link init function, interface is the name of you wireless device
     * return -1 : There is no broadcard address in interface, please assign IP and netmask
     * return -2 : create the socket of send packet faid
     * return 0  : init success;
     * please must use kj_smart_link_quit() function to quik smart_link
     */
    extern int kj_smart_link_init(lpKJ_SMART_LINK_INIT_ARG arg);
    
    /* The function of smart_link send packet , message is the message you want to sent to the client
     *
     * attention : The max length of message is 45, the message over 45 will be ignore,please noet that,ths;
     */
    extern int kj_smart_link_send(char *message);
    
    /* The function of quit smart_link
     * return 0  : normal quit
     * return -1 : fail to close socket
     */
    extern int kj_smart_link_deinit(void);
    
    extern int kj_smart_link_start(char *essid, char *password, lpKJ_SMART_LINK_INIT_ARG arg);
    extern int kj_smart_link_stop(void);
    extern void smart_link_send_ack(void);
    
    extern char createCrc(const char* data, int len);

    //封装API
    extern int quicksmartlink(char* message,const char *brcAddr);
    
    
#ifdef __cplusplus
}
#endif


#endif /* KJSmartLinkHost_h */
