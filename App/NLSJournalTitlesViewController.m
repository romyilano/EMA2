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

- (void)loadView
{
    
    NLSSQLAPI *sqlapi = [[NLSSQLAPI alloc]  init];
    self.sql = sqlapi;
    [self.sql initDatabase];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.view = tableView;
    self.title = self.journal;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    NSUInteger count = [self.sql getTitleCountWhereJournalEquals:self.journalId];
    NSLog(@"numberOfRowsInSection %ld for meshId: %ld is: %ld", section, self.journalId, count);
    
    return (NSInteger)count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSLog(@"indexPath: %ld", (long)indexPath.row);
    NLSTitleModel *tm = [self.sql getTitleAndIdForRow:(NSUInteger)indexPath.row whereJournalEquals:self.journalId];
    
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
