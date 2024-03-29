//
//  NLSFoundationExtras.m
//
//  Created by Patrick Piemonte on 1/5/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NLSFoundationExtras.h"

@implementation NSBundle (NLSFoundationExtras)

+ (NSBundle *)appBundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle mainBundle];
    });
    return bundle;
}

@end

@implementation NSRegularExpression (NLSFoundationExtras)

+ (NSRegularExpression *)hastagMentionRegularExpression
{
    static NSRegularExpression *regEx = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regEx = [NSRegularExpression regularExpressionWithPattern:@"\\B((@|#)([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)_-]+))|\\B(@|#)([\u4e00-\u9fa5]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return regEx;
}

@end
