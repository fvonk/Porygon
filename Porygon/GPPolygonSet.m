//
//  GPPolygonSet.m
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 13/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PorygonPortability.h"
#import "GPPolygonSet.h"

@implementation GPTriangle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.points = [[NSMutableArray alloc] init];
    }
    return self;
}

- (float)area {
    CGPoint A = [(NSValue *)self.points[0] CGPointValue];
    CGPoint B = [(NSValue *)self.points[1] CGPointValue];
    CGPoint C = [(NSValue *)self.points[2] CGPointValue];
    
    float area = abs(A.x * (B.y - C.y) + B.x * (C.y - A.y) + C.x * (A.y - B.y)) / 2.0;
    
    return area;
}

@end


@implementation GPPolygonSet

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allTriangles = [[NSMutableArray alloc] init];
        self.allArea = 0.0;
        self.merged = NO;
        self.allPoints = [[NSMutableSet alloc] init];
    }
    return self;
}

@end
