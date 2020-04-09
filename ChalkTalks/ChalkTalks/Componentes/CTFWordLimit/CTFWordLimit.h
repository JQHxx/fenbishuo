//
//  CTFWordLimit.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTFWordLimit : NSObject

/*＝＝＝＝＝＝＝＝＝＝＝＝＝＝UITextField＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝*/

/**
 在系统/第三方输入源下，限制字数，提示还可以输入多少字数

 @param originTextField 需要实现字数限制的UITextField
 @param warningLabel    提示还可以输入多少字数的UILabel
 @param maxNum          限制的最大字数
 */
+ (void)computeWordCountWithTextField:(UITextField *)originTextField warningLabel:(UILabel *)warningLabel maxNumber:(NSUInteger)maxNum;


/**
 在系统/第三方输入源下，限制字数

 @param originTextField 需要实现字数限制的UITextField
 @param maxNum          限制的最大字数
 */
+ (void)computeWordCountWithTextField:(UITextField *)originTextField maxNumber:(NSUInteger)maxNum;


/*＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝UITextView＝＝＝＝＝＝＝＝＝＝*/

/**
 在系统/第三方输入源下，限制字数，提示还可以输入多少字数
 
 @param originTextView 需要实现字数限制的UITextField
 @param warningLabel   提示还可以输入多少字数的UILabel
 @param maxNum         限制的最大字数
 */
+ (void)computeWordCountWithTextView:(UITextView *)originTextView warningLabel:(UILabel *)warningLabel maxNumber:(NSUInteger)maxNum;


/**
 在系统/第三方输入源下，限制字数
 
 @param originTextView 需要实现字数限制的UITextField
 @param maxNum         限制的最大字数
 */
+ (void)computeWordCountWithTextView:(UITextView *)originTextView maxNumber:(NSUInteger)maxNum;

@end

NS_ASSUME_NONNULL_END
