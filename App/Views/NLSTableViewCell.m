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
@synthesize tm = _tm;
@synthesize isSearching = _isSearching;
@synthesize pendingOperations = _pendingOperations;
@synthesize sql = _sql;
@synthesize searchText = _searchText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //Setup SQL shared instance
        self.sql = [NLSSQLAPI sharedManager];
        
        // Init with spinner
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.accessoryView = activityIndicatorView;
        
        // Initialization code
        self.textLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];

        //This allows for multiple lines
        self.textLabel.numberOfLines = 3;
        self.detailTextLabel.numberOfLines = 3;
        
        // Init with empty string
        self.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
        self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)updateCellWithTitleModel:(NLSTitleModel*)tm atIndexPath:(NSIndexPath *)indexPath
{

    //This should merge rather than replace
    self.tm = tm;
    self.rowId = tm.rowId;
    
    NSLog(@"self.tm.hasData:%d", self.tm.hasData);
    // Check for data
    if (self.tm.hasData) {
        
        [((UIActivityIndicatorView *)self.accessoryView) stopAnimating];
        
        //Attribute string for year
        NSString *journalAndYear  = [NSString stringWithFormat:@"%@, %@ \n", self.tm.journal_abv, self.tm.year ];
        NSMutableAttributedString *journalLine = [[NSMutableAttributedString alloc] initWithString:journalAndYear];
        
        [journalLine addAttribute:NSKernAttributeName
                            value:[NSNumber numberWithFloat:0.5]
                            range:NSMakeRange(0, [journalLine length])];
        
        [journalLine addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"Helvetica Neue" size:12]
                            range:NSMakeRange(0, [journalLine length])];
        
        [journalLine addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithHexString:@"#777777"]
                            range:NSMakeRange(0, [journalLine length])];
        
        //Descriptor strings
//        NSMutableAttributedString *meshDescriptors = [[NSMutableAttributedString alloc] initWithString:@" "];
//        for(NSDictionary *dict in self.tm.descriptors){
//            NSString *str = [[NSString alloc] initWithFormat:@"%@, ", [dict valueForKey:@"name"]];
//            NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:str];
//            [meshDescriptors appendAttributedString:aStr];
//        }
//        
//        //Trim last comma
//        if([meshDescriptors length] >= 1){
//            NSRange endComma;
//            endComma.location = ([meshDescriptors length] - 2);
//            endComma.length = 1;
//            [meshDescriptors deleteCharactersInRange:endComma];
//        }
        
//        [meshDescriptors addAttribute:NSFontAttributeName
//                                value:[UIFont fontWithName:@"Helvetica Neue" size:10]
//                                range:NSMakeRange(0, [meshDescriptors length])];
//        [meshDescriptors addAttribute:NSForegroundColorAttributeName
//                                value:[UIColor colorWithHexString:emaGreen]
//                                range:NSMakeRange(0, [meshDescriptors length])];
//        
//        //Create Detail Text and append journal line and descriptors
//        NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithAttributedString:journalLine];
//        [detailText appendAttributedString:meshDescriptors];
        
        //Attribute string for label
        NSMutableAttributedString *title;
        
        title = [[NSMutableAttributedString alloc] initWithString:self.tm.title];
        
        [title addAttribute:NSKernAttributeName
                      value:[NSNumber numberWithFloat:0.5]
                      range:NSMakeRange(0, [self.tm.title length])];
        
        [title addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"Helvetica Neue" size:12]
                      range:NSMakeRange(0, [self.tm.title length])];
        
//        self.detailTextLabel.attributedText = detailText;
        self.textLabel.attributedText = title;
        
        //Set row id property of cell
        self.rowId = self.tm.rowId;
        
    } else if (self.tm.isFailed) {
        
        NSLog(@"tm is failed");
        [((UIActivityIndicatorView *)self.accessoryView) stopAnimating];
        self.textLabel.text = @"Failed to load";
        
    } else {
        
        [((UIActivityIndicatorView *)self.accessoryView) startAnimating];
        self.textLabel.text = @"Loading...";
        [self startQueryWithIndexPath:indexPath];
        
    }

}

#pragma mark Cache Operations

- (void)startQueryWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *queriesInProgress = self.pendingOperations.queriesInProgress;
    NLSTMQuery *tmQuery = nil;
    NSInvocation *invocation = nil;
    NSUInteger *row = indexPath.row;
    
    if(self.isSearching){
        
        //get args row and match
        NSString *match = self.searchText;
        
        // create a singature from the selector
        SEL selector = @selector(getTitleAndIdForRowOkapi:whereTitleMatch:);
        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:sig];
        
        //setup invocation and args
        [invocation setTarget:self.sql];
        [invocation setSelector:selector];
        [invocation setArgument:&row atIndex:2];
        [invocation setArgument:&match atIndex:3];
        [invocation retainArguments];
        
    }else{
        
        // create a signature from the selector
        // check to see what fields are missing from tm
        // if title, get title, if mesh get mesh
        
        //getMeshDescriptorsForId:tm.rowId
        //SEL selector = @selector(getTitleAndIdForRow:);
        SEL selector = @selector(getEmptyTitleModelWithDescriptorsForId:);
        
        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:sig];
        
        //setup invocation
        [invocation setTarget:self.sql];
        [invocation setSelector:selector];
        [invocation setArgument:&row atIndex:2];
        [invocation retainArguments];
        
    }

    tmQuery = [[NLSTMQuery alloc] initWithInvocation:invocation atIndexPath:indexPath andDelegate:self];
    
    [queriesInProgress setObject:tmQuery forKey:indexPath];
    [self.pendingOperations.queryQueue addOperation:tmQuery];
    
    
}


- (void)sqlQueryDidFinish:(NLSTMQuery *)query
{
    
    // get indexPath
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    //NSLog(@"%@, %ld", NSStringFromSelector(_cmd), (long)query.result);
    [self updateCellForTitleModel:query.titleModel atIndexPath:query.indexPathInTableView];
    
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
//    [self.pendingOperations.queriesInProgress removeObjectForKey:indexPath];
    
    
}


#pragma mark - Cancelling, suspending, resuming queues / operations

- (void)suspendAllOperations
{
    [self.pendingOperations.queryQueue setSuspended:YES];
}

- (void)resumeAllOperations
{
    [self.pendingOperations.queryQueue setSuspended:NO];
}

- (void)cancelAllOperations
{
    [self.pendingOperations.queryQueue cancelAllOperations];
}

@end
