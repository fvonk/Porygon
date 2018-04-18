//
//  SVGPolyline.h
//  Porygon
//
//  Created by Pavel Kozlov on 03/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#ifndef SVGPolyline_h
#define SVGPolyline_h

@interface SVGPolyline: NSObject

@property (nonatomic, readonly) NSArray<NSValue *> *points;
@property (nonatomic, readonly) NSString *hexColor;
@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, assign) BOOL merged;

- (_Nonnull instancetype)initWithIdentifier:(NSString * _Nonnull)identifier withHexColor:(NSString * _Nonnull)hexColor withPoints:(NSArray<NSValue *> * _Nonnull)points;

@end

#endif /* SVGPolyline_h */
