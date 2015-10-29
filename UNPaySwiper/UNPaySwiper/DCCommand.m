//
//  DCCommand.m
//  UNPaySwiper
//
//  Created by 111 on 15-8-11.
//  Copyright (c) 2015年 dynamicode. All rights reserved.
//

#import "DCCommand.h"
#import "DCCommon.h"


#define  ERROR_OK 0
#define  ERROR_FAIL_CONNECT_DEVICE 0x0001
#define  ERROR_FAIL_GET_KSN  0x0002
#define  ERROR_FAIL_READCARD 0x0003
#define  ERROR_FAIL_ENCRYPTPIN 0x0004
#define  ERROR_FAIL_GETMAC     0x0005
#define  ERROR_FAIL_MCCARD   0x0007

@implementation DCCommand

@synthesize delgete = _delgete;

static DCBluetooth *bluetooth = nil;


static BOOL isCanRecData = NO;

static unsigned char ucData[1024];//指令数据
static unsigned long ulDatalen;// 指令数据长度

//超时
static NSTimer *timeout = nil;

//指令数组
static NSMutableArray *arrayData = nil;

static DCCommand *shareRoot = nil;

+ (DCCommand *) Init
{
    @synchronized(self)
    {
        if(shareRoot == nil)
        {
            shareRoot = [[self alloc] init];  //add autorelease: 考虑多线程的情况
        }
        
        return shareRoot;
    }
    
    return shareRoot;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (shareRoot == nil)
        {
            shareRoot = [super allocWithZone:zone];
            return  shareRoot;
        }
    }
    return nil;
}

-(void)InitBluetooth
{
    index = 0;
    bluetooth = [DCBluetooth Init];
    bluetooth.delegete = self;
    
    [bluetooth InitBlue];
    
    arrayData = [[NSMutableArray alloc] init];
    
    memset(ucData, 0, 1024);
    ulDatalen = 0;
}

-(void)FinalizeBluetooth
{
    [bluetooth finalizeBlue];
}

-(void)ScanBluetooth
{
    [bluetooth ScanBluetooth];
}

-(void)StopScanBluetooth
{
    [bluetooth StopScanBluetooth];
}

-(void)ConnectBluetooth:(NSDictionary *)dic
{
    [bluetooth ConnectBluetooth:dic];
}


#pragma DCBluetoothDelegete start

/*! 搜素到一个蓝牙设备 (每搜索到一个设备就会回调一次)
 \param  btDevice 蓝牙设备标识
 \return 无
 */
- (void)OnFindBlueDevice:(NSDictionary *)dic
{
    if(_delgete && [_delgete respondsToSelector:@selector(OnFindBlueDevice:)])
    {
        [_delgete OnFindBlueDevice:dic];
    }
}

/*! 成功连接到一个蓝牙设备回调
 \param  btDevice 蓝牙设备标识
 \return 无
 */
- (void)onDidConnectBlueDevice:(NSDictionary *)dic
{
    if(_delgete && [_delgete respondsToSelector:@selector(onDidConnectBlueDevice:)])
    {
        [_delgete onDidConnectBlueDevice:dic];
    }
}


//失去连接到设备
-(void)onDisconnectBlueDevice:(NSDictionary *)dic
{
    if(_delgete && [_delgete respondsToSelector:@selector(onDisconnectBlueDevice:)])
    {
        [_delgete onDisconnectBlueDevice:dic];
    }
}

#pragma end

//清空数组
-(void)clear
{
    memset(ucData,0, 1024);
    ulDatalen = 0;
}

//插入数据
-(void)insert:(unsigned long)value
{
    ucData[ulDatalen] = value;
    ulDatalen++;
}

-(void)InsertCommand:(NSString *)strData
{
    NSData *data = [DCCommon getHexBytes:strData];
    
    Byte *byData =(Byte *)[data bytes];
    
    for(int i = 0; i < [data length]; i++)
    {
        [self insert:*(byData + i)];
    }
}

-(NSData *)GetCommand_LRC:(NSString *)strData
{
    [self clear];
    [self InsertCommand:strData];
    [self insert:[DCCommon LRC_Check:ucData datalen:ulDatalen]];
    return [NSData dataWithBytes:ucData length:ulDatalen];
}

