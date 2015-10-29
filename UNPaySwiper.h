//
//  UNPaySwiper.h
//  UNPaySwiper
//
//  Created by 111 on 15-8-7.
//  Copyright (c) 2015年 dynamicode. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  ERROR_OK 0
#define  ERROR_FAIL_CONNECT_DEVICE 0x0001
#define  ERROR_FAIL_GET_KSN  0x0002
#define  ERROR_FAIL_READCARD 0x0003
#define  ERROR_FAIL_ENCRYPTPIN 0x0004
#define  ERROR_FAIL_GETMAC     0x0005

typedef enum
{
    STATE_ACTIVE = 0,
    STATE_IDLE = 1,
    STATE_BUSY = 2,
    STATE_UNACTIVE = -1
}DeviceBlueState;


typedef enum
{
    Code0 = 0,     //处理成功
    Code1 = 1,     //指令码不支持
    Code2 = 2,     //参数错误
    Code3 = 3,     //可变数据域长度错误
    Code4 = 4,     //帧格式错误
    Code5 = 5,     //LRC 交易失败
    Code6 = 6,     //其他
    Code7 = 7,     //超时
    Code8 = 8      //返回当前状态
}responseCode;     //响应码说明


typedef enum
{
    card_mc = 1,        //磁条卡
    card_ic = 2,        //IC卡
    card_all = 3        //银行卡
}cardType;              //银行卡类型






@protocol UNPaySwiperDelegate <NSObject>

@optional


//扫描设备结果
-(void)OnFindBlueDevice:(NSDictionary *)dic;


//连接设备结果
-(void)onDidConnectBlueDevice:(NSDictionary *)dic;


//失去连接到设备
-(void)onDisconnectBlueDevice:(NSDictionary *)dic;


//读取ksn结果
-(void)onDidGetDeviceKsn:(NSDictionary *)dic;


-(void)onDidUpdateKey:(int)retCode;


-(void)OnDetectCard;

//读取卡信息结果
-(void)OnDidReadCardInfo:(NSDictionary *)dic;



//加密Pin结果
-(void)onEncryptPinBlock:(NSString *)encPINblock;


//mac计算结果
-(void)OnDidGetMac:(NSString *)strmac;


-(void)onResponse:(int)type :(int)status;

//取消交易
-(void)onDidCancelCard;

@end


@interface UNPaySwiper : NSObject
{
    int intDeviceBlueState;
}

@property(nonatomic) id<UNPaySwiperDelegate> delegate;
@property (nonatomic) BOOL isConnectBlue;
@property (nonatomic, retain) NSDictionary *dicCurrect;

/*
 SDK初始化
 */
+(instancetype)ShareInstance;



/*
 搜索蓝牙设备
 */
-(void)ScanBlueDevice;


/*
 停止扫描蓝牙
 */
-(void)stopScanBlueDevice;


/*
 连接蓝牙设备
 */

-(BOOL)ConnectBlueDevice:(NSDictionary *)dic;


/*
 断开蓝牙设备
 */
-(void)DisConnect;


/*
 获取ksn编号,
 
 */

-(void)GetDeviceKsn;


/*
 写入工作密钥
 (密钥指：签到之后，后台下发的三组
 DESKey、（32位密钥 + 8位checkValue = 40位）
 PINKey、（32位密钥 + 8位checkValue = 40位）
 MACKey) （16位密钥 + 8位checkValue = 24位）
 */

-(void)UpdateKey:(NSDictionary *)keyDic;


/*
 (读磁条卡、IC卡需使用同一接口，app代码无需做刷卡类型区分。
 需返回数据：
 1. 磁卡：卡号（明）、track2（密）、track3（可选）等
 2.IC卡：卡号（明）、track2（密）、track3（可选）、IC卡标识、icdata（55)

 1: 消费
 2: 撤销
 */



-(void)ReadCard:(int)type  money:(double)dbmoney;




/*
 加密pin
 */
-(void)EncryptPin:(NSString *)Pin;


/*
 计算mac
 (消费与查余额时 macdata 位数不同，所以接口对于传入参数的位数最好不要做限制，​若有需要，sdk自行补位）
 */
-(void)GetMacValue:(NSString *)data;


//取消交易
-(void)CancelCard;


@end
