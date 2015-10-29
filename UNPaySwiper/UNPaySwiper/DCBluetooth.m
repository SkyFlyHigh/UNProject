//
//  DCBluetooth.m
//  CSDCSwiper
//
//  Created by 111 on 15-7-29.
//  Copyright (c) 2015年 dynamicode. All rights reserved.
//

#import "DCBluetooth.h"
#import "TransferService.h"
#import "DCCommon.h"

#define START_FIRST     0x4C
#define START_SECOND    0x4B
#define BYTE_66         0x66
#define BYTE_55         0x55
#define SUCCEEDBYTE     0x90

#define INS_COSINFO         0x01   //get cos info.
#define INS_SERIALNUMBER_1  0x02   //serial number.
#define INS_SERIALNUMBER_2  0x03   //serial number.
#define INS_APDU            0x10   //APDU.
#define INS_RE_SEND         0xF0   //ReSend.

@interface DCBluetooth () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSMutableDictionary *PeripheralDic;
    NSData *dataReadySend;
}

@property (strong, nonatomic)CBCentralManager *centralManager;
@property (strong, nonatomic)CBPeripheral *currentPeripheral;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic)NSMutableData         *data;
@property (strong, nonatomic)CBCharacteristic      *characteristicWrite;
@property (strong, nonatomic)CBCharacteristic      *characteristicNotify;


@end

@implementation DCBluetooth

@synthesize delegete = _delegete;
@synthesize isCanSendData = _isCanSendData;


static DCBluetooth *ShareRoot = nil;

static unsigned char byRec[2048];  //接收数据;
static unsigned char rec[2048];  //接收数据;
static int lengthRec = 2048;    //接收数据索引;
static int indexRec;    //接收数据索引;
static int length;  //接收Data长度;
static BOOL start;

+(DCBluetooth *)Init
{
    @synchronized(self)
    {
        if(ShareRoot == nil)
        {
            ShareRoot = [[DCBluetooth alloc] init];
        }
        
        return ShareRoot;
    }
    
    return ShareRoot;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (ShareRoot == nil)
        {
            ShareRoot = [super allocWithZone:zone];
            return  ShareRoot;
        }
    }
    return nil;
}


-(void)InitBlue
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _centralManager.delegate = self;
    
    _data = [[NSMutableData alloc] init];
    
    PeripheralDic = [[NSMutableDictionary alloc] init];
    
    _isCanSendData = YES;
    
}

-(void)finalizeBlue
{
    [self.centralManager stopScan];
    
    if(self.discoveredPeripheral)
    {
        [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:self.characteristicNotify];
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
    }
    
}

-(void)ScanBluetooth
{
    
       NSDictionary* scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    [_centralManager scanForPeripheralsWithServices:nil options:scanOptions];
    NSLog(@"Scanning started");
}

-(void)StopScanBluetooth
{
    [_centralManager stopScan];
}

-(void)ConnectBluetooth:(NSDictionary *)dic
{
    [_centralManager stopScan];
    
    NSDictionary *optionDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,nil];
    
    CBPeripheral *peripheral = [PeripheralDic objectForKey:[dic objectForKey:PERIPHERAL_IDENTIFER]];
    
    
    [_centralManager connectPeripheral:peripheral options:optionDic];
}


-(void)SendData:(NSData *)dataMsg
{
    [_centralManager stopScan];
    
    if (self.discoveredPeripheral == nil || self.characteristicNotify == nil)
    {
        NSLog(@"没有找到匹配成功的外围设备");
    }
    else if(dataMsg.length == 0)
    {
        NSLog(@"请输入发送文本");
    }
    else if(_isCanSendData)
    {
        NSData *dataSend = nil;
        _isCanSendData = NO;
        
        if (dataMsg.length > PACKAGE_DATA_MAXLEN)
        {
            dataSend = [dataMsg subdataWithRange:NSMakeRange(0, PACKAGE_DATA_MAXLEN)];
            dataReadySend = [dataMsg subdataWithRange:NSMakeRange(PACKAGE_DATA_MAXLEN, dataMsg.length - PACKAGE_DATA_MAXLEN)];
        }
        else
        {
            dataSend = [dataMsg subdataWithRange:NSMakeRange(0, dataMsg.length)];
            dataReadySend = nil;
        }
        
       // NSLog(@"正在下发数据");
        
        NSLog(@"dataSend Message = %@", dataSend);
        
        [self writeValue:dataSend forCharacteristic: _characteristicWrite];
    }

}

- (void) writeValue:(NSData *)value forCharacteristic:(CBCharacteristic *) characteristic
{
    //发送数据...
    [self.discoveredPeripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}


- (void)DCdisappearBlue
{
    [self.centralManager stopScan];
    
    if (self.discoveredPeripheral) {
        [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:self.characteristicNotify];
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
    }
}

#pragma mark CBPeripheralDelegate
/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error didWriteValueForCharacteristic state: %@ , failureReason : %@ , suggestion : %@", error.localizedDescription ,error.localizedFailureReason, error.localizedRecoverySuggestion);
        
        return;
    }
    
    _isCanSendData = YES;
    
    NSLog(@"信息发送成功!");
    
    if (dataReadySend)
    {
        [self SendData:dataReadySend];
    }
}



