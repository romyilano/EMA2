//
//  NLSDetailViewController.m
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSDetailViewController.h"
#import "NLSSQLAPI.h"
#import "NLSDetailModel.h"

@interface NLSDetailViewController ()

@end

@implementation NLSDetailViewController

@synthesize abstractId = _abstractId;
@synthesize sql = _sql;

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    self.view = view;
    NSLog(@"abstractId: %ld", (unsigned long)self.abstractId);
    
    NLSSQLAPI *sqlapi = [NLSSQLAPI sharedManager];
    self.sql = sqlapi;
    
    
    NLSDetailModel *dm = [self.sql getAbstractWithId:self.abstractId];
    
    //NSLog(@"UIViewController loadView. Abstract: %@", dm.abstract);
    
    UITextView *tv = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tv.editable = NO;
    tv.font = [UIFont fontWithName: @"Courier" size: 12.0f];
    tv.dataDetectorTypes = UIDataDetectorTypeAll;
    tv.textAlignment = NSTextAlignmentLeft;
    tv.text = dm.abstract;
    
    [view addSubview:tv];
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Abstract";
    }
    return self;
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
