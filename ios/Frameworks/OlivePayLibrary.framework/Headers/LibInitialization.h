//
//  LibInitialization.h
//  PSPApp
//
//  Created by Atmaram on 08/09/16.
//  Copyright © 2016 Reshmi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonLibrary/CommonLibrary.h>
#import "InitializeCommon.h"
//#import <UPI-IOS/OliveUPI-Swift.h>

@interface LibInitialization : NSObject
@property (strong, nonatomic) InitializeCommon *initialize_obj;
- (NSString *)getChallenge: (int)expDays deviceId:(NSString*)device_id appId:(NSString*)appId type:(NSString*)type;
- (BOOL *)registerCommonLib: (NSString*)commonLibToken mobile:(NSString*)mobileNo deviceId:(NSString*)device_id appId:(NSString*)appId hmac:(NSString*)hmac random:(NSString*)random;
-(void) pay:(NSString*)device_token view:(UIViewController *) viewController ;
-(NSString *) getPublicKey;
@end
