//
//  DVSPorygon.m
//  Porygon
//
//  Created by DevinShine on 2017/6/12.
//
//  Copyright (c) 2017 DevinShine <devin.xdw@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  You can use this code to see the effect of sobel
//    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
//    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
//    CGRect rectangle = CGRectMake(0, 0, w, h);
//    CGContextFillRect(context, rectangle);
//    for (DVSPoint *p in edgePointSet) {
//        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
//        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
//        CGRect circleRect = CGRectMake(p.x, p.y, 4, 4);
//        CGContextFillEllipseInRect(context, circleRect);
//    }

#import "DVSPorygon.h"
#import "UIImage+DVSPixel.h"
#import "UIColor+UIColor_Category.h"
#include "delaunay.h"
//#import "Poisson.hpp"
#import "DVSPoint.h"
#import "GPPolygonSet.h"

#define NELEMS(x) (sizeof(x) / sizeof(x[0]))

#define UIColorFromRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                    blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                    alpha:1.0]

int const DVS_GRAY_LIMIT_VALUE = 40;
int const DVS_DEFAULT_RANDOM_COUNT = 500;
int const DVS_DEFAULT_VERTEX_COUNT = 500;
int const DVS_MAX_VERTEX_COUNT = 5000;
int const DVS_MIN_VERTEX_COUNT = 100;


@implementation DVSPorygon

#pragma mark Helper Code
static void shuffle(void *array, size_t n, size_t size) {
    char tmp[size];
    char *arr = (char *)array;
    size_t stride = size * sizeof(char);

    if (n > 1) {
        size_t i;
        for (i = 0; i < n - 1; ++i) {
            size_t rnd = (size_t)rand();
            size_t j = i + rnd / (RAND_MAX / (n - i) + 1);

            memcpy(tmp, arr + j * stride, size);
            memcpy(arr + j * stride, arr + i * stride, size);
            memcpy(arr + i * stride, tmp, size);
        }
    }
}
#pragma mark Sobel Code

int const SOBEL_X[3][3] = {{-1, 0, 1},
                           {-2, 0, 2},
                           {-1, 0, 1}};
int const SOBEL_Y[3][3] = {{-1, -2, -1},
                           {0, 0, 0},
                           {1, 2, 1}};

int get_color(unsigned char *pixel, int w, int h, int x, int y) {
    int index = (w * y + x) * 4;
    if (index < 0 || index >= w * h * 4) {
        return 0;
    }
    return pixel[index];
}

int get_color_i(unsigned char *pixel, int w, int h, int x, int y, int i) {
    int index = (w * y + x) * 4 + i;
    if (index < 0 || index >= w * h * 4) {
        return 0;
    }
    return (int)pixel[index];
}

void set_color_i(unsigned char *pixel, int w, int h, int x, int y, int val, int i) {
    int index = (w * y + x) * 4 + i;
    if (index < 0 || index >= w * h * 4) {
        return;
    }
    pixel[index] = val;
}

int get_x(unsigned char *pixel, int w, int h, int x, int y) {
    if (x <= 0 || y <= 0 || x + 1 == w || y + 1 == h) {
        return 0;
    }
    int pixel_x = ((SOBEL_X[0][0] * get_color(pixel, w, h, x - 1, y - 1)) +
                   (SOBEL_X[0][1] * get_color(pixel, w, h, x, y - 1)) +
                   (SOBEL_X[0][2] * get_color(pixel, w, h, x + 1, y - 1)) +
                   (SOBEL_X[1][0] * get_color(pixel, w, h, x - 1, y)) +
                   (SOBEL_X[1][1] * get_color(pixel, w, h, x, y)) +
                   (SOBEL_X[1][2] * get_color(pixel, w, h, x + 1, y)) +
                   (SOBEL_X[2][0] * get_color(pixel, w, h, x - 1, y + 1)) +
                   (SOBEL_X[2][1] * get_color(pixel, w, h, x, y + 1)) +
                   (SOBEL_X[2][2] * get_color(pixel, w, h, x + 1, y + 1)));
    return pixel_x;
}

