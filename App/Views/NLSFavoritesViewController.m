//
//  NLSFavoritesViewController.m
//  App
//
//  Created by Amir on 8/11/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSFavoritesViewController.h"

@interface NLSFavoritesViewController ()

@end

@implementation NLSFavoritesViewController

@synthesize sql = _sql;
@synthesize tableView = _tableView;
@synthesize button = _button;
@synthesize window = _window;

#pragma mark - view lifecycle

- (void)loadView
{
    
    NSLog(@"init NLSTitleModel");
    self.sql = [NLSSQLAPI sharedManager];
    
    NSLog(@"UIViewController loadView");
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    self.tableView = tableView;
    self.view = tableView;
    self.navigationItem.title = favoritesString;
    
    //Add a remove all Favorites Button
//    UIButton *button;
//    NSUInteger hasFaves = [self.sql getCountFromFavorites];
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect = screen.bounds;
//    NSLog(@"width: %f", screenRect.size.width);
//    CGRect frame = CGRectMake(screenRect.size.width - 60.0, 123.0, 34.0, 65.0);
//    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//
//    
    
//    if(hasFaves > 0){
//        [button addTarget:self action:@selector(removeAllFavorites:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(removeAllFavorites:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Remove All" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    button.frame = CGRectMake(screenRect.size.width - 110.0f, 23.0f, 100.0f, 40.0f);
    self.button = button;
    
    //Create window reference
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.window = window;
    
}


- (void)viewDidLoad
{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    [self.window addSubview:self.button];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeAllFavorites:(UIButton*)button
{
    NSLog(@"remove all favorites");
    [self.sql deleteFavorites];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:true];
    if (self.parentViewController == nil) {
        NSLog(@"viewDidDisappear doesn't have parent so it's been popped");
        //release stuff here
    } else {
        //        NSLog(@"PersonViewController view just hidden");
    }
    
    [self.button removeFromSuperview];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"numberOfSectionsInTableView, %d", 1);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return (NSInteger)[self.sql getCountFromFavorites];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    
    return @"All Favorites";
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"Cell";
    
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    NSLog(@"indexPath: %ld", (long)indexPath.row);
    NLSTitleModel *tm = [self.sql getFavoriteForRow:indexPath.row];
    
    cell.textLabel.text = tm.title;
    cell.rowId = tm.rowId;
    
    NSLog(@"cell.rowId: %lu, textLabel: %@", (unsigned long)cell.rowId, cell.textLabel.text);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NLSTableViewCell *cell = (NLSTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
//    NSString *string = [[NSString alloc] init];
//    string = cell.textLabel.text;
    NSInteger rowId = cell.rowId;
//    NSLog(@"id: %lu, title: %@", (unsigned long)rowId, string);
    
    //Push new view
    NLSDetailViewController *dvc = [[NLSDetailViewController alloc] init]; 
    dvc.abstractId = rowId;
    [self.navigationController pushViewController:dvc animated:TRUE];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    [self.tableView reloadData];
    [self.window addSubview:self.button];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     // Delete the row from the data source
     NLSTableViewCell *cell = (NLSTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
     [self.sql deleteFromFavorites:cell.rowId];
     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
 }


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
