//
//  NLSNSStringExtras.m
//
//  Created by Patrick Piemonte on 2/12/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NLSNSStringExtras.h"
#import "NLSUIKitExtras.h"

@implementation NSString (NLSExtras)

- (BOOL)isAlphaNumeric
{
    NSString *nonAlphaCharsInName = [[self urlify] stringByTrimmingCharactersInSet:[NSCharacterSet alphanumericCharacterSet]];
    return [nonAlphaCharsInName length] == 0;
}

- (BOOL)isEmail
{
    static NSString * const emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    return [emailPredicate evaluateWithObject:self];
}

// Collapses whitespace and drops string to lowercase.
- (NSString *)urlify
{
    return [[self lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString *)URLencode
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                    NULL,
                                    (CFStringRef)self,
                                    NULL,
                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                    kCFStringEncodingUTF8 ));
}

@end

#pragma mark - NSAttributedString

@implementation NSAttributedString (NLSExtras)

+ (NSDictionary *)navigationBarTitleAttributeDict
{
    static dispatch_once_t onceToken;
    static NSDictionary *dict;
    dispatch_once(&onceToken, ^{
        dict = @{NSFontAttributeName : [UIFont NLSFontSize:20.0f],
                 NSForegroundColorAttributeName : [UIColor whiteColor],
                 NSShadowAttributeName : [NSAttributedString navigationBarTitleShadowAttributeDict]};

    });
    return dict;
}

+ (NSShadow *)navigationBarTitleShadowAttributeDict
{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, 0);
    shadow.shadowColor = [UIColor whiteColor];
    return shadow;
}

@end
