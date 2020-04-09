//
//  NSArray+Safety.m
//  StarryNight
//
//  Created by zingwin on 2017/2/21.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import "NSArray+Safety.h"

@implementation NSArray (Safety)
-(id)safe_objectAtIndex:(NSInteger)index{
    NSInteger count = [self count];
    if (count > index) {
        return [self objectAtIndex:index];
    }
    return nil;
}
-(id)safe_objectForKey:(NSString*)key{
    return self;
}
@end

@implementation NSMutableArray (Safety)
-(void)safe_addObject:(id)anObject{
    if (anObject) {
        if([anObject isKindOfClass:[NSString class]]){
            NSString *str = (NSString*)anObject;
            if (str.length <= 0) {
                return;
            }
        }
        [self addObject:anObject];
    }
}

-(void)safe_addObjectsFromArray:(id)anObjects{
    if (anObjects) {
        [self addObjectsFromArray:anObjects];
    }
}

-(NSArray *)safe_subarrayWithRange:(NSRange)range{
    NSUInteger location = range.location;
    NSUInteger length = range.length;
    if(location > self.count){
        return nil;
    }else if (location + length > self.count) {
        //超过了边界,就获取从loction开始所有的item
        if ((location + length) > self.count) {
            if(self.count - location > 0){
                length = self.count - location;
                return [self safe_subarrayWithRange:NSMakeRange(location, length)];
            }
        }
        return nil;
    }else {
        return [self subarrayWithRange:range];
    }
}

@end
