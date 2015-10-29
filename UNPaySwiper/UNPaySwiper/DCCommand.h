//
//  DCCommand.h
//  UNPaySwiper
//
//  Created by 111 on 15-8-11.
//  Copyright (c) 2015年 dynamicode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBluetooth.h"


@protocol DCCommandDelegete <NSObject>

-(void)OnFindBlueDevice:(NSDictionary *)dic;

-(void)onDidConnectBlueDevice:(NSDictionary *)dic;

-(void)onDisconnectBlueDevice:(NSDictionary *)dic;

-(void)onDidGetDeviceKsn:(NSDictionary *)dic;

-(void)onDidUpdateKey:(int)retCode;

-(void)OnDetectCard;

//读取卡信息结果
-(void)OnDidReadCardInfo:(NSDictionary *)dic;

//加密Pin结果
-(void)onEncryptPinBlock:(NSString *)encPINblock;


//mac计算结果
-(void)OnDidGetMac:(NSString *)strmac;

//取消交易
-(void)onDidCancelCard;




-(void)onOpenCardReader:(NSDictionary *)dic;


-(void)onResponse:(int)type :(int)status;


@end

@interface DCCommand : NSObject<DCBluetoothDelegete>
{
    int index;
}

@property(nonatomic, retain) id<DCCommandDelegete> delgete;

+(DCCommand *)Init;

-(void)InitBluetooth;

-(void)FinalizeBluetooth;

-(void)ScanBluetooth;

-(void)StopScanBluetooth;

-(void)ConnectBluetooth:(NSDictionary *)dic;

- (void)disconnectBlue;

-(void)UpdateKey:(NSDictionary *)dic;


-(void)ReadDeviceInfo;


- (void)openCardReader:(int)type;



-(void)ReadMCCard;

//PBOC执行标准流程
-(void)executionStandardProcess:(int)transType money:(double)dbmoney;


- (void)EncryptPinBlock:(NSString *)PINblock :(int)cardType;

-(void)GetMacValue:(NSString *)data;

- (void)resetDevice;


@end
