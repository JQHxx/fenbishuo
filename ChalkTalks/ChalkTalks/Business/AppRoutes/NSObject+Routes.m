//
//  NSObject+Routes.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "NSObject+Routes.h"
#import <objc/runtime.h>


@implementation NSObject (Routes)
-(NSString*)objSchema{
    return objc_getAssociatedObject(self, @selector(objSchema));
}

-(void)setObjSchema:(NSString *)schema{
    objc_setAssociatedObject(self, @selector(objSchema), schema, OBJC_ASSOCIATION_RETAIN);
}

-(NSDictionary*)schemaArgu
{
    return objc_getAssociatedObject(self, @selector(schemaArgu));
}
-(void)setSchemaArgu:(NSDictionary *)argu
{
    objc_setAssociatedObject(self, @selector(schemaArgu), argu, OBJC_ASSOCIATION_RETAIN);
}
@end
