//
//  node_ffi_funs_dylib.m
//  node-ffi-funs-dylib
//
//  Created by sanmu on 2020/2/23.
//  Copyright © 2020 sanmu. All rights reserved.
//

#import "node_ffi_funs_dylib.h"

@implementation node_ffi_funs_dylib

int testInt(void) {
    return 1;
}

char* testString(void) {
    return "123";
}


char* AllWindowInfo () {
//    NSString* pWinName = [NSString stringWithUTF8String:windowName];
//    return (char*)[pWinName UTF8String];
    NSMutableString *multableString = [NSMutableString stringWithString:@""];
    CFArrayRef windowListAll = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    NSArray* arr = CFBridgingRelease(windowListAll);
    for (NSMutableDictionary* entry in arr) {
        if (entry == nil){
            break;
        }
        NSData *data=[NSJSONSerialization dataWithJSONObject:entry options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [multableString appendString:str];
        [multableString appendString:@"\n"];
        
//         NSString *wndName=[entry objectForKey:(id)kCGWindowName];
//         NSString *wndOwnName=[entry objectForKey:(id)kCGWindowOwnerName];
//         NSInteger wndNumber=[[entry objectForKey:(id)kCGWindowNumber] intValue];
//        if (wndName != nil) {
//         return (char*)[multableString UTF8String];
//        }
    }
    return (char*)[multableString UTF8String];
}

@end
