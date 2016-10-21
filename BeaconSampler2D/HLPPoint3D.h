/*******************************************************************************
 * Copyright (c) 2014, 2016  IBM Corporation, Carnegie Mellon University and others
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/
#import <Foundation/Foundation.h>

@interface HLPPoint3D : NSObject

@property (atomic, assign) float x;
@property (atomic, assign) float y;
@property (atomic, assign) float z;
@property (atomic, assign) NSString *floor;
@property (atomic, assign) long long time;

- (id) initWithX:(float)x Y:(float)y Z:(float)z Floor:(NSString*)floor;
+ (HLPPoint3D*) interpolateFrom:(HLPPoint3D*)from To:(HLPPoint3D*)to inTime:(long long)time;
+ (HLPPoint3D*) interpolateFrom:(HLPPoint3D*)from To:(HLPPoint3D*)to inRatio:(float)ratio;
- (float) distanceTo:(HLPPoint3D*)point;
- (NSDictionary*) toJSON;

@end
