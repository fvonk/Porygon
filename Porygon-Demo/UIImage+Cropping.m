//
//  UIImage+Crop.m
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 05/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import "UIImage+Cropping.h"
#import "MagickWand.h"


@implementation UIImage (Cropping)

+ (UIImage *) convertImageToIndexed:(UIImage *)image noOfColors:(int)noOfColors withoutTransformation:(BOOL) noTransformation
{
    MagickWandGenesis();
    MagickWand * magick_wand = NewMagickWand();
    NSData * dataObject = UIImagePNGRepresentation(image);
    MagickBooleanType status;
    status = MagickReadImageBlob(magick_wand, [dataObject bytes], [dataObject length]);
    if (status == MagickFalse) {
        NSLog(@"OOOOPS");
        return image;
    }
    
    status = MagickQuantizeImage(magick_wand, noOfColors, MagickGetImageColorspace(magick_wand)  , 0, NO, NO);
    if (status == MagickFalse) {
        NSLog(@"OOOPS");
        return image;
    }
    
    size_t my_size;
    unsigned char * my_image = MagickGetImageBlob(magick_wand, &my_size);
    NSData * data = [[NSData alloc] initWithBytes:my_image length:my_size];
    free(my_image);
    magick_wand = DestroyMagickWand(magick_wand);
    MagickWandTerminus();
    UIImage * result = [[UIImage alloc] initWithData:data];
    return result;
}



@end
