//
//  DVSPoint.h
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 18/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVSPoint : NSObject
@property (nonatomic) int x;
@property (nonatomic) int y;
- (instancetype)initWithX:(int)x
                        y:(int)y;
@end
