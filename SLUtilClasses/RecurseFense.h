//
// Created by Li Shuo on 13-8-11.
// Copyright (c) 2013 com.menic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface RecurseFense : NSObject

-(id)initWithObject:(id)object functionKey:(const void *)key;
-(id)initWithObject:(id)object functionKey:(const void *)key lockName:(NSString*)lockName;

-(void)unDefense;
@end