//
//  3des.h
//  3des
//
//  Created by qin qin on 11-9-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface TripleDES : NSObject

+(NSData *) doCipher:(NSData *)plainText operation:(CCOperation)encryptOrDecrypt alg:(CCAlgorithm)alg keySize:(size_t)keySize key:(const void *)mainkey;

@end
