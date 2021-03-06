//
//  node_ffi_funs_dylib.h
//  node-ffi-funs-dylib
//
//  Created by sanmu on 2020/2/23.
//  Copyright © 2020 sanmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@interface node_ffi_funs_dylib : NSObject

int testInt(int num);
char* testString(char* str);
char* AllWindowInfo (void);
char* AllWindowInfoWithPid (int pid);
int GetOwnerPidWithName(char* winNameReg, char* winOwnerNameReg);
AXUIElementRef GetWindowWithName(char* winNameReg, char* winOwnerNameReg);
char *GetWindowTitle(AXUIElementRef window);
// 得到运行的程序窗口
NSRunningApplication *GetRunningAppWithOwnerPid(int ownerPid);
// 将app在前端激活
bool SetForegroundWindowWithName(char* winNameReg, char* winOwnerNameReg);
bool SetForegroundApp(NSRunningApplication *runningApp);
// 根据app获取当前激活窗口
AXUIElementRef GetFocusWindowWithApp (NSRunningApplication *app);
// 根据ownerPid获取当前激活窗口
AXUIElementRef GetFocusWindowWithOwnerPid (int ownerPid);
// 判断两个窗口是否相同
bool isEqualTwoWindow (AXUIElementRef win1, AXUIElementRef win2);
// 发送command+key组合键的命令
void PostEventKey(CGKeyCode key, char* flagMask);
bool PasteboardCopyString(char* string);

void ReleaseAXUIElementRef(AXUIElementRef ref);
@end
