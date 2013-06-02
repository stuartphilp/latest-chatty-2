//
//  Categories.h
//  LatestChatty2
//
//  Created by patch-e on 5/28/13.
//
//

@interface NSString (StringAdditions)

- (NSString *)stringByUnescapingHTML;
+ (NSString *)rgbaFromUIColor:(UIColor *)color;
+ (NSString *)hexFromUIColor:(UIColor *)color;

@end

@interface UIColor(ColorAdditions)

// Common colors
+ (UIColor *)lcAuthorColor;
+ (UIColor *)lcBlueColor;
+ (UIColor *)lcLightGrayTextColor;
+ (UIColor *)lcDarkGrayTextColor;
+ (UIColor *)lcTextShadowColor;
+ (UIColor *)lcOverlayColor;

// Table cell colors
+ (UIColor *)lcGroupedCellColor;
+ (UIColor *)lcGroupedCellLabelColor;
+ (UIColor *)lcGroupedTitleColor;
+ (UIColor *)lcSeparatorColor;

// Expiration colors
+ (UIColor *)lcPostExpirationColor;
+ (UIColor *)lcPostExpiredColor;

// Category colors
+ (UIColor *)lcInformativeColor;
+ (UIColor *)lcOffTopicColor;
+ (UIColor *)lcStupidColor;
+ (UIColor *)lcPoliticalColor;
+ (UIColor *)lcNotWorkSafeColor;

// Settings colors
+ (UIColor *)lcSwitchOnColor;
+ (UIColor *)lcSwitchOffColor;
+ (UIColor *)lcSliderThumbColor;

@end

@interface NSDictionary(DictionaryAdditions)

+ (NSDictionary *)whiteTextAttributesDictionary;
+ (NSDictionary *)grayTextAttributesDictionary;
+ (NSDictionary *)textShadowAttributesDictionary;

@end