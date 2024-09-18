//
//  InitializeCommon.h
//  PSPApp
//
//  Created by Reshmi on 09/10/15.
//  Copyright © 2015 Reshmi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonLibrary/CommonLibrary.h>

//#import <CommonLibrary/CommonLibrary.h>
#define PSPNAME @"psp1"
//#define TOKEN @"33324e68476972614e4b39474e36574a36636d6a73304e584a4a636c4b65384a"//ipad

@interface InitializeCommon : NSObject
{
    
}
+ (InitializeCommon *)sharedInstance;
-(NSString*)hmacApp_id: (NSString*)appId mobile:(NSString*)mobileNumber device:(NSString*)device_id token:(NSString*)device_token;
- (NSString *)sha256_string:(NSString *)input;
+(void)alertview : (NSString*)title : (NSString*)msg : (id)class_obj;
+(BOOL)isNullString:(NSString*)_inputString;
+ (NSString *) stringFromHex:(NSString *)str;


//@property(nonatomic,retain) Common *common_obj;////////Common Library Object

@property(nonatomic,retain)NSDictionary *Salt;
@property(nonatomic,retain)NSDictionary *controls; /////////show control fields
@property(nonatomic,retain)NSString *keyCode;

@property(nonatomic,retain)NSString *keyXmlPayload;
@property(nonatomic,retain)NSString *keyid;


@property(nonatomic,retain)NSDictionary *Cred;///UI Parameter of transaction/////////////////////////////////////////










@property(assign) float theFontSize;
//@property(nonatomic,retain)NSString *version;
//+(void)alertview : (NSString*)title : (NSString*)msg : (id)class_obj;
@end
