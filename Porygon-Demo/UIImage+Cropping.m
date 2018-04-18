//
//  UIImage+Crop.m
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 05/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import "UIImage+Cropping.h"
#import "MagickWand.h"
#import "PorygonPortability.h"

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


-(UIImage *)compressImage{
    
    float actualHeight = self.size.height;
    float actualWidth = self.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}


+ (UIImage* )setBackgroundImageByColor:(UIColor *)backgroundColor withFrame:(CGRect )rect{
    
    // tcv - temporary colored view
    UIView *tcv = [[UIView alloc] initWithFrame:rect];
    [tcv setBackgroundColor:backgroundColor];
    
    
    // set up a graphics context of button size
    CGSize gcSize = tcv.frame.size;
    UIGraphicsBeginImageContext(gcSize);
    // add tcv layer to context
    [tcv.layer renderInContext:UIGraphicsGetCurrentContext()];
    // create background image now
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    //    [tcv release];
    
}





+ (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance {
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    //float a = components[3]; // not needed
    
    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;
    
    const float redRange[2] = {
        MAX(r - (tolerance / 2.0), 0.0),
        MIN(r + (tolerance / 2.0), 255.0)
    };
    
    const float greenRange[2] = {
        MAX(g - (tolerance / 2.0), 0.0),
        MIN(g + (tolerance / 2.0), 255.0)
    };
    
    const float blueRange[2] = {
        MAX(b - (tolerance / 2.0), 0.0),
        MIN(b + (tolerance / 2.0), 255.0)
    };
    
    int byteIndex = 0;
    
    while (byteIndex < bitmapByteCount) {
        CGFloat red   = rawData[byteIndex];
        CGFloat green = rawData[byteIndex + 1];
        CGFloat blue  = rawData[byteIndex + 2];
        
//        CGFloat offset = 64;
//        CGFloat R = MAX(0, (red + offset / 2) / offset * offset - 1);
//        CGFloat G = MAX(0, (green + offset / 2) / offset * offset - 1);
//        CGFloat B = MAX(0, (blue + offset / 2) / offset * offset - 1);
//
//        rawData[byteIndex] = R;
//        rawData[byteIndex + 1] = G;
//        rawData[byteIndex + 2] = B;
//        rawData[byteIndex + 3] = 0;
//
        
        if (((red >= redRange[0]) && (red <= redRange[1])) &&
            ((green >= greenRange[0]) && (green <= greenRange[1])) &&
            ((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
            // make the pixel transparent
            //
            rawData[byteIndex] = 0;
            rawData[byteIndex + 1] = 0;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 0;
        }
        
        byteIndex += 4;
    }
    
    UIImage *result = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    
    CGContextRelease(context);
    free(rawData);
    
    return result;
}

+(UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    CGImageRef rawImageRef=image.CGImage;
    
    const CGFloat colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}




+(UIImage *)changeColorTo:(NSArray*) array Transparent: (UIImage *)image
{
    CGImageRef rawImageRef=image.CGImage;
    
//    const CGFloat colorMasking[6] = {100, 255, 100, 255, 100, 255};
    
    const CGFloat colorMasking[6] = {[[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue], [[array objectAtIndex:2] floatValue], [[array objectAtIndex:3] floatValue], [[array objectAtIndex:4] floatValue], [[array objectAtIndex:5] floatValue]};
    
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
