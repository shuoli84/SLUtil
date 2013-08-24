//
// Created by Li Shuo on 13-8-24.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface NSObject (ExecuteWhenDealloc)

+(void)executeWhenDealloc:(NSObject *)object block:(void(^)())block;

@end