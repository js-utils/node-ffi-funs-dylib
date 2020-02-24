//
//  node_ffi_funs_dylib.m
//  node-ffi-funs-dylib
//
//  Created by sanmu on 2020/2/23.
//  Copyright © 2020 sanmu. All rights reserved.
//

#import "node_ffi_funs_dylib.h"

@implementation node_ffi_funs_dylib

int testInt(int num) {
    return num;
}

char* testString(char* str) {
    NSString* pStr = [NSString stringWithUTF8String:str];
    return (char*)[pStr UTF8String];
}

bool validateStringWithRegex(NSString* string, NSString* regex) {
    int location = (int)[string rangeOfString:regex options:NSRegularExpressionSearch].location;
    return location >= 0;
}

bool stringIsPresent (NSString* string) {
 if(string != nil && ![string isEqual:[NSNull null]] && string.length != 0 && ![[string lowercaseString] isEqualToString:@"(null)"])
    {
        return YES;
    }
    return NO;
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

NSRunningApplication *GetRunningAppWithName(char* winNameReg, char* winOwnerNameReg) {
    NSString* pWinOwnerName = [NSString stringWithUTF8String:winOwnerNameReg];
    NSString* pWinName = [NSString stringWithUTF8String:winNameReg];
    CFArrayRef windowListAll = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    NSArray* arr = CFBridgingRelease(windowListAll);
    for (NSMutableDictionary* entry in arr) {
        if (entry == nil){
            break;
        }
        NSString *wndOwnName=[entry objectForKey:(id)kCGWindowOwnerName];
        NSString *wndName=[entry objectForKey:(id)kCGWindowName];
        bool isOwnerFind = !stringIsPresent(pWinOwnerName) || (stringIsPresent(pWinOwnerName) && stringIsPresent(wndOwnName) && validateStringWithRegex(wndOwnName, pWinOwnerName));
        bool isSelfFind = !stringIsPresent(pWinName) || (stringIsPresent(pWinName) && stringIsPresent(wndName) && validateStringWithRegex(wndName, pWinName));
        if (isOwnerFind && isSelfFind) {
            return [NSRunningApplication runningApplicationWithProcessIdentifier:[[entry objectForKey:(id)kCGWindowOwnerPID] intValue]];
        }
        
    }
    return nil;
}
bool SetForegroundApp(NSRunningApplication *runningApp) {
    return [runningApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

void PostEventKey(CGKeyCode key, char* flagMask) {
    NSString* pFlagMask = [NSString stringWithUTF8String:flagMask];
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);

    CGEventRef keyDown = CGEventCreateKeyboardEvent(source, key, TRUE);
    if (validateStringWithRegex(pFlagMask, @"COMMAND")) {
        CGEventSetFlags(keyDown, kCGEventFlagMaskCommand);
    }
    CGEventRef keyUp = CGEventCreateKeyboardEvent(source, key, FALSE);

    CGEventPost(kCGAnnotatedSessionEventTap, keyDown);
    CGEventPost(kCGAnnotatedSessionEventTap, keyUp);

    CFRelease(keyUp);
    CFRelease(keyDown);
    CFRelease(source);
}

@end
