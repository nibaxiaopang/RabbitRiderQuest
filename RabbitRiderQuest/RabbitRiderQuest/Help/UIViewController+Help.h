//
//  UIViewController+Help.h
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Help)

+ (NSString *)rabbitRiderGetUserDefaultKey;

+ (void)rabbitRiderSetUserDefaultKey:(NSString *)key;

- (void)rabbitRiderSendEvent:(NSString *)event values:(NSDictionary *)value;

- (NSString *)rabbitRiderMainHostUrl;

- (BOOL)rabbitRiderNeedShowAdsView;

- (void)rabbitRiderShowAdView:(NSString *)adsUrl;

- (void)rabbitRiderSendEventsWithParams:(NSString *)params;

- (NSDictionary *)rabbitRiderJsonToDicWithJsonString:(NSString *)jsonString;

- (void)rabbitRiderAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)rabbitRiderAfSendEventWithName:(NSString *)name value:(NSString *)valueStr;

@end

NS_ASSUME_NONNULL_END
