//
//  NSArray+Safety.h
//  StarryNight
//
//  Created by zingwin on 2017/2/21.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safety)
-(id)safe_objectAtIndex:(NSInteger)index;
-(id)safe_objectForKey:(NSString*)key;
@end

@interface NSMutableArray (Safety)

/// 数组安全添加数据
/// @param anObject anObject description
-(void)safe_addObject:(id)anObject;
-(void)safe_addObjectsFromArray:(id)anObjects;

-(NSArray *)safe_subarrayWithRange:(NSRange)range;
@end
