#import "Kiwi.h"
#import "RecurseFense.h"
#import "ChangeChannel.h"

SPEC_BEGIN(RecurseFenseSpec)

    describe(@"RecurseFense", ^{
        context(@"init", ^{
            it(@"should prevent recurse call", ^{
                int __block count = 0;
                NSObject *fenseObject = [[NSObject alloc]init];

                __block void (^block1)() = ^(){
                    static char key;
                    RecurseFense *fense = [[RecurseFense alloc] initWithObject:fenseObject functionKey:&key];
                    if(fense){
                        NSLog(@"called");
                        count++;
                        block1();
                    }
                };

                block1();
                [[theValue(count) should] equal:theValue(1)];

                block1();
                [[theValue(count) should] equal:theValue(2)];
            });
        });
    });

SPEC_END

SPEC_BEGIN(ChangeChannelSpec)
    describe(@"ChangeChannelBasicUsage", ^{
        context(@"View frame change", ^{
            it(@"should be able to handle basic usage", ^{
                UIView *view1 = [[UIView alloc]init];
                ObjectChangeItem *view1Change = [[ObjectChangeItem alloc] initWithObject:view1 keyPath:@"frame"];
                UIView *view2 = [[UIView alloc] init];
                ChangeChannel *changeChannel = [[ChangeChannel alloc] initWithChangeItems:@[
                    view1Change,
                    [[ObjectChangeItem alloc] initWithObject:view2 keyPath:@"frame"],
                ] value:[NSValue valueWithCGRect:view1.frame]];

                view1.frame = CGRectMake(1, 1, 10000, 10000);
                [[theValue(view2.frame.origin.x) should] equal:theValue(1)];

                view2.frame = CGRectMake(2, 2, 3, 3);
                [[theValue(view1.frame.origin.x) should] equal:theValue(2)];

                UIView *view3 = [[UIView alloc]init];
                [changeChannel appendChangeItem:[[ObjectChangeItem alloc] initWithObject:view3 keyPath:@"frame"]];

                view2.frame = CGRectMake(2, 2, 3, 3);
                [[theValue(view3.frame.origin.x) should] equal:theValue(2)];

                [changeChannel removeChangeItem:view1Change];
                view2.frame = CGRectMake(3,3,0,0);
                [[theValue(view1.frame.origin.x) should] equal:theValue(2)];

                [changeChannel appendChangeItem:view1Change];
                [[theValue(view1.frame.origin.x) should] equal:theValue(3)];

                BlockChangeItem *blockChange = [[BlockChangeItem alloc]initWithBlock:^(id newValue, id oldValue){
                    NSLog(@"New Value: %@, Old value: %@", newValue, oldValue);
                }];
                [changeChannel appendChangeItem:blockChange];
                view1.frame = CGRectMake(0,0,0,0);
                view2.frame = CGRectMake(2,1,1000,900);
                view3.frame = CGRectMake(3,5,1000,900);

                UIView *view4 = [[UIView alloc]init];
                ObjectChangeItem *view4Change = [[ObjectChangeItem alloc] initWithObject:view4 keyPath:@"frame"];
                view4Change.converter = [[ValueConverter alloc] initWithC2OBlock:^id(id value){
                    if([[NSNull null] isEqual:value]){
                        return value;
                    }
                    CGRect rect = [value CGRectValue];
                    CGRect resultRect = CGRectMake(rect.origin.x * 2, rect.origin.y * 2, rect.size.width * 2, rect.size.height * 2);
                    return [NSValue valueWithCGRect:resultRect];
                } o2cBlock:^id(id value){
                     if([[NSNull null] isEqual:value]){
                        return value;
                    }
                    CGRect rect = [value CGRectValue];
                    CGRect resultRect = CGRectMake(rect.origin.x / 2, rect.origin.y / 2, rect.size.width / 2, rect.size.height / 2);
                    return [NSValue valueWithCGRect:resultRect];
                }];

                [changeChannel appendChangeItem:view4Change];
                view3.frame = CGRectMake(3,5,1000,900);
                [[theValue(view4.frame.origin.x) should] equal:theValue(6)];
                [[theValue(view4.frame.size.width) should] equal:theValue(2000)];

                view4.frame = CGRectMake(4, 4, 4, 4);
                [[theValue(view3.frame.origin.x) should] equal:theValue(2)];
                [[theValue(view3.frame.size.width) should] equal:theValue(2)];
            });
        });
    });
SPEC_END