int get_y(unsigned char *pixel, int w, int h, int x, int y) {
    if (x <= 0 || y <= 0 || x + 1 == w || y + 1 == h) {
        return 0;
    }
    int pixel_Y = ((SOBEL_Y[0][0] * get_color(pixel, w, h, x - 1, y - 1)) +
                   (SOBEL_Y[0][1] * get_color(pixel, w, h, x, y - 1)) +
                   (SOBEL_Y[0][2] * get_color(pixel, w, h, x + 1, y - 1)) +

                   (SOBEL_Y[1][0] * get_color(pixel, w, h, x - 1, y)) +
                   (SOBEL_Y[1][1] * get_color(pixel, w, h, x, y)) +
                   (SOBEL_Y[1][2] * get_color(pixel, w, h, x + 1, y)) +

                   (SOBEL_Y[2][0] * get_color(pixel, w, h, x - 1, y + 1)) +
                   (SOBEL_Y[2][1] * get_color(pixel, w, h, x, y + 1)) +
                   (SOBEL_Y[2][2] * get_color(pixel, w, h, x + 1, y + 1)));
    return pixel_Y;
}

#pragma mark Setter

- (void)setVertexCount:(int)vertexCount {
    if (vertexCount < DVS_MIN_VERTEX_COUNT) {
        _vertexCount = DVS_MIN_VERTEX_COUNT;
    } else if (vertexCount > DVS_MAX_VERTEX_COUNT) {
        _vertexCount = DVS_MAX_VERTEX_COUNT;
    } else {
        _vertexCount = vertexCount;
    }
}

#pragma mark Public

- (instancetype)init {
    self = [super init];
    if (self) {
        _randomCount = DVS_DEFAULT_RANDOM_COUNT;
        _vertexCount = DVS_DEFAULT_VERTEX_COUNT;
        _isWireframe = false;
        _currentPolylines = [[NSMutableArray alloc] init];
        _minSquare = 0.0005;
        _maxSquare = 0.005;
    }
    return self;
}

- (UIImage *)lowPolyWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    [_currentPolylines removeAllObjects];
    
    struct PixelData pd = [image pixelData];
    unsigned char *pixel = pd.rawData;
    int w = pd.width;
    int h = pd.height;
    
    self.imageWidth = (float)w;
    self.imageHeight = (float)h;
    
    unsigned char *grayPixel = (unsigned char *)calloc(w * h * 4, sizeof(unsigned char));
    unsigned char *sobelPixel = (unsigned char *)calloc(w * h * 4, sizeof(unsigned char));
    
    // to gray
    for (int i = 0; i < w * h * 4; i += 4) {
        int r = pixel[i];
        int g = pixel[i + 1];
        int b = pixel[i + 2];
        int avg = (r + g + b) / 3;
        grayPixel[i] = avg;
        grayPixel[i + 1] = avg;
        grayPixel[i + 2] = avg;
        grayPixel[i + 3] = 255;
    }
    
    int grayCount = 0;
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            int pixelX = get_x(grayPixel, w, h, x, y);
            int pixelY = get_y(grayPixel, w, h, x, y);
            int boundary_gray = ((unsigned int)sqrt(pixelX * pixelX + pixelY * pixelY)) >> 0;
            set_color_i(sobelPixel, w, h, x, y, boundary_gray, 0);
            set_color_i(sobelPixel, w, h, x, y, boundary_gray, 1);
            set_color_i(sobelPixel, w, h, x, y, boundary_gray, 2);
            set_color_i(sobelPixel, w, h, x, y, 255, 3);
            if (boundary_gray > DVS_GRAY_LIMIT_VALUE) {
                grayCount++;
            }
        }
    }
    
    // save edge ponit
    int j = 0;
    del_point2d_t *points = (del_point2d_t *)calloc(grayCount, sizeof(del_point2d_t));
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            if (get_color(sobelPixel, w, h, x, y) > DVS_GRAY_LIMIT_VALUE) {
                points[j].x = x;
                points[j].y = y;
                j++;
            }
        }
    }
    
    // shuffle edge point
    shuffle(points, grayCount, sizeof(points[0]));
    
    int shuffe_count = _vertexCount; // selected edge point count
    NSMutableArray *edgePointArray = [NSMutableArray arrayWithCapacity:shuffe_count];
    for (int i = 0; i < shuffe_count; i++) {
        [edgePointArray addObject:[[DVSPoint alloc] initWithX:points[i].x y:points[i].y]];
    }
    NSMutableSet *edgePointSet = [NSMutableSet setWithArray:edgePointArray];
    
    // add top vertex and bottom vertex
    [edgePointSet addObject:[[DVSPoint alloc] initWithX:0 y:0]];
    [edgePointSet addObject:[[DVSPoint alloc] initWithX:w y:0]];
    [edgePointSet addObject:[[DVSPoint alloc] initWithX:w y:h]];
    [edgePointSet addObject:[[DVSPoint alloc] initWithX:0 y:h]];
    
    // add random point
