//
//  DVSPoint.m
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 18/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import "DVSPoint.h"

@implementation DVSPoint

- (instancetype)initWithX:(int)x
                        y:(int)y {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[DVSPoint class]] &&
    self.x == ((DVSPoint *)object).x &&
    self.y == ((DVSPoint *)object).y;
}

- (NSUInteger)hash {
    int times = 1;
    while (times <= _y)
        times *= 10;
    return _x * times + _y;
}
@end
