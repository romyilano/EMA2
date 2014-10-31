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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:NO forType:1];    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    
    NSLog(@"init NLSJournalViewController");
    self.sql  = [NLSSQLAPI sharedManager];
    
    self.letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = [UIColor colorWithHexString:linkBlue];
    [tableView reloadData];
    
    self.view = tableView;
    self.navigationItem.title = journalsString;
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:YES forType:1];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"numberOfSectionsInTableView, %ld", (unsigned long)[self.letters count]);
    return (NSInteger)[self.letters count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return (NSInteger)[self.sql getCountFromJournalsWhereSectionLike:[self.letters objectAtIndex:(NSUInteger)section]];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return [self.letters objectAtIndex:(NSUInteger)section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.letters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSLog(@"sectionForSectionIndexTitle: %@ atIndex: %ld", title, (long)index);
    return (NSInteger)[self.letters indexOfObject:title];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myIdentifier = @"MyReuseIdentifier";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myIdentifier];
    }
    
    NSLog(@"indexPath.row: %ld, indexPath.section: %ld", (long)indexPath.row, (long)indexPath.section);
    NLSJournalModel *jm = [self.sql getJournalTitleForRow:(NSInteger)indexPath.row whereSectionLike:[self.letters objectAtIndex:(NSUInteger)indexPath.section]];
    
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
