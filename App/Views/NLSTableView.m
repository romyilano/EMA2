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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = @"Hello there!";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row pressed!!");
}


@end
