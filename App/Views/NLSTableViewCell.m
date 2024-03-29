//
//  NLSTableViewCell.m
//  App
//
//  Created by Amir Djavaherian on 7/25/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSTableViewCell.h"
#import "NLSTitleLabel.h"
#import "NLSJournalLabel.h"

#define TITLE_TAG 1
#define JOURNAL_TAG 2
#define DESCRIPTOR_TAG 3

@implementation NLSTableViewCell

@synthesize rowId = _rowId;
@synthesize name = _name;
@synthesize tm = _tm;
@synthesize isSearching = _isSearching;
@synthesize pendingOperations = _pendingOperations;
@synthesize sql = _sql;
@synthesize searchText = _searchText;
@synthesize title = _title;
@synthesize titleLabel = _titleLabel;
@synthesize journalLabel = _journalLabel;
@synthesize descriptorLabel = _descriptorLabel;
@synthesize tableView = _tableView;


- (NLSPendingOperations *)pendingOperations
{
    if (!_pendingOperations) {
        _pendingOperations = [[NLSPendingOperations alloc] init];
    }
    return _pendingOperations;
}

#pragma mark - Init
#

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifierDefault:(NSString *)reuseIdentifier
{
    //Setup SQL shared instance
    self.sql = [NLSSQLAPI sharedManager];
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self initLabels];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andId:(NSInteger)emaId
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    //Setup SQL shared instance
    self.sql = [NLSSQLAPI sharedManager];
    
    if (self) {
        NSLog(@"init cell %ld", (long)emaId);
        
        self.rowId = emaId;
        
        [self initLabels];
        
        //begin data queries
        [self startQueryWithId:emaId];
        [self startJournalQuery:@selector(getJournalAbvForId:)];
        [self startDescriptorQuery:@selector(getEmptyTitleModelWithDescriptorsForId:)];

    }
    return self;
}

- (void)initLabels
{
    // Init with spinner
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.accessoryView = activityIndicatorView;
    
    NSUInteger width = [[UIScreen mainScreen] applicationFrame].size.width;
    
    self.titleLabel = [[NLSTitleLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 48.0f)];
    self.titleLabel.tag = TITLE_TAG;
    self.titleLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 3;
    [self.contentView addSubview:self.titleLabel];
    
    self.journalLabel = [[NLSJournalLabel alloc] initWithFrame:CGRectMake(0.0, 48.0, width, 22.0)];
    self.journalLabel.tag = JOURNAL_TAG;
    self.journalLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];
    self.journalLabel.textColor = [UIColor darkGrayColor];
    self.journalLabel.backgroundColor = [UIColor whiteColor];
    self.journalLabel.text = @"";
    self.journalLabel.numberOfLines = 1;
    [self.contentView addSubview:self.journalLabel];
    
    self.descriptorLabel = [[NLSTitleLabel alloc] initWithFrame:CGRectMake(0.0, 70.0, width, 40.0)];
    self.descriptorLabel.tag = DESCRIPTOR_TAG;
    self.descriptorLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];
    self.descriptorLabel.textColor = [UIColor darkGrayColor];
    self.descriptorLabel.backgroundColor = [UIColor whiteColor];
    self.descriptorLabel.text = @"";
    self.descriptorLabel.numberOfLines = 3;
    [self.contentView addSubview:self.descriptorLabel];
    
    // Init with empty string
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
    self.journalLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
    self.descriptorLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
    
}

