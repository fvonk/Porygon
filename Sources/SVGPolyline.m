//
//  SVGPolyline.m
//  Porygon
//
//  Created by Pavel Kozlov on 03/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGPolyline.h"

@implementation SVGPolyline

- (_Nonnull instancetype)initWithIdentifier:(NSString * _Nonnull)identifier withHexColor:(NSString * _Nonnull)hexColor withPoints:(NSArray<NSValue *> * _Nonnull)points
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _hexColor = hexColor;
        _points = points;
    }
    return self;
}

@end
