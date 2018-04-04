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

- (instancetype)initWithIdentifier:(NSString *)identifier withHexColor:(NSString *)hexColor withPoints:(NSArray<NSValue *> *)points;

@end

#endif /* SVGPolyline_h */