//    if (_isPoisson) {
//        const auto Points = generatePosisson(_randomCount);
//        for ( auto i = Points.begin(); i != Points.end(); i++ )
//        {
//            DVSPoint *p = [DVSPoint new];
//            p.x = i->x * w;
//            p.y = i->y * h;
//            [edgePointSet addObject:p];
//        }
//    }else{
        for (int i = 0; i < _randomCount; i++) {
            DVSPoint *p = [DVSPoint new];
            p.x = arc4random() % 100 / 100.0 * w;
            p.y = arc4random() % 100 / 100.0 * h;
            [edgePointSet addObject:p];
        }
//    }
    
    
    NSUInteger result_count = [edgePointSet count];
    del_point2d_t *result_points = (del_point2d_t *)calloc(result_count, sizeof(del_point2d_t));
    
    int i = 0;
    for (DVSPoint *p in edgePointSet) {
        result_points[i].x = p.x;
        result_points[i].y = p.y;
        i++;
    }
    
    // step 2. convert to 2d delaunay
    delaunay2d_t *t = delaunay2d_from(result_points, (int)result_count);
    tri_delaunay2d_t *tri = tri_delaunay2d_from(t);
    
    int thickness = 1;
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGContextBeginPath(context);
    
    for (int i = 0, j = 0; i < tri->num_triangles; i++, j += 3) {
        int indice_1 = tri->tris[j];
        int indice_2 = tri->tris[j + 1];
        int indice_3 = tri->tris[j + 2];
        int x1 = tri->points[indice_1].x;
        int y1 = tri->points[indice_1].y;
        int x2 = tri->points[indice_2].x;
        int y2 = tri->points[indice_2].y;
        int x3 = tri->points[indice_3].x;
        int y3 = tri->points[indice_3].y;
        
        // Get the coordinates of the color
        int x = (x1 + x2 + x3) / 3;
        int y = (y1 + y2 + y3) / 3;
        
        float r = get_color_i(pixel, w, h, x, y, 0) / 255.0;
        float g = get_color_i(pixel, w, h, x, y, 1) / 255.0;
        float b = get_color_i(pixel, w, h, x, y, 2) / 255.0;
        float a = get_color_i(pixel, w, h, x, y, 3) / 255.0;
        CGFloat r2, g2, b2, a2;
        
        NSString *identifier = [NSString stringWithFormat:@"Fill-%d", i];
        UIColor *realColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
        NSString *hexColor = [realColor hexStringForColor];
        SVGPolyline *polyline = [[SVGPolyline alloc] initWithIdentifier:identifier withHexColor:hexColor withPoints:@[
                                                                                                                      [NSValue valueWithCGPoint:CGPointMake(tri->points[indice_1].x, tri->points[indice_1].y)],
                                                                                                                      [NSValue valueWithCGPoint:CGPointMake(tri->points[indice_2].x, tri->points[indice_2].y)],
                                                                                                                      [NSValue valueWithCGPoint:CGPointMake(tri->points[indice_3].x, tri->points[indice_3].y)]
                                                                                                                      ]];
        [realColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
        
        [_currentPolylines addObject:polyline];
        
        CGContextSetRGBFillColor(context, r2, g2, b2, a2);
        CGContextSetRGBStrokeColor(context, r2, g2, b2, a2);
        CGContextSetLineWidth(context, thickness);
        CGContextMoveToPoint(context, x1, y1);
        CGContextAddLineToPoint(context, x2, y2);
        CGContextAddLineToPoint(context, x3, y3);
        CGContextAddLineToPoint(context, x1, y1);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGContextDrawPath(context, kCGPathFill);
        
        
        // draw wireframe
        if (_isWireframe) {
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
            CGContextSetLineWidth(context, thickness);
            CGContextMoveToPoint(context, x1, y1);
            CGContextAddLineToPoint(context, x2, y2);
            CGContextAddLineToPoint(context, x3, y3);
            CGContextAddLineToPoint(context, x1, y1);
            CGContextStrokePath(context);
        }
    }
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    tri_delaunay2d_release(tri);
    delaunay2d_release(t);
    free(result_points);
    free(points);
    free(sobelPixel);
    free(grayPixel);
    free(pixel);
    return outputImage;
}