-(NSData *)GetCommand:(NSString *)strData
{
    [self clear];
    
    NSData *data = [DCCommon getHexBytes:strData];
    
    Byte *byData =(Byte *)[data bytes];
    
    //
    [self insert:0x4C];
    [self insert:0x4B];
    
    //length
    [self insert:0x00];
    [self insert:0x00];
    
    [self insert:0x2F];
    
    [self insert:*(byData + 0)];
    [self insert:*(byData + 1)];
    
    if(index > 0x100)
    {
        index = 0;
    }
    
    index = index + 2;
    
    [self insert:index];
    
    for(int i = 2; i < [data length]; i++)
    {
        [self insert:*(byData + i)];
    }
    
    //length
    ucData[2] = (ulDatalen-4)/100/10*16 + (ulDatalen-4)/100%10;
    ucData[3] = (ulDatalen-4)%100/10*16 + (ulDatalen-4)%100%10;
    
    [self insert:0x03];
    
    [self insert:[DCCommon LRC_Check:ucData datalen:ulDatalen]];
    
    return [NSData dataWithBytes:ucData length:ulDatalen];
    
}

-(NSData *)GetAppendCommand:(NSString *)strData
{
    [self InsertCommand:strData];
    
    return [NSData dataWithBytes:ucData length:ulDatalen];
}


-(void)UpdateKey:(NSDictionary *)dic
{
    [self clear];
    
    [self insert:0x4C];
    [self insert:0x4B];
    
    [self insert:0x00];//length
    [self insert:0x00];
    
    [self insert:0x2F];
    
    [self insert:0x1E];
    [self insert:0x04];
    
    if (index > 0x100) {
        index = 0;
    }
    index += 2;
    
    [self insert:index];
    

    
    [self insert:0x01];
    
    NSString *strDESKey = [dic objectForKey:@"DESKey"];
    NSString *strPINKey = [dic objectForKey:@"PINKey"];
    NSString *strMacKey = [dic objectForKey:@"MacKey"];
    
    unsigned long len = [strDESKey length]/2 + [strPINKey length]/2 + [strMacKey length]/2;
    
    [self insert:len];
    //[self InsertCommand:strDESKey];
    [self InsertCommand:strPINKey];
    [self InsertCommand:strMacKey];
    [self InsertCommand:strDESKey];
    
    ucData[2] = (ulDatalen - 4)/100/10*16 + (ulDatalen - 4)/100%10;
    ucData[3] = (ulDatalen-4)%100/10*16 + (ulDatalen-4)%100%10;

    [self insert:0x03];
    [self insert:[DCCommon LRC_Check:ucData datalen:ulDatalen]];
    
    NSData *data = [NSData dataWithBytes:ucData length:ulDatalen];
    
    
    [self SendCommand:data];
    
}



-(void)ReadDeviceInfo
{
    NSData *data = [self GetCommand_LRC:@"4C4B00042FF1010603"];
    
    [self SendCommand:data];
}


///开启读卡器 D1 21
- (void)openCardReader:(int)type
{
    NSData *data = nil;
    
    //4C4B00102FD121 00 0101 0102011E 03
    //4C4B00102FD121 00 0101 0202011E 03
    //4C4B00102FD121 00 0101 0302011E 03
    
    switch (type) {
            
        case 1:
            data = [self GetCommand_LRC:@"4C4B00102FD1210001010102011E03"];
            break;
            
        case 2:
            data = [self GetCommand_LRC:@"4C4B00102FD1210001010202011E03"];
            break;
            
        case 3:
            data = [self GetCommand_LRC:@"4C4B00102FD1210001010302011E03"];
            break;
            
        default:
            data = [self GetCommand_LRC:@"4C4B00102FD1210001010302011E03"];
            break;
    }
    
    [self SendCommand:data];
}

//读磁条卡 magnetic card D1 22

-(void)ReadMCCard
{
    //4C4B00192FD122 00 0101 0202 0A 00000000FFFFFF000000 03
    NSData *data = [self GetCommand_LRC:@"4C4B00192FD12200010106020A00000000FFFFFF00000003"];
    
    [self SendCommand:data];
}

