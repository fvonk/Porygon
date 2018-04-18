//
//  UIColor+UIColor_Category.m
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 17/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import "SVGColor_Category.h"

@implementation SVGColor (SVGColor_Category)

- (BOOL)colorEqualsToColor:(SVGColor *)color2 withTolerance:(CGFloat)tolerance {
    CGFloat r1, g1, b1, r2, g2, b2, a1, a2;
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    r1 = r1 * 255.0; r2 = r2 * 255.0;
    g1 = g1 * 255.0; g2 = g2 * 255.0;
    b1 = b1 * 255.0; b2 = b2 * 255.0;
    if (sqrt(pow((r1 - r2), 2) + pow((g1 - g2), 2) + pow((b1 - b2), 2)) <= tolerance * 255.0)
        return YES;
    else
        return NO;
    
    //    if (fabs(r1 - r2) <= tolerance &&
    //        fabs(g1 - g2) <= tolerance &&
    //        fabs(b1 - b2) <= tolerance)
    ////                && fabs(a1 - a2) <= tolerance)
    //        return YES;
    //    return NO;
}

- (SVGColor *)getMiddleColorWithAnother:(SVGColor *)color2 {
    CGFloat r1, g1, b1, r2, g2, b2, a1, a2;
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    return [SVGColor colorWithRed:(r1+r2)/2.0f
                           green:(g1+g2)/2.0f
                            blue:(b1+b2)/2.0f
                           alpha:(a1+a2)/2.0f];
}


- (NSString *)hexStringForColor {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

+(SVGColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [SVGColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
