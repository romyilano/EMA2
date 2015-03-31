//
//  NLSTitleLabel.m
//  App
//
//  Created by Amir on 3/30/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSTitleLabel.h"

@implementation NLSTitleLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 10, 0, 10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
