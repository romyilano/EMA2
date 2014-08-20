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


#pragma mark - SQL Overides

-(NSInteger)getTitleCount
{
    NSLog(@"getTitleCount");
    return (NSInteger)[self.sql getTitleCountWhereMeshEquals:self.meshId];
}

-(NSInteger)getTitleCountWhereTitleContains
{
        NSLog(@"getTitleCountWhereTitleContains");
    return (NSInteger)[self.sql getTitleCountWhereMeshEquals:self.meshId andTitleMatch:self.searchBar.text];
    
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)row WhereTitleMatch:str
{
        NSLog(@"getTitleAndIdForRow whereTitleMatch");
    return [self.sql getTitleAndIdForRow:(NSUInteger)row whereMeshEquals:self.meshId andTitleLike:str];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)row
{
        NSLog(@"getTitleAndIdForRow");
    return [self.sql getTitleAndIdForRow:(NSUInteger)row whereMeshEquals:self.meshId];
}


@end
