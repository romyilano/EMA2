//
//  NLSDescriptorTitlesViewController.m
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSDescriptorTitlesViewController.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"

@interface NLSDescriptorTitlesViewController ()

@end

@implementation NLSDescriptorTitlesViewController

@synthesize section = _section;
@synthesize letters = _letters;
@synthesize meshId = _meshId;
@synthesize descriptor = _descriptor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.descriptor;
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
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is self.searchDisplayController.searchResultsTableView");
        return [self.sql getTitleCountWhereMeshEquals:self.meshId andTitleMatch:self.searchBar.text];
    }else{
        return [self.sql getTitleCountWhereMeshEquals:self.meshId];
    }
    
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"Cell";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    NSLog(@"indexPath: %ld", (long)indexPath.row);
    
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is self.searchDisplayController.searchResultsTableView in cellForRowAtIndexPath: %ld", (long)indexPath.row);
        tm = [self.sql getTitleAndIdForRow:(NSUInteger)indexPath.row whereMeshEquals:self.meshId andTitleLike:self.searchBar.text];
    }else{
        tm = [self.sql getTitleAndIdForRow:(NSUInteger)indexPath.row whereMeshEquals:self.meshId];
    }
    
    
    
    cell.textLabel.text = tm.title;
    cell.rowId = tm.rowId;
    
    NSLog(@"cell.rowId: %lu, textLabel: %@", (unsigned long)cell.rowId, cell.textLabel.text);
    return cell;
}

@end
