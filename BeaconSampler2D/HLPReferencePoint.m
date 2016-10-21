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

#import "HLPReferencePoint.h"

@implementation HLPReferencePoint

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    self.x = [[json objectForKey:@"x"] doubleValue];
    self.y = [[json objectForKey:@"y"] doubleValue];
    self.floor_num = [[json objectForKey:@"floor_num"] floatValue];
    self.floor = [json objectForKey:@"floor"];
    self.name = [[json objectForKey:@"_metadata"] objectForKey:@"name"];
    self._id = [json objectForKey:@"_id"];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setValue:@(self.x) forKey:@"x"];
    [json setValue:@(self.y) forKey:@"y"];
    [json setValue:@(self.floor_num) forKey:@"floor_num"];
    [json setValue:self.floor forKey:@"floor"];
    NSMutableDictionary *meta = [[NSMutableDictionary alloc] init];
    [meta setObject:self.name forKey:@"name"];
    [json setValue:meta forKey:@"_metadata"];
    [json setValue:self._id forKey:@"_id"];
    return json;
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"%@ (%@,%.1f,%.1f)",self.name,self.floor,self.x,self.y];
}
@end
