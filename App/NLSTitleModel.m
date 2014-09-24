//
//  NLSTitleModel.m
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSTitleModel.h"

@implementation NLSTitleModel

@synthesize rowId = _rowId;
@synthesize cellId = _cellId;
@synthesize title = _title;
@synthesize year = _year;
@synthesize journal_abv = _journal_abv;
@synthesize descriptors = _descriptors;
@synthesize attributed = _attributed;
@synthesize failed = _failed;
@synthesize data = _data;

- (id) init
{
    self.rowId = -1;
    self.cellId = -1;
    self.title = @"Title"; // do your own initialisation here
    self.year = @"Year";
    self.journal_abv = @"Journal Abv";
    self.descriptors = @[@{@"":@""}];
    self.data = nil;
    return self;
}

- (id)initWithCellId:(NSInteger)cellId{
    
    if (self = [super init]) {
        self.cellId = cellId;
    }
    return self;
}

- (BOOL)hasData {
    if(!self.data){
        return NO;
    }else{
        return YES;
    }    
}

- (BOOL)isAttributed {
    return _attributed;
}

- (BOOL)isFailed {
    return _failed;
}


/*
 
 - (NLSTableViewCell*)decorateCell:(NLSTableViewCell*)cell
 {
 //Attribute string for year
 
 NLSTitleModel *tm = cell.tm;
 NSMutableAttributedString *year;
 NSString *journalAndYear  = [NSString stringWithFormat:@"%@, %@ \n", tm.journal_abv, tm.year ];
 year = [[NSMutableAttributedString alloc] initWithString:journalAndYear];
 
 [year addAttribute:NSKernAttributeName
 value:[NSNumber numberWithFloat:0.5]
 range:NSMakeRange(0, [year length])];
 
 [year addAttribute:NSFontAttributeName
 value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
 range:NSMakeRange(0, [year length])];
 
 [year addAttribute:NSForegroundColorAttributeName
 value:[UIColor colorWithHexString:@"#777777"]
 range:NSMakeRange(0, [year length])];
 
 //Descriptor strings
 NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithAttributedString:year];
 
 NSMutableAttributedString *meshDescriptors = [[NSMutableAttributedString alloc] initWithString:@""];
 for(NSDictionary *dict in tm.descriptors){
 NSString *str = [[NSString alloc] initWithFormat:@"%@, ", [dict valueForKey:@"name"]];
 NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:str];
 [meshDescriptors appendAttributedString:aStr];
 }
 
 //trim last comma
 NSRange endComma;
 endComma.location = ([meshDescriptors length] - 2);
 endComma.length = 1;
 [meshDescriptors deleteCharactersInRange:endComma];
 
 [meshDescriptors addAttribute:NSFontAttributeName
 value:[UIFont fontWithName:@"AvenirNext-Medium" size:10]
 range:NSMakeRange(0, [meshDescriptors length])];
 
 [detailText appendAttributedString:meshDescriptors];
 
 cell.detailTextLabel.attributedText = detailText;
 cell.detailTextLabel.textColor = [UIColor colorWithHexString:emaGreen];
 
 //Attribute string for label
 NSMutableAttributedString *title;
 
 title = [[NSMutableAttributedString alloc] initWithString:tm.title];
 
 [title addAttribute:NSKernAttributeName
 value:[NSNumber numberWithFloat:0.5]
 range:NSMakeRange(0, [tm.title length])];
 
 [title addAttribute:NSFontAttributeName
 value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
 range:NSMakeRange(0, [tm.title length])];
 
 cell.textLabel.attributedText = title;
 
 
 //Set row id property of cell
 cell.rowId = tm.rowId;
 cell.tm = tm;
 
 return cell;
 }

 */

@end