-(void)addAnimations
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.15;
    [self.titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    [self.journalLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    [self.descriptorLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
}

-(void)reloadView
{
    [((UIActivityIndicatorView *)self.accessoryView) stopAnimating];
    [self addAnimations];
//    [self layoutIfNeeded];
//    [self setNeedsLayout];
//    
//    [UIView animateWithDuration:200
//                     animations:^{
//                         [self setNeedsLayout]; // Called on parent view
//                     }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Update cell labels
#

-(void)dbg
{
    NSLog(@"");
}

-(void)updateCellWithId:(NSInteger)emaId
{
    NSLog(@"%@ %ld", NSStringFromSelector(_cmd), (long)emaId);
    
    [((UIActivityIndicatorView *)self.accessoryView) startAnimating];
    NSAttributedString *loadingString = [[NSAttributedString alloc] initWithString:@"Loading..." attributes:nil];
    NSAttributedString *blankString = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
    self.titleLabel.attributedText = loadingString;
    self.journalLabel.attributedText = blankString;
    self.descriptorLabel.attributedText = blankString;
    self.rowId = emaId;
    [self cancelAllOperations];
    [self startQueryWithId:emaId];
    [self startJournalQuery:@selector(getJournalAbvForId:)];
    [self startDescriptorQuery:@selector(getEmptyTitleModelWithDescriptorsForId:)];
}

-(void)updateCellWithTitleModel:(NLSTitleModel*)tm
{

    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if (tm.title != nil) {
        
        //Attribute string for label
        NSMutableAttributedString *title;
        
        title = [[NSMutableAttributedString alloc] initWithString:tm.title];
        
        [title addAttribute:NSKernAttributeName
                      value:[NSNumber numberWithFloat:0.5]
                      range:NSMakeRange(0, [tm.title length])];
        
        [title addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"Helvetica Neue" size:12]
                      range:NSMakeRange(0, [tm.title length])];
        
        self.titleLabel.attributedText = title;
        
        [self reloadView];
        
    } else if (tm.isFailed) {
        
        NSLog(@"tm is failed");
        [((UIActivityIndicatorView *)self.accessoryView) stopAnimating];
        self.titleLabel.text = @"Failed to load";
        
    } else {
        
        [((UIActivityIndicatorView *)self.accessoryView) startAnimating];
        self.titleLabel.text = @"Loading...";
        
    }

}

-(void)updateCellWithDescriptors:(NLSTitleModel *)tm
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [tm.descriptors objectAtIndex:0]);
    
    //Descriptor strings
    if ([tm.descriptors count] > 0){
        
        NSMutableAttributedString *meshDescriptors = [[NSMutableAttributedString alloc] initWithString:@" "];
        for(NSDictionary *dict in tm.descriptors){
            NSString *str = [[NSString alloc] initWithFormat:@"%@, ", [dict valueForKey:@"name"]];
            NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:str];
            [meshDescriptors appendAttributedString:aStr];
        }
        
        //Trim last comma
        if([meshDescriptors length] >= 1){
            NSRange endComma;
            endComma.location = ([meshDescriptors length] - 2);
            endComma.length = 1;
            [meshDescriptors deleteCharactersInRange:endComma];
        }
        
        [meshDescriptors addAttribute:NSFontAttributeName
                                value:[UIFont fontWithName:@"Helvetica Neue" size:10]
                                range:NSMakeRange(0, [meshDescriptors length])];
        [meshDescriptors addAttribute:NSForegroundColorAttributeName
                                value:[UIColor colorWithHexString:emaGreen]
                                range:NSMakeRange(0, [meshDescriptors length])];
        
        //Create Detail Text and append journal line and descriptors
        NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithString:@""];
        [detailText appendAttributedString:meshDescriptors];
        
        self.descriptorLabel.attributedText = detailText;
        NSLog(@"detail text: %@", detailText);
        [self reloadView];
        
    } else {
        //get descriptors
        [self startDescriptorQuery:@selector(getEmptyTitleModelWithDescriptorsForId:)];
    }
    
    
}

-(void)updateCellWithJournal:(NLSTitleModel *)tm
{
    
    if(tm.journal_abv !=  nil){
        //Attribute string for year
        NSString *journalAndYear  = [NSString stringWithFormat:@"%@, %@", tm.journal_abv, tm.year];
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
        
        self.journalLabel.attributedText = journalLine;
        [self reloadView];
        
    } else {
        //get journal and year
        [self startJournalQuery:@selector(getJournalAbvForId:)];
    }
}

#pragma mark - Start Queries
#

- (void)startQueryWithId:(NSInteger)emaId
{
    
    NSLog(@"%@ %ld", NSStringFromSelector(_cmd), (long)emaId);
    
    NLSTMQuery *tmQuery = nil;
    NSInvocation *invocation = nil;

    //get args row and match
    NSInteger row = emaId;
    
    // create a signature from the selector
    SEL selector = @selector(getTitleAndIdForRow:);
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:sig];

    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&row atIndex:2];
    [invocation retainArguments];

    
    tmQuery = [[NLSTMQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:tmQuery];
}

- (void)startDescriptorQuery:(SEL)selector
{
    
    NSLog(@"%@ %ld", NSStringFromSelector(_cmd), (long)self.rowId);
    NLSDescriptorArrayQuery *daQuery = nil;
    NSInvocation *invocation = nil;
    
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    NSUInteger row = self.rowId;
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&row atIndex:2];
    [invocation retainArguments];
    
    daQuery = [[NLSDescriptorArrayQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:daQuery];
    
}

- (void)startJournalQuery:(SEL)selector
{
    NLSJournalQuery *journalQuery = nil;
    NSInvocation *invocation = nil;
    
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    NSUInteger row = self.rowId;
    
//    NSLog(@"start journal query: %d", row);
    
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&row atIndex:2];
    [invocation retainArguments];
    
    journalQuery = [[NLSJournalQuery alloc] initWithInvocation:invocation andDelegate:self];
    
    [self.pendingOperations.queryQueue addOperation:journalQuery];
    
}

#pragma mark - Return From Queries
#

- (void)sqlQueryDidFinish:(NLSTitleModel *)tm
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), tm.title);
    [self updateCellWithTitleModel:tm];
}

-(void)sqlQueryDidFinishForMeshArray:(NLSTitleModel *)tm
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self updateCellWithDescriptors:tm];
}

-(void)journalQueryDidFinish:(NLSTitleModel *)tm
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self updateCellWithJournal:tm];
}


#pragma mark - Cancelling, suspending, resuming queues / operations
#

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
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.pendingOperations.queryQueue cancelAllOperations];
}

@end
