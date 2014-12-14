//
//  NLSTableViewCell.m
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSTableViewCell.h"

@implementation NLSTableViewCell

@synthesize rowId = _rowId;
@synthesize name = _name;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];
        //This allows for multiple lines
        self.textLabel.numberOfLines = 3;
        self.detailTextLabel.numberOfLines = 3;
        self.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
