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

- (instancetype)initWithIdentifier:(NSString *)identifier withHexColor:(NSString *)hexColor withPoints:(NSArray<NSValue *> *)points
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