//PBOC执行标准流程  1C 05
-(void)executionStandardProcess:(int)transType money:(double)dbmoney
{
    [self clear];
    [self insert:0x4C];
    [self insert:0x4B];
    [self insert:0x00];//length
    [self insert:0x00];
    [self insert:0x2F];
    [self insert:0x1C];
    [self insert:0x05];
    
    if (index > 0x100) {
        index = 0;
    }
    index += 2;
    
    [self insert:index];
    
    [self insert:0x01];
    [self insert:0x00];
    //交易日期
    [self insert:0x9A];
    [self insert:0x03];
    NSString *strDate = [DCCommon DateTime_Now:@"yyMMdd"];
    [self InsertCommand:strDate];
    //时分秒
    [self insert:0x9F];
    [self insert:0x21];
    [self insert:0x03];
    NSString *strTime = [DCCommon DateTime_Now:@"HHmmss"];
    [self InsertCommand:strTime];
    //授权金额
    [self insert:0x9F];
    [self insert:0x02];
    [self insert:0x06];
    NSString *str9F02 = [NSString stringWithFormat:@"%012.0f", dbmoney*100];
    [self InsertCommand:str9F02];
    //授权金额（其他）
    [self insert:0x9F];
    [self insert:0x03];
    [self insert:0x06];
    NSString *str9F03 = @"000000000000";
    [self InsertCommand:str9F03];
    //交易类型
    [self insert:0x9C];
    [self insert:0x01];
    
    switch (transType)
    {
        case 1://消费
            [self insert:0x00];
            break;
//        case 3://撤销
//            [self insert:0x20];
//            break;
        case 2://查余
            [self insert:0x31];
            break;
            
        default:
            [self insert:0x31];
            break;
    }
    
    //自定义的交易类型	0x01：标准的授权过程
    /*
     0x0B：电子现金消费
     0x21：电子现金指定账户圈存
     0x22：电子现金非指定账户圈存
     0x23：电子现金现金圈存
     0x24：电子现金圈提
     0x0E：电子现金日志（和PBOC日志一样）
     0x25：电子现金余额查询
     0x26：电子现金现金圈存撤销
     */
    [self insert:0xDF];
    [self insert:0x7C];
    [self insert:0x01];
    [self insert:0x01];
    //当前卡片介质，非接，接触1）	0x00 接触式 0x01非接触
    [self insert:0xDF];
    [self insert:0x70];
    [self insert:0x01];
    [self insert:0x00];
    //PBOC流程指示2）	0x01 读应用数据 0x06第一次密文生成
    [self insert:0xDF];
    [self insert:0x71];
    [self insert:0x01];
    [self insert:0x06];
    //强制联机标识	0x00 不强制 0x01强制联机
    [self insert:0xDF];
    [self insert:0x72];
    [self insert:0x01];
    [self insert:0x01];
    //账户选择标识	0x00 不支持 0x01支持
    [self insert:0xDF];
    [self insert:0x73];
    [self insert:0x01];
    [self insert:0x00];
    //附加数据	自定义 联机密码参数
    [self insert:0xDF];
    [self insert:0x74];
    [self insert:0x00];
    //需要响应的标签对象列表，该标签内容为合法的PBOC的标签列表，即TLV中T的列表	参考输出数据中的TAG标签值
    [self insert:0xDF];
    [self insert:0x35];
    NSString *strDF35 = @"9F33959F1A9A9F37829F369F269F109C9F025F2A9F039F349F27849F74DF75DF785A575F245F34";
    [self insert:strDF35.length/2];
    [self InsertCommand:strDF35];
    
    //设置命令长度
    ucData[2] = (ulDatalen-4)/100/10*16 + (ulDatalen-4)/100%10;
    ucData[3] = (ulDatalen-4)%100/10*16 + (ulDatalen-4)%100%10;
    ucData[9] = ulDatalen-10;
    
    [self insert:0x03];
    [self insert:[DCCommon LRC_Check:ucData datalen:ulDatalen]];
    
    NSData *data = [NSData dataWithBytes:ucData length:ulDatalen];
    [self SendCommand:data];
    
}

