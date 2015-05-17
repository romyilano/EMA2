//
//  NLSFeedViewController.h
//  App
//
//  Created by Amir on 5/11/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSDetailViewController.h"
#import "EDColor.h"
#import "MWFeedParser.h"
#import <UIKit/UIKit.h>

@interface NLSFeedViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, MWFeedParserDelegate> {

    // Parsing
    MWFeedParser *feedParser;
    NSMutableArray *parsedItems;

    // Displaying
    NSArray *feedArray;
    NSDateFormatter *formatter;
    
}

@property (nonatomic, strong) NSArray *feedArray;
@property (strong, nonatomic) UITableView *tableView;


@end
