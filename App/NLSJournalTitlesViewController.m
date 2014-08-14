//
//  NLSJournalTitlesViewController.m
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSJournalTitlesViewController.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"

@interface NLSJournalTitlesViewController ()

@end

@implementation NLSJournalTitlesViewController

@synthesize section = _section;
@synthesize letters = _letters;
@synthesize journal = _journal;
@synthesize journalId = _journalId;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.journal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is self.searchDisplayController.searchResultsTableView");
        return [self.sql getTitleCountWhereJournalEquals:self.journalId andTitleLike:self.searchBar.text];
    }else{
        return [self.sql getTitleCountWhereJournalEquals:self.journalId];
    }
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSLog(@"indexPath: %ld", (long)indexPath.row);
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];

    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is self.searchDisplayController.searchResultsTableView in cellForRowAtIndexPath: %ld", (long)indexPath.row);
        tm = [self.sql getTitleAndIdForRow:(NSUInteger)indexPath.row whereJournalEquals:self.journalId andTitleLike:self.searchBar.text];
    }else{
        tm = [self.sql getTitleAndIdForRow:(NSUInteger)indexPath.row whereJournalEquals:self.journalId];
    }
        
    cell.textLabel.text = tm.title;
    cell.rowId = tm.rowId;
    
    NSLog(@"cell.rowId: %lu, textLabel: %@", (unsigned long)cell.rowId, cell.textLabel.text);
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
