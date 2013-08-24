//
// Created by Li Shuo on 13-8-24.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class ChangeChannel;

typedef void (^ChangeBlock)(id newValue, id oldValue);
typedef id (^ValueConvertBlock)(id value);

@interface ValueConverter : NSObject
@property (nonatomic, copy) ValueConvertBlock c2oBlock;
@property (nonatomic, copy) ValueConvertBlock o2cBlock;
-(id)initWithC2OBlock:(ValueConvertBlock)c2oBlock o2cBlock:(ValueConvertBlock)o2cBlock;
@end

@protocol ChangeItem
@required
-(void)valueChangedTo:(id)newValue from:(id)oldValue;

/**
* Change action block is the block when changes detected.
*/
-(void)attachToChannel:(ChangeChannel *)channel;
-(void)detach;
@end

@interface ObjectChangeItem : NSObject <ChangeItem>
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSString* keyPath;
@property (nonatomic, strong) ValueConverter* converter;

@property (nonatomic, copy) void (^attachBlock)(ObjectChangeItem*, ChangeChannel *);
@property (nonatomic, copy) void (^detachBlock)(ObjectChangeItem*);

-(id)initWithObject:(id)object keyPath:(NSString*)keyPath;
-(void)valueChangedTo:(id)newValue from:(id)oldValue;
-(void)attachToChannel:(ChangeChannel *)channel;
-(void)detach;
@end

@interface BlockChangeItem : NSObject <ChangeItem>

@property (nonatomic, copy) void (^block)(id newValue, id oldValue);
@property (nonatomic, strong) NSString* name;

-(id)initWithBlock:(ChangeBlock)block;
-(void)attachToChannel:(ChangeChannel *)channel;
-(void)detach;
@end

@interface ChangeChannel : NSObject{

}

@property (nonatomic, strong) id currentValue;
@property (nonatomic, strong) NSMutableArray *changeItems;
@property (nonatomic, copy) ChangeBlock changeSendBlock;
-(id)initWithChangeItems:(NSArray*)changeItems value:(id)value;

-(void)setNewValue:(id)newValue fromOldValue:(id)oldValue;

-(void)appendChangeItem:(id<ChangeItem>)changeItem;
-(void)removeChangeItem:(id<ChangeItem>)changeItem;
@end
