//
//  GPPolygonSet.h
//  Porygon
//
//  Created by Pavel Kozlov on 13/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#ifndef GPPolygonSet_h
#define GPPolygonSet_h

@interface GPTriangle : NSObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *hexColor;
@property (nonatomic) NSMutableArray<NSValue *> *points;

-(instancetype)init;
- (float)area;

@end

@interface GPPolygonSet : NSObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *hexColor;
@property (nonatomic) NSMutableSet<NSValue *> *allPoints;
@property (nonatomic) NSMutableArray<GPTriangle *> *allTriangles;
@property (nonatomic, assign) float allArea;
@property (nonatomic, assign) BOOL merged;

-(instancetype)init;

@end



#endif /* GPPolygonSet_h */
