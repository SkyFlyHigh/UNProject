//
//  DCDeviceCommon.m
//  DynamiPos
//
//  Created by zhongwei.li on 13-7-22.
//  Copyright (c) 2013年 Dynamicode. All rights reserved.
//

#import "DCCommon.h"
#import "math.h"
#import "TripleDES.h"
#import "DC_ISO8583.h"

@implementation DCCommon

/**
 * 对字符串str添加LRC校验位
 * @param str
 */
+(unsigned char)LRC_Check:(unsigned char[])data datalen:(unsigned long)length
{
    uint16_t i;
    uint32_t k=0;
    uint8_t result;
    
    for(i=2;i<length-1;i++)
    {
        k=k^data[i];
    }
    
    result=k;
    return result; 
}

+(NSString *)DateTime_Now:(NSString *)format
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *string = [formatter stringFromDate:today];
    return string;
}

+(int)ToHex:(NSString*)tmpid
{
    int int_ch;
    
    if (tmpid.length % 2) {
        tmpid = [NSString stringWithFormat:@"0%@", tmpid];
    }
    
    unichar hex_char1 = [tmpid characterAtIndex:0]; ////两位16进制数中的第一位(高位*16)
    int int_ch1;
    if(hex_char1 >= '0'&& hex_char1 <='9')
        int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
    else if(hex_char1 >= 'A'&& hex_char1 <='F')
        int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
    else
        int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
    
    
    unichar hex_char2 = [tmpid characterAtIndex:1]; ///两位16进制数中的第二位(低位)
    int int_ch2;
    if(hex_char2 >= '0'&& hex_char2 <='9')
        int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
    else if(hex_char2 >= 'A'&& hex_char2 <='F')
        int_ch2 = hex_char2-55; //// A 的Ascll - 65
    else
        int_ch2 = hex_char2-87; //// a 的Ascll - 97
    
    int_ch = int_ch1+int_ch2;
    return int_ch;
}

// 将字符串如："2b3edf" 转换为 0x2b3edf
+(NSData *)getHexBytes:(NSString *)hexString
{
    @try {
        int j=0;
        u_char bytes[1024];  ///3ds key的Byte 数组， length/2
        
        if (hexString.length % 2) {
            hexString = [NSString stringWithFormat:@"0%@", hexString];
        }
        
        unsigned long len = [hexString length]/2;
        
        for(int i=0; i<[hexString length]; i++)
        {
            int int_ch;  /// 两位16进制数转化后的10进制数
            
            unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
            int int_ch1;
            if(hex_char1 >= '0' && hex_char1 <='9')
                int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
            else if(hex_char1 >= 'A' && hex_char1 <='F')
                int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
            else
                int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
            i++;
            
            unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
            int int_ch2;
            if(hex_char2 >= '0' && hex_char2 <='9')
                int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
            else if(hex_char2 >= 'A' && hex_char2 <='F')
                int_ch2 = hex_char2-55; //// A 的Ascll - 65
            else
                int_ch2 = hex_char2-87; //// a 的Ascll - 97
            
            int_ch = int_ch1+int_ch2;
            
            bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
            j++;
        }
        
        NSData *newData = [NSData dataWithBytes:bytes length:len];
        return newData;
    }
    @catch (NSException *exception) {
        return nil;
    }
	@catch (...) {
        return nil;
    }
}

int getHexChar(unichar c)
{
    int v = 0;
    if(c >= '0' && c <='9'){
        v = (c-48);   // 0 的Ascll - 48
    }else if(c >= 'A' && c <='F'){
        v = (c-55);   // A 的Ascll - 65
    }else if(c >= 'a' && c <='f'){
        v = (c-87);   // a 的Ascll - 97
    }else{
        v = -1;
    }
    return v;
}

