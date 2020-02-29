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

int GetOwnerPidWithName(char* winNameReg, char* winOwnerNameReg) {
    NSMutableDictionary* entry = getWindowWithName(winNameReg, winOwnerNameReg);
   if (entry == nil){
       return 0;
   }
   return [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
}
// https://www.cnblogs.com/andrewwang/p/8635292.html
// https://kb.kutu66.com/objective-c/post_1083773
// https://hant-kb.kutu66.com/others/post_3862789
AXUIElementRef GetWindowWithName(char* winNameReg, char* winOwnerNameReg) {
    NSMutableDictionary* entry = getWindowWithName(winNameReg, winOwnerNameReg);
    if (entry == nil){
      return nil;
    }
    int ownerPid = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
    NSInteger wndNumber=[[entry objectForKey:(id)kCGWindowNumber] intValue];
//    NSString *wndName=[entry objectForKey:(id)kCGWindowName];
    if (ownerPid == 0) {
        return nil;
    }
    //根据ownerPid获取窗口所属的app
    AXUIElementRef appRef = AXUIElementCreateApplication(ownerPid);
    //获取app所有的窗口
    CFArrayRef windowList;
    AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *)&windowList);
    CFRelease(appRef);
    if (windowList) {
        for (int i=0; i<CFArrayGetCount(windowList); i++){
            //遍历app所有窗口，查找跟全局遍历所获得窗口的实体
            AXUIElementRef windowRef = (AXUIElementRef)CFArrayGetValueAtIndex(windowList, i);
            CGWindowID application_window_id = 0;
            // https://stackoverflow.com/questions/6178860/getting-window-number-through-osx-accessibility-api/6365105#6365105
            _AXUIElementGetWindow(windowRef, &application_window_id);
            //找到
            if (application_window_id == wndNumber){
                return windowRef;
            } else {
                CFRelease(windowRef);
            }
        }
    }
    //setting new position
//    AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, position);
//    AXUIElementGetAttributeValue();
    return nil;
}

char *GetWindowTitle(AXUIElementRef window) {
    NSMutableString *multableString = [NSMutableString stringWithString:@""];
    CFTypeRef _someProperty;
    if (AXUIElementCopyAttributeValue(window, (__bridge CFStringRef)NSAccessibilityTitleAttribute, &_someProperty) == kAXErrorSuccess) {
        NSString* strTitle = CFBridgingRelease(_someProperty);
        [multableString appendString:strTitle];
    }
      // 获取标题另一种实现
//    CFStringRef title = NULL;
//    if (AXUIElementCopyAttributeValue(window, kAXTitleAttribute, (CFTypeRef*)&title) == kAXErrorSuccess) {
//        NSString* str2 = CFBridgingRelease(title);
//    }
    return false;
    return (char*)[multableString UTF8String];
}

bool SetForegroundWindowWithName(char* winNameReg, char* winOwnerNameReg) {
    int ownerPid = GetOwnerPidWithName(winNameReg, winOwnerNameReg);
    if (ownerPid > 0) {
        NSRunningApplication * runningApp = GetRunningAppWithOwnerPid(ownerPid);
        SetForegroundApp(runningApp);
        AXUIElementRef window = GetWindowWithName(winNameReg, winOwnerNameReg);
        if (window) {
            return (AXUIElementSetAttributeValue(window, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue) == kAXErrorSuccess);
        }
    }
    return false;
}

NSRunningApplication *GetRunningAppWithOwnerPid(int ownerPid) {
    return [NSRunningApplication runningApplicationWithProcessIdentifier:ownerPid];
}

bool SetForegroundApp(NSRunningApplication *runningApp) {
    return [runningApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

// 根据app获取当前激活窗口
 AXUIElementRef GetFocusWindowWithApp (NSRunningApplication *app) {
    pid_t pid = [app processIdentifier];
    AXUIElementRef appElem = AXUIElementCreateApplication(pid);
    AXUIElementRef window = NULL;
    if (AXUIElementCopyAttributeValue(appElem, kAXFocusedWindowAttribute, (CFTypeRef*)&window) == kAXErrorSuccess) {
        CFRelease(appElem);
        return (AXUIElementRef)window;
    }
    CFRelease(appElem);
    return nil;
}
// 根据ownerPid获取当前激活窗口
AXUIElementRef GetFocusWindowWithOwnerPid (int ownerPid) {
    return GetFocusWindowWithApp(GetRunningAppWithOwnerPid(ownerPid));
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

void ReleaseAXUIElementRef(AXUIElementRef ref) {
    CFRelease(ref);
}
@end
