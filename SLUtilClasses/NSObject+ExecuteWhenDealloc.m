//
// Created by Li Shuo on 13-8-24.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSObject+ExecuteWhenDealloc.h"
#import "NSObject+AssociatedObjects.h"


@interface ExecuteWrapper : NSObject

@property (nonatomic, copy) void(^block)();

-(void)dealloc;
@end

@implementation ExecuteWrapper
-(void)dealloc{
    if(self.block){
        self.block();
    }
}
@end

@implementation NSObject (SLUtil)

+(void)executeWhenAnyDealloc:(NSArray*)objects block:(void(^)())block{
    for (NSObject *obj in objects){
        [NSObject executeWhenDealloc:objects block:block];
    }
}

+(void)executeWhenDealloc:(NSObject *)object block:(void(^)())block{
    static char key;
    NSMutableArray *executeWrapperArray = [object associatedValueForKey:&key];
    if ( executeWrapperArray == nil){
        executeWrapperArray = [NSMutableArray array];
        [object associateValue:executeWrapperArray withKey:&key];
    }
    ExecuteWrapper *executeWrapper = [[ExecuteWrapper alloc] init];
    executeWrapper.block = block;
    [executeWrapperArray addObject:executeWrapper];
}
@end