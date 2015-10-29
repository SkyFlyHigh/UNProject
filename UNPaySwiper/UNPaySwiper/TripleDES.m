//
//  3des.m
//  3des
//
//  Created by qin qin on 11-9-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TripleDES.h"

@implementation TripleDES

+(NSData *) doCipher:(NSData *)plainText operation:(CCOperation)encryptOrDecrypt alg:(CCAlgorithm)alg keySize:(size_t)keySize key:(const void *)mainkey
{
    const void * vplainText;
    size_t plainTextBufferSize;
    
	plainTextBufferSize = [plainText length];
	vplainText = [plainText bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t * bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
	
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES)
	& ~(kCCBlockSize3DES - 1);
	
    bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
	
    const void * vkey = mainkey;   //char字符
	
    uint8_t iv[kCCBlockSize3DES];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
	
    ccStatus = CCCrypt(encryptOrDecrypt,
                       alg,
                       kCCOptionECBMode,
                       vkey,
                       keySize,
                       nil, //iv,
                       vplainText, //plainText
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
	
	NSData * myData = [NSData dataWithBytes:(const void *)bufferPtr
                                     length:(NSUInteger)movedBytes];
	return myData;
}

@end
