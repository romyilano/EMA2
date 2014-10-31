//
//  NLSTableView.m
//  App
//
//  Created by Amir on 10/31/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "NLSTableView.h"

@implementation NLSTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.tableHeaderView.frame;
    rect.origin.y = 0;
    self.tableHeaderView.frame = rect;
    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    [window addSubview:self.tableHeaderView];

}

@end
