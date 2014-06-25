//
//  NLSNSStringExtras.h
//
//  Created by Patrick Piemonte on 2/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NLSExtras)

- (BOOL)isAlphaNumeric;
- (BOOL)isEmail;

- (NSString *)urlify;
- (NSString *)URLencode;

@end

@interface NSAttributedString (NLSExtras)

+ (NSDictionary *)navigationBarTitleAttributeDict;
+ (NSShadow *)navigationBarTitleShadowAttributeDict;

@end
