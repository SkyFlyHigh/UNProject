//
//  DCBluetooth.h
//  CSDCSwiper
//
//  Created by 111 on 15-7-29.
//  Copyright (c) 2015年 dynamicode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define  PERIPHERAL_IDENTIFER  @"identifier"
#define  PERIPHERAL_NAME       @"Name"


@protocol DCBluetoothDelegete <NSObject>

/*! 搜素到一个蓝牙设备 (每搜索到一个设备就会回调一次)
 \param  btDevice 蓝牙设备标识
 \return 无
 */
- (void)OnFindBlueDevice:(NSDictionary *)dic;

/*! 成功连接到一个蓝牙设备回调
 \param  btDevice 蓝牙设备标识
 \return 无
 */
- (void)onDidConnectBlueDevice:(NSDictionary *)dic;


//失去连接到设备
-(void)onDisconnectBlueDevice:(NSDictionary *)dic;


-(void)onReceiveCommandResult:(int)length :(unsigned char[])data;


@end

@interface DCBluetooth : NSObject


@property(nonatomic, retain) id<DCBluetoothDelegete> delegete;

@property (nonatomic) BOOL isCanSendData;


+(DCBluetooth *)Init;


-(void)InitBlue;

-(void)finalizeBlue;

-(void)ScanBluetooth;

-(void)StopScanBluetooth;

-(void)ConnectBluetooth:(NSDictionary *)dic;

- (void)DCdisappearBlue;

-(void)SendData:(NSData *)dataMsg;


@end
