//
//  UIImage+Crop.h
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 05/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import "PorygonPortability.h"

@interface SVGImage (Cropping)

+ (SVGImage *) convertImageToIndexed:(SVGImage *)image noOfColors:(int)noOfColors withoutTransformation:(BOOL) noTransformation;

-(SVGImage *)compressImage;

+ (SVGImage*)setBackgroundImageByColor:(UIColor *)backgroundColor withFrame:(CGRect )rect;

+ (SVGImage*) replaceColor:(UIColor*)color inImage:(SVGImage*)image withTolerance:(float)tolerance;

+(SVGImage *)changeWhiteColorTransparent: (SVGImage *)image;

+(SVGImage *)changeColorTo:(NSArray*) array Transparent: (SVGImage *)image;

//resizing Stuff...
+ (SVGImage *)imageWithImage:(SVGImage *)image scaledToSize:(CGSize)newSize;



@end
