//
//  NSObject+Routes.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Routes)
@property(nonatomic,strong,getter=objSchema,setter=setObjSchema:) NSString *objSchema;
@property(nonatomic,strong,getter=schemaArgu,setter=setSchemaArgu:) NSDictionary *schemaArgu;
@end
