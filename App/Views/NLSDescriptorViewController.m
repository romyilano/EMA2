//
//  NLSDescriptorViewController.m
//  App
//
//  Created by Amir on 8/6/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSDescriptorViewController.h"

@interface NLSDescriptorViewController ()

@end

@implementation NLSDescriptorViewController

@synthesize sql = _sql;
@synthesize letters = _letters;

- (void)loadView
{
    
    NSLog(@"init NLSDescriptorViewController");
    self.sql = [NLSSQLAPI sharedManager];
    
    self.letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = [UIColor colorWithHexString:linkBlue];
    [tableView reloadData];
    
    self.view = tableView;
    self.title = @"Descriptors";
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:YES forType:1];
    
}


- (void)viewDidLoad
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:NO forType:1];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSInteger count = (long)[self.sql getCountFromDescriptorsWhereSectionLike:[self.letters objectAtIndex:(NSUInteger)section]];
    NSLog(@"Descriptors, numberOfRowsInSection, %ld for section: %ld", (long)section, (long)count);
    
    return count;
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
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier];
    }
    
    NSLog(@"indexPath.row: %ld, indexPath.section: %ld", (long)indexPath.row, (long)indexPath.section);
    NLSDescriptorModel *dm = [self.sql getDescriptorForRow:(NSInteger)indexPath.row whereSectionLike:[self.letters objectAtIndex:(NSUInteger)indexPath.section]];
    
    cell.name = dm.name;
    cell.rowId = dm.rowId;
    cell.textLabel.text = dm.name;
    
    NSLog(@"cell.rowId: %lu, textLabel: %@", (unsigned long)cell.rowId, cell.textLabel.text);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NLSTableViewCell *cell = (NLSTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"cell id: %lu, name: %@", (unsigned long)cell.rowId, cell.name);
    
    NLSDescriptorTitlesViewController *dtvc = [[NLSDescriptorTitlesViewController alloc] init];

    dtvc.letters = self.letters;
    dtvc.meshId = cell.rowId;
    dtvc.descriptor = cell.name;
    
    //Push new view
    [self.navigationController pushViewController:dtvc animated:TRUE];
}


@end