/*
 
    CBCentralManagerDelegate
 
 */

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"蓝牙未打开,请打开蓝牙.");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"您的设备不支持BlueTooth 4.0 BLE.");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"您的设备未授权.");
            break;
        case CBCentralManagerStatePoweredOn:
            //NSLog(@"蓝牙启动,扫描周边外围设备...");
            //[self ScanBluetooth];
            break;
        default:
            break;
    }
}


/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @param central              The central manager providing this update.
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
 *								was not available.
 *
 *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
 *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
 *
 *  @seealso                    CBAdvertisementData.h
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [PeripheralDic setValue:peripheral forKey:[peripheral.identifier UUIDString]];
    
    if(peripheral.identifier && peripheral.name)
    {
        if(_delegete && [_delegete respondsToSelector:@selector(OnFindBlueDevice:)])
        {
            NSLog(@"PERIPHERAL_NAME : %@", peripheral.name);
            [_delegete OnFindBlueDevice:@{PERIPHERAL_IDENTIFER:[peripheral.identifier UUIDString], PERIPHERAL_NAME:peripheral.name}];
            
        }
    }
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
 *
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功,扫描services...%@", peripheral);
    
    [_centralManager stopScan];
    
    [_data setLength:0];
    
    peripheral.delegate = self;
    
    //NSArray *arryServices = [NSArray arrayWithObject:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]];
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


//
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Peripheral Disconnected , error:%@",error.localizedDescription);
    }else{
        NSLog(@"Peripheral Disconnected");
    }
    
    [PeripheralDic removeObjectForKey:[NSString stringWithFormat:@"%@", peripheral.identifier]];
    
    [_delegete onDisconnectBlueDevice:@{PERIPHERAL_IDENTIFER:peripheral.identifier.UUIDString,PERIPHERAL_NAME:peripheral.name}];
    
    NSLog(@"外围连接已断开");
    self.discoveredPeripheral = nil;
}

#pragma mark CBPeripheralDelegate

/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
{
    if(error)
    {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    NSLog(@"发现service,扫描characteristics...");
    self.discoveredPeripheral = peripheral;
    
    for(CBService *service in peripheral.services)
    {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_WRITE]] forService:service];
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_NOTIFY]] forService:service];
    }
    
}

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_WRITE]])
        {
            self.characteristicWrite = characteristic;
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_NOTIFY]])
        {
            //it is the notify characteristic , subscribe to it:
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.characteristicNotify = characteristic;
        }
    }
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_NOTIFY]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying)
    {
        if (self.characteristicNotify != nil && self.characteristicWrite != nil)
        {
            if (_delegete && [_delegete respondsToSelector:@selector(onDidConnectBlueDevice:)])
            {
                NSLog(@"特征匹配成功，可以收发数据.");
                self.currentPeripheral = self.discoveredPeripheral = peripheral;
                
                [_delegete onDidConnectBlueDevice:@{PERIPHERAL_IDENTIFER:peripheral.identifier.UUIDString,PERIPHERAL_NAME:peripheral.name}];
            }
        }
    }
    else
    {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"characteristic(%d) value=%@", (int)characteristic.value.length, characteristic.value);
    
    if (characteristic.value.length > 0)
    {
        @autoreleasepool
        {
            Byte *dataByte = (Byte *)[characteristic.value bytes];
            
            for(int i=0; i < characteristic.value.length; i++)
            {
                uint8_t uartByte = (uint8_t)*(dataByte + i);
                
                if (uartByte == START_FIRST && !start)
                {
                    indexRec = 0;
                }
                
                [self checkData:uartByte];
                indexRec++;
            }
        }
    }

}

-(int)checkData:(uint8_t)byte
{
    @try
    {
        if(byte == START_FIRST && !start)
        {
            byRec[indexRec] = byte;
            start = YES;
        }
        else if(start)
        {
            if (indexRec > lengthRec-5) {
                indexRec = 0;
                memset(byRec,'\0', lengthRec);
            }
            
            byRec[indexRec] = byte;
            
            if (indexRec == 2)
            {
                length = byte * 0x100;
            }
            else if (indexRec == 3)
            {
                length += byte;
            }
            else if (indexRec >= length+5 && byRec[4] == 0x4F && byRec[length+4] == 0x03)
            {
                int a = byRec[length+5];
                int b = [DCCommon LRC_Check:byRec datalen:length+5];
                
                a = a<0?256+a:a;
                b = b<0?256+b:b;
                
                if (a == b)
                {
                    memset(rec,'\0', length-1);
                    memcpy(rec, &byRec[5], length-1);
                    
                    if (_delegete && [_delegete respondsToSelector:@selector(onReceiveCommandResult::)])
                    {
                        [_delegete onReceiveCommandResult:length-1 :rec];
                    }
                }
                
                indexRec = 0;
                memset(byRec,'\0', lengthRec);
                start = NO;
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"exception = %@", [exception callStackSymbols]);
    }
    return 0;
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
//    // Don't do anything if we're not connected
//    if (!self.discoveredPeripheral.isConnected) {
//        return;
//    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_NOTIFY]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}

@end
