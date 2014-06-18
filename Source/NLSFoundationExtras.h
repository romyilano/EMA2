//
//  NLSFoundationExtras.h
//
//  Created by Patrick Piemonte on 1/5/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

// assertion macros silent assertions in release builds, avoiding crashes

#ifdef NDEBUG
#define NLSAssert(assertion)
#define NLSAssertWithLog(assertion,log, ...)
#else
#define NLSAssert(assertion)                  NSCAssert1((unsigned long)(assertion) != 0, @"assertion: (%s)", #assertion)
#define NLSAssertWithLog(assertion,log, ...)  NSCAssert2((unsigned long)(assertion) != 0, @"assertion: (%s) '%@'", #assertion, ([NSString stringWithFormat: log, ## __VA_ARGS__]))
#endif

@interface NSBundle (NLSFoundationExtras)

+ (NSBundle *)appBundle;

@end

@interface NSRegularExpression (NLSFoundationExtras)

+ (NSRegularExpression *)hastagMentionRegularExpression;

@end
