//
//  UIColor+UIColor_Category.h
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 17/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColor_Category)

- (BOOL)colorEqualsToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance;
- (UIColor *)getMiddleColorWithAnother:(UIColor *)color2;
- (NSString *)hexStringForColor;
+(UIColor *)colorFromHexString:(NSString *)hexString;

@end
