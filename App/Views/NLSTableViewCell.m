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
@synthesize title = _title;

@synthesize titleLabel = _titleLabel;
@synthesize journalLabel = _journalLabel;
@synthesize descriptorLabel = _descriptorLabel;

#define TITLE_TAG 1
#define JOURNAL_TAG 2
#define DESCRIPTOR_TAG 3

- (NLSPendingOperations *)pendingOperations
{
    if (!_pendingOperations) {
        _pendingOperations = [[NLSPendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"init cell");
        //Setup SQL shared instance
        self.sql = [NLSSQLAPI sharedManager];
        
        // Init with spinner
//        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        self.accessoryView = activityIndicatorView;
        
        self.rowId = indexPath.row + 1;
        
        NSUInteger width = [[UIScreen mainScreen] applicationFrame].size.width;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 48.0f)];
        self.titleLabel.tag = TITLE_TAG;
        self.titleLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 3;
        [self.contentView addSubview:self.titleLabel];
        
        
        self.journalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 48.0, width, 22.0)];
        self.journalLabel.tag = JOURNAL_TAG;
        self.journalLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];
        self.journalLabel.textColor = [UIColor darkGrayColor];
        self.journalLabel.backgroundColor = [UIColor whiteColor];
        self.journalLabel.text = @"JDATA";
        [self.contentView addSubview:self.journalLabel];
        
        self.descriptorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, width, 40.0)];
        self.descriptorLabel.tag = DESCRIPTOR_TAG;
        self.descriptorLabel.font = [UIFont fontWithName: @"Helvetica Neue" size: 12];
        self.descriptorLabel.textColor = [UIColor darkGrayColor];
        self.descriptorLabel.backgroundColor = [UIColor whiteColor];
        self.descriptorLabel.text = @"DDATA";
        self.descriptorLabel.numberOfLines = 3;
        [self.contentView addSubview:self.descriptorLabel];
        

        
        // Init with empty string
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
        self.journalLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
        self.descriptorLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
        
        
        //begin data queries
        
        [self startQuery:@selector(getTitleAndIdForRow:)];
        [self startJournalQuery:@selector(getJournalAbvForId:)];
        [self startDescriptorQuery:@selector(getEmptyTitleModelWithDescriptorsForId:)];
        
    }
    return self;
}

-(void)reloadView
{
    [((UIActivityIndicatorView *)self.accessoryView) stopAnimating];
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:200
                     animations:^{
                         [self setNeedsLayout]; // Called on parent view
                     }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(NSSet *)propertyNames {
    NSMutableSet *propNames = [NSMutableSet set];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[[NSString alloc] initWithUTF8String:property_getName(property)] autorelease];
        [propNames addObject:propertyName];
    }
    free(properties);
    
    return propNames;
}

-(void)updateCellWithTitleModel:(NLSTitleModel*)tm
{

    NSLog(@"%@", NSStringFromSelector(_cmd));
    
//    NSArray *properties = [tm allPropertyNames];
//    self.tm.title = [tm valueForKey:title];
    
//    if(tm.title != nil){
//        NSLog(@"tm has title %@", tm.title);
////        [self.propertyNames setValue:tm.title forKey:@"title"];
////        [self.tm setValue:tm.title forKey:@"title"];
////        NSLog(@"self.tm.title: %@", self.tm.title);
//    }
//    if(tm.journal_abv != nil){
//        NSLog(@"tm has journalabv");
//        self.tm.journal_abv = tm.journal_abv;
//    }
//    if([tm.descriptors count] > 0){
//        NSLog(@"tm has descriptors");
//        self.tm.descriptors = tm.descriptors;
//    }
    
    
    if (tm.title != nil) {
        
        //Set row id property of cell
        self.rowId = self.tm.rowId;
        
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
        NSLog(@"still need title for %d", self.rowId);
        [((UIActivityIndicatorView *)self.accessoryView) startAnimating];
        self.titleLabel.text = @"Loading...";
        [self startQuery:@selector(getTitleAndIdForRow:)];
        
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
        NSLog(@"still need descriptors for %d", self.rowId);
        [self startQuery:@selector(getEmptyTitleModelWithDescriptorsForId:)];
    }
    
    
}

-(void)updateCellWithJournal:(NLSTitleModel *)tm
{
    
    if(tm.journal_abv !=  nil){
        //Attribute string for year
        NSString *journalAndYear  = [NSString stringWithFormat:@"journal: %@, year: %@", tm.journal_abv, tm.year ];
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
        
    } else {
        //get journal and year
        NSLog(@"still need journal and year for %d", self.rowId);
        [self startJournalQuery:@selector(getJournalAbvForId:)];
    }
}

#pragma mark Cache Operations

- (void)startQuery:(SEL)selector
{
    NLSTMQuery *tmQuery = nil;
    NSInvocation *invocation = nil;
//    NSUInteger *row = indexPath.row;
    
//    SEL selector = @selector(getEmptyTitleModelWithDescriptorsForId:);
//
//    if(self.isSearching){
//        
//        //get args row and match
//        NSString *match = self.searchText;
//        
//        // create a signature from the selector
//        SEL selector = @selector(getTitleAndIdForRowOkapi:whereTitleMatch:);
//        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
//        invocation = [NSInvocation invocationWithMethodSignature:sig];
//        
//        //setup invocation and args
//        [invocation setTarget:self.sql];
//        [invocation setSelector:selector];
//        [invocation setArgument:&row atIndex:2];
//        [invocation setArgument:&match atIndex:3];
//        [invocation retainArguments];
//        
//    }else{
    
        // create a signature from the selector
        // check to see what fields are missing from tm
        // if title, get title, if mesh get mesh
        
        //getMeshDescriptorsForId:tm.rowId
        //SEL selector = @selector(getTitleAndIdForRow:);

        
        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:sig];
    
        NSUInteger row = self.rowId;
        //setup invocation
        [invocation setTarget:self.sql];
        [invocation setSelector:selector];
        [invocation setArgument:&row atIndex:2];
        [invocation retainArguments];
        
//    }

    tmQuery = [[NLSTMQuery alloc] initWithInvocation:invocation andDelegate:self];
    
    [self.pendingOperations.queryQueue addOperation:tmQuery];
    
    
}

- (void)startDescriptorQuery:(SEL)selector
{
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
    
    //    }
    
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
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&row atIndex:2];
    [invocation retainArguments];
    
    //    }
    
    journalQuery = [[NLSJournalQuery alloc] initWithInvocation:invocation andDelegate:self];
    
    [self.pendingOperations.queryQueue addOperation:journalQuery];
    
    
}

- (void)sqlQueryDidFinish:(NLSTMQuery *)query
{
    
    // get indexPath
    NSLog(@"--------table view cell: %@", NSStringFromSelector(_cmd));
    
    NSLog(@"%@, %ld", NSStringFromSelector(_cmd), (long)query.result);
    
    [self updateCellWithTitleModel:query.titleModel];
    
    
}

-(void)sqlQueryDidFinishForMeshArray:(NLSDescriptorArrayQuery *)query
{
    // get indexPath
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self updateCellWithDescriptors:query.titleModel];
}

-(void)journalQueryDidFinish:(NLSJournalQuery *)query
{
    // get indexPath
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self updateCellWithJournal:query.titleModel];
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
