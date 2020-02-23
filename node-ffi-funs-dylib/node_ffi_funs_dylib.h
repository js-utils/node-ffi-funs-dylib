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
@end
