//
//  UNPaySwiper.m
//  UNPaySwiper
//
//  Created by 111 on 15-8-7.
//  Copyright (c) 2015年 dynamicode. All rights reserved.
//

#import "UNPaySwiper.h"
#import "DCCommand.h"
#import "DCCommon.h"


@interface UNPaySwiper() <DCCommandDelegete>
{
    DCCommand *blueCommand;
    cardType  currentCardType;
    int       transType;
    double    transmoney;
}



@end


@implementation UNPaySwiper

@synthesize dicCurrect;



/*
 SDK初始化
 */
+(instancetype)ShareInstance
{
    static UNPaySwiper *_shareInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^(){
    
        _shareInstance = [[self alloc] init];
    
        [_shareInstance Setup];
    });
    
    return _shareInstance;
    
}


-(void)Setup
{
    intDeviceBlueState = STATE_UNACTIVE;
    
    currentCardType = card_mc;
    
    blueCommand = [DCCommand Init];
    
    blueCommand.delgete = self;
    
    [blueCommand InitBluetooth];
    
}



/*
 搜索蓝牙设备
 */
-(void)ScanBlueDevice
{
    intDeviceBlueState = STATE_BUSY;
    [blueCommand ScanBluetooth];
}


-(void)stopScanBlueDevice
{
    intDeviceBlueState = STATE_BUSY;
    [blueCommand StopScanBluetooth];
}

/*
 连接蓝牙设备
 */

-(BOOL)ConnectBlueDevice:(NSDictionary *)dic
{
    
    intDeviceBlueState = STATE_UNACTIVE;
    
    [blueCommand ConnectBluetooth:dic];
    
    return YES;
    
}


/*
 断开蓝牙设备
 */
-(void)DisConnect
{
    dicCurrect = nil;
    intDeviceBlueState = STATE_UNACTIVE;
    self.isConnectBlue = NO;
    [blueCommand disconnectBlue];
}


/*
 获取ksn编号,
 
 */

-(void)GetDeviceKsn
{
    intDeviceBlueState = STATE_BUSY;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [blueCommand ReadDeviceInfo];
    
    });
}


/*
 写入工作密钥
 (密钥指：签到之后，后台下发的三组
 DESKey、（32位密钥 + 8位checkValue = 40位）
 PINKey、（32位密钥 + 8位checkValue = 40位）
 MACKey) （16位密钥 + 8位checkValue = 24位）
 */

-(void)UpdateKey:(NSDictionary *)keyDic
{
    intDeviceBlueState = STATE_BUSY;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        [blueCommand UpdateKey:keyDic];
    
    });
    
}


/*
 (读磁条卡、IC卡需使用同一接口，app代码无需做刷卡类型区分。
 需返回数据：
 1. 磁卡：卡号（明）、track2（密）、track3（可选）等
 2.IC卡：卡号（明）、track2（密）、track3（可选）、IC卡标识、icdata（55)
 

2: 消费
3: 撤销
4: 查余
*/


-(void)ReadCard:(int)type  money:(double)dbmoney
{
    intDeviceBlueState = STATE_BUSY;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            [blueCommand openCardReader:card_all];
        
            transType = type;
            transmoney = dbmoney;
        
        });
    
}




/*
 加密pin
 */
-(void)EncryptPin:(NSString *)Pin
{
    intDeviceBlueState = STATE_BUSY;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSData *data = [DCCommon getHexBytes:Pin];
            NSString *key = @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
            NSData *result = [DCCommon encrypt:data :key];
            [blueCommand EncryptPinBlock:[DCCommon bytess:result] :currentCardType];
    });
    
}


/*
 计算mac
 (消费与查余额时 macdata 位数不同，所以接口对于传入参数的位数最好不要做限制，​若有需要，sdk自行补位）
 */
-(void)GetMacValue:(NSString *)data
{
    intDeviceBlueState = STATE_BUSY;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [blueCommand GetMacValue:data];
        
        });
}

-(void)CancelCard
{
    intDeviceBlueState = STATE_BUSY;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if(self.isConnectBlue)
        {
            [blueCommand resetDevice];
        }
    });
    
}


#pragma DCCommandDelegete

-(void)OnFindBlueDevice:(NSDictionary *)dic
{
    if(_delegate && [_delegate respondsToSelector:@selector(OnFindBlueDevice:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate OnFindBlueDevice:dic];
        });
    }
    
}

-(void)onDidConnectBlueDevice:(NSDictionary *)dic
{
    self.isConnectBlue = YES;
    
    intDeviceBlueState = STATE_IDLE;
    
    if(_delegate && [_delegate respondsToSelector:@selector(onDidConnectBlueDevice:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate onDidConnectBlueDevice:dic];
        });
    }
}

-(void)onDisconnectBlueDevice:(NSDictionary *)dic
{
    self.isConnectBlue = NO;
    intDeviceBlueState = STATE_UNACTIVE;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onDisconnectBlueDevice:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate onDisconnectBlueDevice:dic];
        });
    }
}


-(void)onDidGetDeviceKsn:(NSDictionary *)dicKsn
{
   intDeviceBlueState = STATE_IDLE;

    if(_delegate && [_delegate respondsToSelector:@selector(onDidGetDeviceKsn:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [_delegate onDidGetDeviceKsn:dicKsn];
        
        });
    }
    
}


-(void)onDidUpdateKey:(int)retCode
{
    intDeviceBlueState = STATE_IDLE;
    
    if(_delegate && [_delegate respondsToSelector:@selector(onDidUpdateKey:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate onDidUpdateKey:retCode];
            
        });
    }
}


-(void)OnDetectCard
{
    
    intDeviceBlueState = STATE_IDLE;
    
    if(_delegate && [_delegate respondsToSelector:@selector(OnDetectCard)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate OnDetectCard];
            
        });
    }

}

-(void)OnDidReadCardInfo:(NSDictionary *)dic
{
    intDeviceBlueState = STATE_IDLE;
    
    if(_delegate && [_delegate respondsToSelector:@selector(OnDidReadCardInfo:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate OnDidReadCardInfo:dic];
            
        });
    }

}

//加密Pin结果
-(void)onEncryptPinBlock:(NSString *)encPINblock
{
    intDeviceBlueState = STATE_IDLE;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onEncryptPinBlock:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate onEncryptPinBlock:encPINblock];
            
        });
    }
}


//mac计算结果
-(void)OnDidGetMac:(NSString *)strmac
{
    intDeviceBlueState = STATE_IDLE;
    
    if (_delegate && [_delegate respondsToSelector:@selector(OnDidGetMac:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate OnDidGetMac:strmac];
            
        });
    }
}



-(void)onOpenCardReader:(NSDictionary *)dic
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        currentCardType = [[dic objectForKey:@"1"] intValue];
    
        if(currentCardType  == card_mc)
        {
            [blueCommand ReadMCCard];
        }
        else if(currentCardType == card_ic)
        {
            [blueCommand executionStandardProcess:transType money:transmoney];
        }
        
    });

}

-(void)onResponse:(int)type :(int)status
{
    intDeviceBlueState = STATE_IDLE;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onResponse::)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate onResponse:type:status];
            
        });
    }

}

-(void)onDidCancelCard
{
    intDeviceBlueState = STATE_IDLE;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onDidCancelCard)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate onDidCancelCard];
            
        });
    }
}




#pragma end

@end