//加密PINblock  1A 21
- (void)EncryptPinBlock:(NSString *)PINblock :(int)cardType
{
    [self clear];
    [self insert:0x4C];
    [self insert:0x4B];
    [self insert:0x00];//length
    [self insert:0x00];
    [self insert:0x2F];
    [self insert:0x1A];
    [self insert:0x21];
    
    if (index > 0x100) {
        index = 0;
    }
    index += 2;
    
    [self insert:index];
    
    [self insert:0x01];
    [self insert:0x08];
    [self InsertCommand:PINblock];
    
    [self insert:0x02];
    [self insert:0x01];
    [self insert:(cardType==1?1:0)];
    
    //[self insert:0x01];
    
    //设置命令长度
    ucData[2] = (ulDatalen-4)/100/10*16 + (ulDatalen-4)/100%10;
    ucData[3] = (ulDatalen-4)%100/10*16 + (ulDatalen-4)%100%10;
    
    [self insert:0x03];
    [self insert:[DCCommon LRC_Check:ucData datalen:ulDatalen]];
    
    NSData *data = [NSData dataWithBytes:ucData length:ulDatalen];
    [self SendCommand:data];

}


-(void)GetMacValue:(NSString *)datastr
{
    NSData *dataInfo = [DCCommon getHexBytes:datastr];
    
    Byte *byInfo = (Byte*)[dataInfo bytes];
    
    NSInteger length1 = 0;
    NSInteger length2 = [dataInfo length];
    
    if (length2 <= 127) {
        length1 = dataInfo.length + 9;
    } else if (length2 <= 255) {
        length1 = dataInfo.length + 10;
    } else {
        length1 = dataInfo.length + 11;
    }
    
    [self clear];
    [self insert:0x4C];
    [self insert:0x4B];
    [self insert:length1/100/10*16 + length1/100%10];
    [self insert:length1%100/10*16 + length1%100%10];
    [self insert:0x2F];
    [self insert:0x1E];
    [self insert:0x05];
    
    if (index > 0x100) {
        index = 0;
    }
    index += 2;
    
    [self insert:index];
    
    [self insert:0x01];
    
    if (length2 <= 127) {
        [self insert:length2];
    } else if (length2 <= 255) {
        [self insert:0x81];
        [self insert:length2];
    } else {
        [self insert:0x82];
        [self insert:length2/0x100];
        [self insert:length2%0x100];
    }
    
    for (int i=0; i<[dataInfo length]; i++) {
        [self insert:*(byInfo+i)];
    }
    [self insert:0x02];
    [self insert:0x01];
    [self insert:0x5A];
    [self insert:0x03];
    [self insert:[DCCommon LRC_Check:ucData datalen:ulDatalen]];
    
    NSData *data = [NSData dataWithBytes:ucData length:ulDatalen];
    [self SendCommand:data];
}

//取消/复位操作
- (void)resetDevice
{
    bluetooth.isCanSendData = YES;
    NSData *data = [self GetCommand_LRC:@"4C4B00042F1D080003"];
    [arrayData removeAllObjects];
    [self SendCommand:data];
}


-(void)SendCommand:(NSData *)data
{
    @try {
        
        [arrayData addObject:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if(timeout)
            {
                [timeout invalidate];
            }
            
            timeout = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(Timeout:) userInfo:nil repeats:NO];
        });
        
        
        isCanRecData = YES;
        
        if([bluetooth isCanSendData])
        {
            #if defined(DEBUG)||defined(_DEBUG)
            Byte *testByte = (Byte *)[arrayData[0] bytes];
                        printf("SendCommand len:(%d) ", [arrayData[0] length]);
                        for (int i=0; i<[arrayData[0] length]; i++)
                        {
                            printf(" %0.2x", *(testByte + i));
                        }
                        printf("\n");
            #endif
            [bluetooth SendData:arrayData[0]];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Blue send Command Progress=%@", exception);
    }
}

-(void)Timeout:(NSTimer *)timer
{
    [arrayData removeAllObjects];
    
    if(_delgete && [_delgete respondsToSelector:@selector(onResponse::)])
    {
        [_delgete onResponse:0x1FF1 :7];
    }
    
}

- (void)disconnectBlue
{
    [bluetooth DCdisappearBlue];
}

#pragma DCBluetoothDelgete

