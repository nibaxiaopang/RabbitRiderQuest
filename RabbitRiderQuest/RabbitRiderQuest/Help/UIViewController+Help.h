//
//  UIViewController+Help.h
//  RabbitRiderQuest
//
//  Created by RabbitRiderQuest on 2024/12/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Help)

- (void)rabbitRiderShowAlertWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle;
- (void)rabbitRiderDismissKeyboard;
- (void)rabbitRiderSetNavigationTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font;
- (void)rabbitRiderNavigateToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIActivityIndicatorView *)rabbitRiderShowLoadingIndicatorWithStyle:(UIActivityIndicatorViewStyle)style;
- (void)rabbitRiderHideLoadingIndicator:(UIActivityIndicatorView *)indicator;
- (void)rabbitRiderAnimateViewTransitionToView:(UIView *)newView duration:(NSTimeInterval)duration;
- (void)rabbitRiderAddChildViewController:(UIViewController *)childViewController toContainerView:(UIView *)containerView;
- (void)rabbitRiderRemoveChildViewController;
- (void)rabbitRiderOpenURL:(NSURL *)url;

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
