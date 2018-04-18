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

@end
