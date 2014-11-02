//
//  NLSJournalViewController.m
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSJournalViewController.h"

@interface NLSJournalViewController ()

@end

@implementation NLSJournalViewController

@synthesize sql = _sql;
@synthesize letters = _letters;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.defactoTitle = journalsString;
    self.navigationItem.title = self.defactoTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section
    if (self.isSearching){
        
        if(self.searchReset){
            self.searchReset = NO;
            NSLog(@"Search reset prev row count: %ld", (long)self.prevSearchRowCount);
            return self.prevSearchRowCount;
        }
        NSInteger count = (long)[self.sql getCountFromJournalsWhereSectionLike:self.searchBar.text];
        return count;
    }else{
        
        NSInteger count = (long)[self.sql getCountFromJournalsWhereSectionLike:[self.letters objectAtIndex:(NSUInteger)section]];
        return count;
    }
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myIdentifier = @"MyReuseIdentifier";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myIdentifier];
    }
    
    NSLog(@"indexPath.row: %ld, indexPath.section: %ld", (long)indexPath.row, (long)indexPath.section);
    NLSJournalModel *jm = nil;
    
    if(self.isSearching){
        jm = [self.sql getJournalTitleForRow:(NSInteger)indexPath.row whereSectionLike:self.searchBar.text];
    }else{
        jm = [self.sql getJournalTitleForRow:(NSInteger)indexPath.row whereSectionLike:[self.letters objectAtIndex:(NSUInteger)indexPath.section]];
    }
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:jm.journal_title attributes:nil];
    NSString *issn = [[NSString alloc] initWithFormat:@"ISSN: %@", jm.issn];
    NSMutableAttributedString *issnAttr = [[NSMutableAttributedString alloc] initWithString:issn attributes:nil];
    
    NSRange range = NSMakeRange(0, [issnAttr length]);

    [issnAttr addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:@"AvenirNext-Medium" size:10]
                 range:range];
    
    [issnAttr addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:emaGreen]
                 range:range];
    
    
    cell.name = jm.journal_title;
    cell.rowId = jm.rowId;
    cell.textLabel.attributedText = title;
    cell.detailTextLabel.attributedText = issnAttr;
    
    NSLog(@"cell.rowId: %lu, textLabel: %@, issn: %@", (unsigned long)cell.rowId, cell.textLabel.text, issnAttr);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NLSTableViewCell *cell = (NLSTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"cell id: %lu, name: %@", (unsigned long)cell.rowId, cell.name);
    
    NLSJournalTitlesViewController *jtvc = [[NLSJournalTitlesViewController alloc] init];

    jtvc.letters = self.letters;
    jtvc.journalId = cell.rowId;
    jtvc.journal = cell.name;

    [self.navigationController pushViewController:jtvc animated:TRUE];
}


@end
