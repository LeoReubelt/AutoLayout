//
//  NSString+EH.h
//  CRMStar
//
//  Created by epau on 6/6/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EH)

- (CGFloat)heightForTextHavingWidth:(CGFloat)width font:(UIFont *)font;
- (CGFloat)heightForTextHavingWidth:(CGFloat)width font:(UIFont *)font maxLines:(CGFloat)maxLines;

@end