+(NSString *)stringFromHexString:(NSString *)hexString
{
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    
    for (int i = 0; i < [hexString length] - 1; i += 2)
    {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    free(myBuffer);
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

+(NSData *)plistReadStr:(NSString *)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:filename];
	
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

// 将字符串如："9559982397527462" 转换为 39353539393832333937353237343632
+(NSData *)getHexFromAscll:(NSString*)string
{
    if( string == nil || string == NULL || [string length] > 1000 ){
        // 数据有问题或者或者数据过长
        NSLog(@"Convert Hex String error: %@", string);
        return nil;
    }
    
	unsigned long len = [string length];
	u_char bytes[len];
    memset(bytes, 0, len);
    
	for(int i=0; i<[string length]; i++)
	{
		unichar hex_char1 = [string characterAtIndex:i];
		bytes[i] = (hex_char1);
	}
    
	NSData *newData = [NSData dataWithBytes:bytes length:len];
	return newData;
}

// 将字符串如："9559982397527462" 转换为 39353539393832333937353237343632
+(NSString *)getAscllFromString:(NSString*)string
{
    if( string == nil || string == NULL || [string length] > 1000 ){
        // 数据有问题或者或者数据过长
        NSLog(@"Convert Hex String error: %@", string);
        return nil;
    }
    
    int len = (int)[string length];
    u_char bytes[len];
    
    for(int i=0; i<[string length]; i++)
    {
        unichar hex_char1 = [string characterAtIndex:i];
        bytes[i] = (hex_char1);
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:len];
    return [self bytess:newData];
}

// 将字符串如："39353539393832333937353237343632" 转换为 "9559982397527462"
+(NSString *)getStringFromAscll:(NSString*)string
{
    if( string == nil || string == NULL || [string length] % 2 != 0 || [string length] > 1000 ){
        // 数据有问题或者或者数据过长
        NSLog(@"Convert Hex String error: %@", string);
        return nil;
    }
    
    unsigned long len = [string length]/2;
    unichar bytes[len];
    
    for(int i=0; i<[string length]; i++)
    {
        unichar hex_char1 = [string characterAtIndex:i];
        hex_char1 = getHexChar(hex_char1);
        i++;
        unichar hex_char2 = [string characterAtIndex:i];
        hex_char2 = getHexChar(hex_char2);
        
        bytes[i/2] = hex_char1 * 0x10 + hex_char2;
    }
    
    NSString *encrypted = [NSString stringWithCharacters:(const unichar*)bytes length:len];

    return encrypted;
}

//把string以byte字符串形式
+(NSString *)bytess:(NSData *)_data
{
	NSString *hashSN = [_data description];
	hashSN = [hashSN stringByReplacingOccurrencesOfString:@" " withString:@""];
	hashSN = [hashSN stringByReplacingOccurrencesOfString:@"<" withString:@""];
	hashSN = [hashSN stringByReplacingOccurrencesOfString:@">" withString:@""];
	NSLog(@"sn0000=%@",hashSN);
	return hashSN;
}

+(NSData *)encrypt:(NSData *)data :(NSString *)key
{
    if ([key length] < 8)
    {
        return nil;
    }
    
    NSData *dataKey = [self getHexBytes:key];
    NSData *result = [TripleDES doCipher:data operation:kCCEncrypt alg:kCCAlgorithmDES keySize:kCCKeySizeDES key:(Byte *)dataKey.bytes];
    NSLog(@"sn0000=%@",result);
    return result;
}

+(NSData *)decrypt:(NSData *)data :(NSString *)key
{
    if ([key length] < 8)
    {
        return nil;
    }
    
    NSData *dataKey = [self getHexBytes:key];
    NSData *result = [TripleDES doCipher:data operation:kCCDecrypt alg:kCCAlgorithmDES keySize:kCCKeySizeDES key:(Byte *)dataKey.bytes];
    return result;
}

//解析TLV
+(NSMutableDictionary *)ResolveTLV:(int)length :(unsigned char[])by
{
    int len = 0, T = 0, L = 0, lenT = 0;
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    for(int i=0; i<length; i++)
    {
        if (i == len)
        {
            T = by[i];
            
            if (T == 0x5F || T == 0x9F || T == 0xDF) {
                lenT = 2;
                i++;
                T = T * 0x100 + by[i];
            } else {
                lenT = 1;
            }
        }
        else if (i == lenT + len)
        {
            L = by[i];
            len += L + lenT + 1;
            //T = T & 0x3F;
            
            NSString *strV = @"";
            
            for(int j=0; j<L; j++)
            {
                strV = [NSString stringWithFormat:@"%@%0.2X", strV, by[++i]];
            }
            
            NSLog(@"T:%X L:%d V:%@", T, L, strV);
            
            [dic setValue:strV forKey:[NSString stringWithFormat:@"%X", T]];
        }
    }
    
    return dic;
}

//组装8583
+(NSData *)Assemble8583:(NSMutableDictionary *)dic
{
    unsigned char by[1024];
    memset(by, '\0', 1024);
    int m = 0;
    
    NSArray *keys = [dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableArray *arraySorted = [NSMutableArray arrayWithArray:sortedArray];
    
    for (int i=0; i<[arraySorted count]; i++)
    {
        if ([arraySorted[i] isEqualToString:@"254"])
        {
            [arraySorted removeObjectAtIndex:i];
            [arraySorted insertObject:@"254" atIndex:0];
        }
        else if ([arraySorted[i] isEqualToString:@"255"])
        {
            [arraySorted removeObjectAtIndex:i];
            [arraySorted insertObject:@"255" atIndex:1];
        }
    }
    
    for (NSString *key in arraySorted)
    {
        NSString *value = [dic objectForKey:key];
        
        DC_ISO8583 iso = Tbl8583[[key intValue]-1];
        
        if ([key intValue] == 0) {
            iso.datatyp = 0;
        }
        
        //检查是否定长
        if (iso.variable_flag > 0)
        {
            switch (iso.variable_flag -1)
            {
                case 1:
                    by[m] = [value length]/10*16 + [value length]%10;
                    m++;
                    break;
                case 2:
                {
                    NSInteger length = [value length];
                    if (iso.datatyp == 2) {
                        length /= 2;
                    }
                    
                    by[m] = length/100/10*16 + length/100%10;
                    m++;
                    by[m] = length%100/10*16 + length%100%10;
                    m++;
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        /*0 -- BCD, 1 -- ASCII, 2 -- BINARY*/
        NSData *dataValue = nil;
        
        switch (iso.datatyp)
        {
            case 0:
            {
                if (iso.variable_flag == 0) {
                    if ([value length]%2 > 0) {
                        value = [NSString stringWithFormat:@"%@0", value];
                    }
                } else {
                    if ([value length]%2 > 0) {
                        value = [NSString stringWithFormat:@"%@0", value];
                    }
                }
                
                dataValue = [DCCommon getHexBytes:value];
            }
                break;
            case 1:
            {
                dataValue = [DCCommon getHexFromAscll:value];
            }
                break;
            case 2:
            {
                if ([value length]%2 > 0) {
                    value = [NSString stringWithFormat:@"%@0", value];
                }
                dataValue = [DCCommon getHexBytes:value];
            }
                break;
                
            default:
                break;
        }
        
        Byte *bitValue = (Byte *)[dataValue bytes];
        
        memcpy(&by[m], bitValue, [dataValue length]);
        m += [dataValue length];
        
        if ([key isEqualToString:@"0"])
        {
            NSData *data = [self bytearrFromArray:keys];
            unsigned char *bitMap = (unsigned char *)[data bytes];
            memcpy(&by[m], bitMap, 8);
            m += 8;
        }
    }
    
    NSData *dataResult = [NSData dataWithBytes:by length:m];
    return dataResult;
}

//解析8583
+(NSMutableDictionary *)Resolve8583:(int)length :(unsigned char[])by
{
    printf("\n");
    for (int i=0; i<length; i++) {
        printf(" %0.2X", *(by+i));
    }
    printf("\n");
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    int m = 0;
    unsigned char fieldData[2];
    unsigned char bitMap[8];
    
    memset(fieldData, '\0', 2);
    memset(bitMap, '\0', 8);

    memcpy(fieldData, by+m, 2);
    m += 2;
    memcpy(bitMap, by+m, 8);
    m += 8;
    
    char *a = [self bytearrToStr:bitMap length:8];
    
    for (int i=0; i<64; i++)
    {
        if (a[i] == '1')
        {
            //NSLog(@"i=%d", i+1);
            
            DC_ISO8583 iso = Tbl8583[i];
            int len = 0;
            int len2 = 0;
            
            //检查是否定长
            if (iso.variable_flag == 0)
            {
                len = iso.length;
                len2 = len;
                
                //检查数据类型，判断是否是BCD来判断数据长度的计算方法
                switch (iso.datatyp) {
                    case 0:
                        len = len%2 == 0 ? len/2 : len/2+1;
                        break;
                    case 1:
                        len2 = len*2;
                        break;
                        
                    default:
                        len2 = len*2;
                        break;
                }
            }
            else
            {
                switch (iso.variable_flag -1)
                {
                    case 1:
                        len = (by[m]>>4)*10 + (by[m]&0x0f);
                        break;
                    case 2:
                        len = ((by[m]>>4)*10 + (by[m]&0x0f))*100 + ((by[m+1]>>4)*10 + (by[m+1]&0x0f));
                        break;
                        
                    default:
                        break;
                }
                
                m += iso.variable_flag -1;
                len2 = len;
                
                if (iso.datatyp == 0) {
                    len = len%2 == 0 ? len/2 : len/2+1;
                } else {
                    len2 = len*2;
                }
            }
            
            unsigned char chars[len];
            memset(chars, '\0', len);
            memcpy(chars, by+m, len);
            
            NSMutableString *value = [NSMutableString new];
            
            for (int j=0; j<len; j++)
            {
                [value appendFormat:@"%0.2X", chars[j]];
            }
            
            NSString *value2 = [value substringToIndex:len2];
            //NSLog(@"value2=%@", value2);
            [dic setValue:value2 forKey:[NSString stringWithFormat:@"%d", i+1]];
            
            m += len;
        }
    }
    return dic;
}

////以二进制方式打印数组
///data 待打印二进制
/// length待打印长度
+(NSData *)bytearrFromArray:(NSArray *)array
{
    unsigned char chars[64];
    memset(chars, '0', 64);
    
    Byte bitMap[8];
    memset(bitMap, '0', 8);
    
    for(NSString *str in array)
    {
        chars[[str intValue]-1] = '1';
    }
    
    for(int i=0; i<8; i++)
    {
        int m = 0;
        
        for(int j=0; j<8; j++)
        {
            if (chars[i*8 + j] == '1') {
                int n = (i+1)*8 - (i*8 + j + 1);
                m +=  pow(2, n);
            }
        }
        bitMap[i] = (Byte)m;
    }
    
    NSData *data = [NSData dataWithBytes:bitMap length:8];
    return data;
}

////以二进制方式打印数组
///data 待打印二进制
/// length待打印长度
+(char *)bytearrToStr:(unsigned  char *)data length:(int)length
{
    char char_1 = '1',char_0 = '0';
    char *chars = (char *)malloc(length*8+1);
    chars[length*8] = '\n';
    
    for(int i=0;i<length;i++)
    {
        Byte bb = data[i];
        for(int j=0;j<8;j++)
        {
            if(((bb>>j)&0x01) == 1)
            {
                chars[i*8+j] = char_1;
            }else{
                chars[i*8+j] = char_0;
            }
        }
        char temp = 0;
        temp =  chars[i*8+0];chars[i*8+0] = chars[i*8+7];chars[i*8+7] = temp;
        temp =  chars[i*8+1];chars[i*8+1] = chars[i*8+6];chars[i*8+6] = temp;
        temp =  chars[i*8+2];chars[i*8+2] = chars[i*8+5];chars[i*8+5] = temp;
        temp =  chars[i*8+3];chars[i*8+3] = chars[i*8+4];chars[i*8+4] = temp;
    }
    
    return chars;
}

@end
