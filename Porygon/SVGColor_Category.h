//
//  UIColor+UIColor_Category.h
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 17/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import "PorygonPortability.h"

@interface SVGColor (SVGColor_Category)

- (BOOL)colorEqualsToColor:(SVGColor *)color2 withTolerance:(CGFloat)tolerance;
- (SVGColor *)getMiddleColorWithAnother:(SVGColor *)color2;
- (NSString *)hexStringForColor;
+(SVGColor *)colorFromHexString:(NSString *)hexString;

@end
