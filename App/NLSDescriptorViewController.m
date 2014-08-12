//
//  NLSDescriptorViewController.m
//  App
//
//  Created by Amir on 8/6/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSDescriptorViewController.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"
#import "NLSTitleViewController.h"
#import "NLSDetailViewController.h"
#import "NLSDescriptorTitlesViewController.h"

@interface NLSDescriptorViewController ()

@end

@implementation NLSDescriptorViewController

@synthesize sql = _sql;
@synthesize letters = _letters;

- (void)loadView
{
    
    NSLog(@"init NLSDescriptorViewController");
    NLSSQLAPI *sqlapi = [NLSSQLAPI sharedManager];
    self.sql = sqlapi;
    
    self.letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z #" componentsSeparatedByString:@" "];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.view = tableView;
    self.title = @"MeSH Descriptors";
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
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
    NSLog(@"numberOfSectionsInTableView, %ld", [self.letters count]);
    return (NSInteger)[self.letters count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    NSString *letter = [NSString stringWithFormat:@"%@%%", [self.letters objectAtIndex:(NSUInteger)section]];
    NSInteger count = (long)[self.sql getCountFromTable:@"mesh_descriptor" whereCol:@"name" like:letter];
    NSLog(@"Descriptors, numberOfRowsInSection, %ld for section: %ld", section, count);
    
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
    NSLog(@"sectionForSectionIndexTitle: %@ atIndex: %ld", title, index);
    return (NSInteger)[self.letters indexOfObject:title];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myIdentifier = @"MyReuseIdentifier";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier];
    }
    
    NSLog(@"indexPath.row: %ld, indexPath.section: %ld", indexPath.row, indexPath.section);
    NLSDescriptorModel *dm = [self.sql getDescriptorForRow:(NSUInteger)indexPath.row whereSectionLike:[self.letters objectAtIndex:(NSUInteger)indexPath.section]];
    
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
    
    NSLog(@"cell id: %lu, name: %@", cell.rowId, cell.name);
    
    NLSDescriptorTitlesViewController *dtvc = [[NLSDescriptorTitlesViewController alloc] init];

    dtvc.letters = self.letters;
    dtvc.meshId = cell.rowId;
    dtvc.descriptor = cell.name;
    
    //Push new view
    [self.navigationController pushViewController:dtvc animated:TRUE];
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
