//
//  NLSAutoSizeTextview.m
//  App
//
//  Created by Amir on 11/3/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "NLSAutoSizeTextview.h"

@implementation NLSAutoSizeTextview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"textViewDidChange: %@", NSStringFromSelector(_cmd));
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}

@end