-(void)onReceiveCommandResult:(int)length :(unsigned char[])data
{
    [timeout invalidate];
    
#if defined(DEBUG)||defined(_DEBUG)
    printf("\nreceiveCommandResult:(%d) ", length);
    for (int i=0; i<length; i++)
    {
        printf(" %0.2x", *(data + i));
    }
    printf("\n");
#endif
    
    if(isCanRecData && length > 5)
    {
        isCanRecData = NO;
        
        int type = data[0] * 0x100 + data[1];
        int status = data[4]-0x30;
        
        if(status == 0)
        {
            switch (type)
            {
                case 0xD121:  //打开读卡器
                    
                    {
                        unsigned char byRec[length-5];
                        memcpy(byRec, &data[5], length-5);
                        
                        
                        if(_delgete &&[_delgete respondsToSelector:@selector(OnDetectCard)])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [_delgete OnDetectCard];
                                
                            });
                        }
                        
                        NSMutableDictionary *dic = [DCCommon ResolveTLV:length-5 :byRec];
                        
                        if(_delgete && [_delgete respondsToSelector:@selector(onOpenCardReader:)])
                        {
                            if([arrayData count] > 0)
                            {
                                [arrayData removeObjectAtIndex:0];
                            }
                            [_delgete onOpenCardReader:dic];
                        }
                        
                        
                        
                    
                    }
                    
                    break;
                case 0xD122: //读磁条卡
                    
                    {
                        unsigned char byRec[length-5];
                        memcpy(byRec, &data[5], length - 5);
                        
                        NSMutableDictionary *dic = [DCCommon ResolveTLV:length-5 :byRec];
                        
                        dic[kMCCount] = [dic[kMCCount] stringByReplacingOccurrencesOfString:@"F" withString:@""];
                        //dic[kMCTrackOneData] = [dic[kMCTrackOneData] stringByReplacingOccurrencesOfString:@"F" withString:@""];
                        
                        
                        NSString *strRet = [NSString stringWithString: [dic objectForKey:@"1"]];
                        
                        if([strRet isEqualToString:@"00"])
                        {
                            if(_delgete && [_delgete respondsToSelector:@selector(OnDidReadCardInfo:)])
                            {
                                [_delgete OnDidReadCardInfo:dic];
                            }
                        }
                        else if([strRet isEqualToString:@"FF"])
                        {
                            status = ERROR_FAIL_MCCARD;
                            if(_delgete && [_delgete respondsToSelector:@selector(onResponse::)])
                            {
                                [_delgete onResponse:type :status];
                            }
                        }
                        

                    
                    }
                    
                    break;
                    
                case 0xF101: //读取设备信息
                {
                    unsigned char byRec[length-5];
                    memcpy(byRec, &data[5], length-5);
                    
                    NSMutableDictionary *dic = [DCCommon ResolveTLV:length-5 :byRec];
                    
                    NSString *sn = [DCCommon getStringFromAscll:dic[@"1"]];
                    dic[@"1"] = [sn substringWithRange:NSMakeRange (4, sn.length-4)];
                    dic[@"3"] = [DCCommon getStringFromAscll:dic[@"3"]];
                    dic[@"4"] = [DCCommon getStringFromAscll:dic[@"4"]];
                    dic[@"6"] = [DCCommon getStringFromAscll:[dic[@"6"] stringByReplacingOccurrencesOfString:@"FF" withString:@""]];
                    dic[@"7"] = [DCCommon getStringFromAscll:dic[@"7"]];
                    dic[@"A"] = [DCCommon getStringFromAscll:dic[@"A"]];
                    
                    //3字节交易流水号+8字节POS终端代码+15字节的商户代码
                    NSString *string = [dic objectForKey:@"B"];
                    
                    if ([string length] >= 6)
                    {
                        dic[@"B"] = [string substringWithRange:NSMakeRange (0,6)];
                    }
                    
                    if(_delgete && [_delgete respondsToSelector:@selector(onDidGetDeviceKsn:)])
                    {
                        //NSDictionary *dicKSN = [NSDictionary dictionaryWithObject:dic[@"6"] forKey:@"KSN"];
                        
                        [_delgete onDidGetDeviceKsn:dic];
                    }
                }
                    
                    break;
                    
                case 0xF103: //更新设备信息
                    
                    break;
                    
                case 0x1C05:   //PBOC执行标准流程
                {
                    unsigned char byRec[length-8];
                    memcpy(byRec, &data[8], length - 8);
                    NSMutableString *str55ICData = [NSMutableString string];
                    
                    for (int i=0; i<length-8; i++)
                    {
                        if (byRec[i] == 0xdf && byRec[i+1] == 0x75)
                        {
                            break;
                        }
                        [str55ICData appendFormat:@"%0.2X", byRec[i]];
                    }
                    
                    if(str55ICData.length > 100)
                    {
                        NSMutableDictionary *dic = [DCCommon ResolveTLV:length-8 :byRec];
                        dic[@"55"] = str55ICData;
                        dic[@"5A"] = [dic[@"5A"] stringByReplacingOccurrencesOfString:@"F" withString:@""];
                       // dic[@"57"] = [dic[@"57"] stringByReplacingOccurrencesOfString:@"F" withString:@""];
                        dic[@"5F24"] = [dic[@"5F24"] substringToIndex:4];
                    
                    
                         if(_delgete && [_delgete respondsToSelector:@selector(OnDidReadCardInfo:)])
                         {
                            [_delgete OnDidReadCardInfo:dic];
                         }
                    }
                }
                    
                    break;
                
                case 0x1C06:   //PBOC二次授权
                    
                    break;
                    
                case 0x1D08:   //取消/复位操作
                    
                    if(_delgete && [_delgete respondsToSelector:@selector(onDidCancelCard)])
                    {
                        [_delgete onDidCancelCard];
                    }
                    
                    break;
                    
                case 0x1D09:   //升级应用/固件
                    
                    break;
                
                case 0x1E04:   //签到成功,写工作秘钥
                    
                    if(_delgete && [_delgete respondsToSelector:@selector(onDidUpdateKey:)])
                    {
                        [_delgete onDidUpdateKey:ERROR_OK];
                    }
                    
                    break;
                
                case 0x1E05:  //计算Mac
                {
                    unsigned char byRec[length-5];
                    memcpy(byRec, &data[5], length-5);
                    
                    NSDictionary *dic = [DCCommon ResolveTLV:length-5 :byRec];
                    
                    if (_delgete && [_delgete respondsToSelector:@selector(OnDidGetMac:)]) {
                        [_delgete OnDidGetMac:dic[@"1"]];
                    }
                }
                    
                    break;
                    
                case 0x1A21: //计算PINblock密文
                {
                    unsigned char byRec[length-5];
                    memcpy(byRec, &data[5], length-5);
                    
                    NSDictionary *dic = [DCCommon ResolveTLV:length-5 :byRec];
                    
                    if (_delgete && [_delgete respondsToSelector:@selector(onEncryptPinBlock:)]) {
                        [_delgete onEncryptPinBlock:dic[@"1"]];
                    }
                }
                    
                    break;
                    
                case 0x80AA:   //清除个人化
                    
                    break;
                    
                case 0x1E06:   //用户信息写入
                    
                    break;
                    
                case 0x1E08:   //用户信息读出
                    
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            if(_delgete && [_delgete respondsToSelector:@selector(onResponse::)])
            {
                [_delgete onResponse:type :status];
            }
        }
    }
    else
    {
        int type = data[0] * 0x100 + data[1];
        int status = data[4]-0x30;
        
        if(type == 0x1E04)
        {
            if(status == 0)
            {
                if(_delgete && [_delgete respondsToSelector:@selector(onDidUpdateKey:)])
                {
                    [_delgete onDidUpdateKey:ERROR_OK];
                }
            }
        }
        
        if(status != 0)
        {
            if(_delgete && [_delgete respondsToSelector:@selector(onResponse::)])
            {
                [_delgete onResponse:type :status];
            }
        }
        

    }
    
    
     //将当前已回复指令删除
    if([arrayData count] > 0)
    {
        [arrayData removeObjectAtIndex:0];
        
        
        //判断缓存里面是否还存在指令
        if([arrayData count] > 0)
        {
            isCanRecData = YES;
            NSData *data = [arrayData objectAtIndex:0];
            
            [bluetooth SendData:data];
        }
        
    }
    
    
    
}


#pragma end



@end
