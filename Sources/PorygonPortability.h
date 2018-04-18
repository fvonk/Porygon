//
//  PorygonPortability.h
//  Porygon
//
//  Created by Pavel Kozlov on 18/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

#ifndef PorygonPortability_h
#define PorygonPortability_h

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
@compatibility_alias SVGImage UIImage;
@compatibility_alias SVGColor UIColor;
//@compatibility_alias PSVGBezierPath UIBezierPath;

#else

#import <AppKit/AppKit.h>
@compatibility_alias SVGImage NSImage;
@compatibility_alias SVGColor NSColor;
//@compatibility_alias PSVGBezierPath NSBezierPath;

#endif


#endif /* PorygonPortability_h */
