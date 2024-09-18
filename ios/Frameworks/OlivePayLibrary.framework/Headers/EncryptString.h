//
//  EncryptString.h
//  TestApp
//
//  Created by Aman Gangurde on 10/11/22.
//

#import <Foundation/Foundation.h>


@interface EncryptString : NSObject
+(NSString*) sha256:(NSString *)input;
-(void)decodeAndPrintCipherBase64Data:(NSString *)cipherText usingHexKey:(NSString *)hexKey hexIV:(NSString *)hexIV;
-(NSString *)aesEncode:(NSData *)plainText usingHexKey:(NSString *)hexKey hexIV:(NSString *)hexIV;
+(NSString *)rsa:(NSString *)originString Key:(NSString *)pubkey;
- (NSString *)utf8StringFromBase64:(NSString*)input;
-(NSString *)hMacRegistration:(NSString *)message PublicKey:(NSString *)key K0:(NSString *)k0;
-(NSString *)hMacGeneral:(NSString *)message K0:(NSString *)k0;
-(NSString *)hMacPayment:(NSString *)message K0:(NSString *)k0;
+(NSString *)generateKeyForAES;
+(void)removeKey;
- (NSString *)aesEncodeToHex:(NSString *)plainText usingHexKey:(NSString *)hexKey hexIV:(NSString *)hexIV;

+ (NSString*)populateHMAC:(NSString*)app_id mobile:(NSString*)mobile token:(NSString*)token deviceId:(NSString*)deviceId random:(NSString*) random; // newly added
+ (NSString*)populateTrustString:(NSString*)message token:(NSString*)token random:(NSString*)random;  // newly added

+ (NSDictionary *)decryptWithA256GCM:(NSData *)dataIn iv:(NSData *)ivData key:(NSData *)keyData aad:(NSData *)aad error:(NSError **)error;
+ (NSData *)encryptWithA256GCM:(NSData *)dataIn iv:(NSData *)ivData key:(NSData *)keyData aad:(NSData *)aad error:(NSError **)error;


@end
