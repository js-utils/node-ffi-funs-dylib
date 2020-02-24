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
int GetOwnerPidWithWinName(char* winNameReg, char* winOwnerNameReg);
AXUIElementRef GetWindowWithWinName(char* winNameReg, char* winOwnerNameReg);
// 得到运行的程序窗口
NSRunningApplication *GetRunningAppWithOwnerPid(int ownerPid);
// 将app在前端激活
bool SetForegroundApp(NSRunningApplication *runningApp);
// 发送command+key组合键的命令
void PostEventKey(CGKeyCode key, char* flagMask);
bool PasteboardCopyString(char* string);

void ReleaseAXUIElementRef(AXUIElementRef ref);
@end
