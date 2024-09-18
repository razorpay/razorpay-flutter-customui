//
//  CryptLib.h
//

//#import "OlivePayLibrary.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface Encrypt : NSObject

-  (NSData *)encrypt:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSString *) md5:(NSString *) input;
-  (NSString*) sha256:(NSString *)key length:(NSInteger) length;
-(NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv;
@end
