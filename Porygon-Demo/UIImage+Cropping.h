//
//  UIImage+Crop.h
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 05/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Cropping)

+ (UIImage *) convertImageToIndexed:(UIImage *)image noOfColors:(int)noOfColors withoutTransformation:(BOOL) noTransformation;

-(UIImage *)compressImage;

+ (UIImage*)setBackgroundImageByColor:(UIColor *)backgroundColor withFrame:(CGRect )rect;

+ (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance;

+(UIImage *)changeWhiteColorTransparent: (UIImage *)image;

+(UIImage *)changeColorTo:(NSArray*) array Transparent: (UIImage *)image;

//resizing Stuff...
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;



@end
