//
// Created by Li Shuo on 13-8-24.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ChangeChannel.h"
#import "NSObject+BlockObservation.h"
#import "RecurseFense.h"
#import "NSArray+BlocksKit.h"

@implementation ValueConverter
-(id)initWithC2OBlock:(ValueConvertBlock)c2oBlock o2cBlock:(ValueConvertBlock)o2cBlock {
    self = [super init];

    if(self){
        _c2oBlock = c2oBlock;
        _o2cBlock = o2cBlock;
    }

    return self;
}
@end

@implementation ObjectChangeItem{
    NSString* _observerIdentifier;
}

-(id)initWithObject:(id)object keyPath:(NSString *)keyPath {
    self = [super init];

    if(self){
        _object = object;
        _keyPath = keyPath;
    }

    return self;
}

-(void)valueChangedTo:(id)newValue from:(id)oldValue{
    id value = newValue;
    if(_converter){
        value = _converter.c2oBlock(newValue);
    }
    [_object setValue:value forKey:_keyPath];
}

-(void)attachToChannel:(ChangeChannel *)channel{
    if(self.attachBlock){
        self.attachBlock(self, channel);
    }
    else{
        typeof(self) __weak weakSelf = self;
        ChangeWithSenderBlock changeBlock = [channel.changeSendBlock copy];
        _observerIdentifier = [_object addObserverForKeyPath:_keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld task:^(id obj, NSDictionary *change) {
            id oldValue = change[NSKeyValueChangeOldKey];
            id newValue = change[NSKeyValueChangeNewKey];
            if(weakSelf.converter){
                oldValue = weakSelf.converter.o2cBlock(oldValue);
                newValue = weakSelf.converter.o2cBlock(newValue);
            }
            changeBlock(newValue, oldValue, weakSelf);
        }];
    }
}

-(void)detach {
    if(self.detachBlock){
        self.detachBlock(self);
    }
    else{
        [_object removeObserversWithIdentifier:_observerIdentifier];
    }
}
@end

@implementation BlockChangeItem
-(id)initWithBlock:(void (^)(id newValue, id oldValue))block{
    self = [super init];
    if(self){
        self.block = block;
    }
    return self;
}

-(void)valueChangedTo:(id)newValue from:(id)oldValue {
    self.block(newValue, oldValue);
}

-(void)attachToChannel:(ChangeChannel *)channel{
    return;
}

-(void)detach {
    return;
}
@end

@implementation ChangeChannel

-(id)init{
    return [self initWithChangeItems:nil value:nil];
}

-(id)initWithChangeItems:(NSArray*)changeItems value:(id)value{
    self = [super init];

    if(self){
        typeof(self) __weak weakSelf = self;
        self.changeSendBlock = ^(id newValue, id oldValue, id obj){
            [weakSelf setNewValue:newValue fromOldValue:oldValue source:obj];
        };
        self.currentValue = value;
        self.changeItems = [NSMutableDictionary dictionaryWithCapacity:changeItems.count];
        for(id<ChangeItem> change in changeItems){
            [self appendChangeItem:change];
        }
    }

    return self;
}

-(void)setNewValue:(id)newValue fromOldValue:(id)oldValue source:(id)object{
    self.currentValue = newValue;
    NSMutableArray *objectAvailable = [NSMutableArray array];
    NSMutableArray *recursiveDefenses = [NSMutableArray array];

    for(NSObject<ChangeItem> *change in self.changeItems.allValues){
        static char functionKey;
        RecurseFense *recursiveDefense = [[RecurseFense alloc] initWithObject:change functionKey:&functionKey];
        if(recursiveDefense){
            [recursiveDefenses addObject:recursiveDefense];
            if ([change isEqual:object]){
                continue;
            }
            [objectAvailable addObject:change];
        }
    }

    for(NSObject<ChangeItem> *change in objectAvailable){
        [change valueChangedTo:newValue from:oldValue];
    }

    for(RecurseFense *defense in recursiveDefenses){
        [defense unDefense];
    }
}

-(NSString*)appendChangeItem:(id <ChangeItem>)changeItem {
    NSString *identifier = [[NSUUID UUID] UUIDString];
    [self appendChangeItem:changeItem identifier:identifier];
    return identifier;
}

-(void)appendChangeItem:(id <ChangeItem>)changeItem identifier:(NSString*)name{
    if(self.changeItems[name]){
        [self removeChangeItem:self.changeItems[name]];
    }
    [self.changeItems setObject:changeItem forKey:name];

    [changeItem valueChangedTo:self.currentValue from:[NSNull null]];
    [changeItem attachToChannel:self];
}

-(void)removeChangeItemByIdentifier:(NSString*)identifier {
    if(self.changeItems[identifier]){
        id<ChangeItem> change = self.changeItems[identifier];
        [change detach];
        [self.changeItems removeObjectForKey:identifier];
    }
}

-(void)removeChangeItem:(id <ChangeItem>)changeItem {
    NSString* __block identifier;
    [self.changeItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isEqual:changeItem]){
            identifier = key;
        }
    }];

    [self removeChangeItemByIdentifier:identifier];
}

-(void)dealloc {
    for(id<ChangeItem> change in self.changeItems.allValues){
        [change detach];
    }
}
@end


