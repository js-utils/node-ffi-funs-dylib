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
// 得到运行的程序窗口
NSRunningApplication *GetRunningAppWithName(char* winNameReg, char* winOwnerNameReg);
// 将app在前端激活
bool SetForegroundApp(NSRunningApplication *runningApp);
// 发送command+key组合键的命令
void PostEventKey(CGKeyCode key, char* flagMask);

@end
