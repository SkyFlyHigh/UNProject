//
//  DCDeviceCommon.h
//  DynamiPos
//
//  Created by zhongwei.li on 13-7-22.
//  Copyright (c) 2013年 Dynamicode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCCommon : NSObject

+(unsigned char)LRC_Check:(unsigned char[])data datalen:(unsigned long)length;
+(int)ToHex:(NSString*)tmpid;

+(NSData *)getHexBytes:(NSString *)hexString;

+(NSString *)stringFromHexString:(NSString *)hexString;
+(NSData *)getHexFromAscll:(NSString*)string;

+(NSString *)getAscllFromString:(NSString*)string;
+(NSString *)getStringFromAscll:(NSString*)string;

+(NSString *)bytess:(NSData *)_data;

+(NSData *)plistReadStr:(NSString *)filename;

+(NSData *)encrypt:(NSData *)data :(NSString *)key;
+(NSData *)decrypt:(NSData *)data :(NSString *)key;

+(NSString *)DateTime_Now:(NSString *)format;

//解析TLV
+(NSMutableDictionary *)ResolveTLV:(int)length :(unsigned char[])by;

//组装8583
+(NSData *)Assemble8583:(NSMutableDictionary *)dic;
//解析8583
+(NSMutableDictionary *)Resolve8583:(int)length :(unsigned char[])by;

@end
