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

#import "HLPUtil.h"

@implementation HLPUtil


+ (NSDictionary*) loadJSONFile:(NSString*)full {
    NSData *data = [NSData dataWithContentsOfFile:full];
    
    if (data) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            return json;
        }
        NSLog(@"%@", error);
    }
    return @{};
}

+ (NSString *)toJSONString:(NSObject *)json {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:0 error:nil] encoding:NSUTF8StringEncoding];
}


+ (NSString*) dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmssSS"];
    NSDate* date = [NSDate date];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSArray *)getFileTypeOf:(NSString *)type atPath:(NSString *)path {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    for(NSString *content in [fileManager contentsOfDirectoryAtPath:path error:nil]) {
        if ([content hasSuffix:type]) {
            [array addObject:[path stringByAppendingPathComponent:content]];
        }
    }
    return array;
}

+(BOOL)deleteFile:(NSString *)path {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}

+(BOOL)moveFile:(NSString *)path toDir:(NSString *)dir {
    [HLPUtil makeDir:dir];
    
    NSString *toPath = [dir stringByAppendingPathComponent:path.pathComponents.lastObject];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager moveItemAtPath:path toPath:toPath error:nil];
}

+(BOOL)makeDir:(NSString*)dir {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
}

@end