-(void)generateSVG:(void (^)(double))progress andCompletion:(void (^)(NSString *, NSString *))completion
{
    NSString *title = [[NSProcessInfo processInfo] globallyUniqueString];
    NSMutableString* svgAsString = [NSMutableString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
                                    <svg width=\"maxWidthpx\" height=\"maxHeightpx\" viewBox=\"0 0 maxWidth maxHeight\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"> \n\
                                    <title>%@</title> \n\
                                    <desc>Created with Porygon</desc> \n\
                                    <defs></defs> \n\
                                    <g id=\"Page-1\" stroke=\"none\" stroke-width=\"1\" fill=\"none\" fill-rule=\"evenodd\"> \n\
                                    <g id=\"Puzzle\" fill-rule=\"nonzero\">\n", title];

    
    [_currentPolylines sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[(SVGPolyline *)obj1 hexColor] compare:[(SVGPolyline *)obj2 hexColor]];
    }];
    NSMutableArray<NSMutableArray *> *sortedPolylines = [[NSMutableArray alloc] initWithCapacity:256];
    
    NSString *current = [_currentPolylines[0] hexColor];
    NSMutableArray<SVGPolyline *> *colorArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _currentPolylines.count; i++) {
        [_currentPolylines[i] setMerged:NO];
        if ([[UIColor colorFromHexString:current] colorEqualsToColor:[UIColor colorFromHexString:[_currentPolylines[i] hexColor]] withTolerance:_colorTolerance] == YES) {
            [colorArray addObject:_currentPolylines[i]];
        } else {
            if ([colorArray count] > 0)
                [sortedPolylines addObject:colorArray];
            
            colorArray = [[NSMutableArray alloc] init];
            [colorArray addObject:_currentPolylines[i]];
            current = [_currentPolylines[i] hexColor];
        }
    }
    if ([colorArray count] > 0)
        [sortedPolylines addObject:colorArray];
    
    
    NSLog(@"color groups %lu", sortedPolylines.count);
    
    const float minArea = self.imageWidth * self.imageHeight * self.minSquare;//0.0005;
    const float maxArea = self.imageWidth * self.imageHeight * self.maxSquare;//0.005;
    
    NSMutableArray<GPPolygonSet *> *gpPolygonSets = [[NSMutableArray alloc] init];
    
    int colorGroups = 0;
    BOOL areaLimitExceeded = NO;
    for (NSArray<SVGPolyline *> *oneColorArray in sortedPolylines) {
        colorGroups++;
        for (int i = 0; i < oneColorArray.count; i++) {
            if (areaLimitExceeded) {
                areaLimitExceeded = NO;
                i--;
            }
            
            SVGPolyline *polyline = oneColorArray[i];
            if ([polyline merged])
                continue;
            
            GPPolygonSet *gpPolygonSet = [[GPPolygonSet alloc] init];
            [gpPolygonSet setIdentifier:polyline.identifier];
            [gpPolygonSet setHexColor:polyline.hexColor];
            
            GPTriangle *gpTriangle = [[GPTriangle alloc] init];
            [gpTriangle setHexColor:polyline.hexColor];
            [gpTriangle setIdentifier:polyline.identifier];
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:polyline.points];
            [[gpTriangle points] addObjectsFromArray:[orderedSet array]];
            
            [[gpPolygonSet allTriangles] addObject:gpTriangle];
            [gpPolygonSet setAllArea:[gpPolygonSet allArea] + [gpTriangle area]];
            [[gpPolygonSet allPoints] addObjectsFromArray:polyline.points];
            
            
            for (int j = 0; j < oneColorArray.count; j++) {
                if ([oneColorArray[j] merged] || j == i)
                    continue;
                
                @autoreleasepool {
                    SVGPolyline *polyline2 = oneColorArray[j];
                    
                    int count = 0;
                    NSSet *polylinePointsSet = [gpPolygonSet allPoints];
                    
                    for (NSValue *point in polyline2.points) {
                        if ([polylinePointsSet containsObject:point]) {
                            count++;
                        
                            if (count > 1) {
                                [oneColorArray[j] setMerged:YES];
                                
                                GPTriangle *gpTriangle = [[GPTriangle alloc] init];
                                [gpTriangle setHexColor:polyline2.hexColor];
                                [gpTriangle setIdentifier:polyline2.identifier];
                                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:polyline2.points];
                                [[gpTriangle points] addObjectsFromArray:[orderedSet array]];
                                
                                [[gpPolygonSet allTriangles] addObject:gpTriangle];
                                [gpPolygonSet setAllArea:[gpPolygonSet allArea] + [gpTriangle area]];
                                [[gpPolygonSet allPoints] addObjectsFromArray:polyline2.points];
                                
                                if ([gpPolygonSet allArea] >= maxArea) {
                                    areaLimitExceeded = YES;
                                    break;
                                } else {
                                    j = 0;
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (areaLimitExceeded)
                        break;
                }
            }
            [polyline setMerged:YES];
            
            [gpPolygonSets addObject:gpPolygonSet];
        }
        progress(double(colorGroups) / double(sortedPolylines.count) / 3.0);
    }
    
    for (int i = 0; i < gpPolygonSets.count; i++) {
        if ([[gpPolygonSets[i] allTriangles] count] == 1 && [gpPolygonSets[i] allArea] < maxArea) {
            GPTriangle *gpTriangle = [[gpPolygonSets[i] allTriangles] firstObject];

            for (int j = 0; j < gpPolygonSets.count; j++) {
                if (([gpPolygonSets[j] merged] == YES && [[gpPolygonSets[j] allTriangles] count] == 1) || i == j)
                    continue;

                if (([[gpPolygonSets[j] allPoints] containsObject:gpTriangle.points[0]] && [[gpPolygonSets[j] allPoints] containsObject:gpTriangle.points[1]]) ||
                    ([[gpPolygonSets[j] allPoints] containsObject:gpTriangle.points[0]] && [[gpPolygonSets[j] allPoints] containsObject:gpTriangle.points[2]]) ||
                    ([[gpPolygonSets[j] allPoints] containsObject:gpTriangle.points[1]] && [[gpPolygonSets[j] allPoints] containsObject:gpTriangle.points[2]]))
                {
                    [[gpPolygonSets[j] allTriangles] addObject:gpTriangle];
                    [[gpPolygonSets[j] allPoints] addObjectsFromArray:gpTriangle.points];
                    [gpPolygonSets[j] setAllArea:[gpPolygonSets[j] allArea] + [gpTriangle area]];
                    [gpPolygonSets[i] setMerged:YES];
                    break;
                }
            }
        }

        progress(0.33 + double(i) / double(gpPolygonSets.count) / 3.0);
    }

    [gpPolygonSets filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        BOOL merged = [(GPPolygonSet *)object merged];
        [(GPPolygonSet *)object setMerged:NO];
        return !merged;
    }]];

    for (int i = 0; i < gpPolygonSets.count; i++) {
        if ([gpPolygonSets[i] merged] == NO && [gpPolygonSets[i] allArea] <= minArea) {

            for (int j = 0; j < gpPolygonSets.count; j++) {
                if ([gpPolygonSets[j] merged] == YES || i == j)
                    continue;

                NSMutableSet<NSValue *> *gpPolygonSetPointsSet = [[gpPolygonSets[i] allPoints] mutableCopy];
                [gpPolygonSetPointsSet intersectSet:[gpPolygonSets[j] allPoints]];
                if ([gpPolygonSetPointsSet count] > 1) {

                    [[gpPolygonSets[j] allTriangles] addObjectsFromArray:[gpPolygonSets[i] allTriangles]];
                    [[gpPolygonSets[j] allPoints] addObjectsFromArray:[NSArray arrayWithArray:[[gpPolygonSets[i] allPoints] allObjects]]];
                    [gpPolygonSets[j] setAllArea:[gpPolygonSets[j] allArea] + [gpPolygonSets[i] allArea]];
                    [gpPolygonSets[i] setMerged:YES];
                    break;
                }
            }
        }

        progress(0.67 + double(i) / double(gpPolygonSets.count) / 3.0);
    }

    __block float test = 0.0;
    [gpPolygonSets filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        if ([(GPPolygonSet *)object merged] == NO)
            test += [(GPPolygonSet *)object allArea];
        return [(GPPolygonSet *)object merged] == NO;
    }]];
    NSLog(@"groups2 %lu %f", gpPolygonSets.count, test);
    
    //DEBUG
    [gpPolygonSets enumerateObjectsUsingBlock:^(GPPolygonSet * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(GPPolygonSet *)obj allArea] < minArea)
            abort();
    }];
    
    NSMutableSet *stringsSet = [[NSMutableSet alloc] init];//DEBUG
    for (GPPolygonSet *gpPolygonSet in gpPolygonSets) {
        [svgAsString appendFormat:@"<g id=\"%.0f\">\n", gpPolygonSet.allArea];
        
        for (GPTriangle *gpTriangle in [gpPolygonSet allTriangles]) {
            NSMutableString *pointsString = [[NSMutableString alloc] init];
            for (NSValue *point in gpTriangle.points) {
                [pointsString appendFormat:@"%.0f %.0f ", point.CGPointValue.x, point.CGPointValue.y];
            }
            
            //DEBUG
            if ([stringsSet containsObject:pointsString]) {
                NSLog(@"pointsString %@", pointsString);
                abort();
            }
            [stringsSet addObject:pointsString];
            
            [svgAsString appendFormat:@"<polygon id=\"%@\" fill=\"#%@\" points=\"%@\"></polygon>\n", gpTriangle.hexColor, gpTriangle.hexColor, pointsString];
        }
        
        [svgAsString appendFormat:@"</g>\n"];
    }
    
    NSString *result = [NSString stringWithFormat:@"color groups %lu, final groups: %lu" , sortedPolylines.count, gpPolygonSets.count];
    [svgAsString replaceOccurrencesOfString:@"maxWidth" withString:[NSString stringWithFormat:@"%f", self.imageWidth] options:NSLiteralSearch range:NSMakeRange(0, svgAsString.length)];
    [svgAsString replaceOccurrencesOfString:@"maxHeight" withString:[NSString stringWithFormat:@"%f", self.imageHeight] options:NSLiteralSearch range:NSMakeRange(0, svgAsString.length)];
    NSString *endSvg = @"</g>\n</g>\n</svg>";
    [svgAsString appendString:endSvg];
    
    completion(svgAsString, result);
}

#pragma mark Private

@end
