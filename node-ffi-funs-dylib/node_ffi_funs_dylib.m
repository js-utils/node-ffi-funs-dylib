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

char* AllWindowInfoWithPid (int pid) {
    AXUIElementRef app = AXUIElementCreateApplication(pid);
    CFArrayRef result;
    AXUIElementCopyAttributeValues((AXUIElementRef) app, kAXWindowsAttribute, 0, 99999, &result);
    NSArray* arr = CFBridgingRelease(result);
    NSString* string = [NSString stringWithFormat:@"%lu", arr.count];
     return (char*)[string UTF8String];
}

NSMutableDictionary* getWindowWithName(char* winNameReg, char* winOwnerNameReg) {
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
            return entry;
        }
        
    }
    return nil;
}

int GetOwnerPidWithWinName(char* winNameReg, char* winOwnerNameReg) {
    NSMutableDictionary* entry = getWindowWithName(winNameReg, winOwnerNameReg);
   if (entry == nil){
       return 0;
   }
   return [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
}

NSRunningApplication *GetRunningAppWithOwnerPid(int ownerPid) {
    return [NSRunningApplication runningApplicationWithProcessIdentifier:ownerPid];
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

bool PasteboardCopyString(char* string) {
    NSString* stringToWrite = [NSString stringWithUTF8String:string];
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
    return [pasteBoard setString:stringToWrite forType:NSPasteboardTypeString];
}

@end
