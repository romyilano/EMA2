//
//  NLSDetailViewController.m
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSDetailViewController.h"
#import "NLSDetailModel.h"


@interface NLSDetailViewController ()

@end

@implementation NLSDetailViewController

@synthesize abstractId = _abstractId;
@synthesize sql = _sql;
@synthesize button = _button;
@synthesize window = _window;

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
    
    //Add favorite button
    NLSButton *button;
    BOOL isFave = [self.sql checkForFavoriteId:self.abstractId];
    if(isFave){
        button = [NLSButton buttonWithNormalImageName:@"FavoritesHighlighted-50@2x.png" highlightedImageName:@"FavoritesHighlighted-50@2x.png"];
    }else{
        button = [NLSButton buttonWithNormalImageName:@"Favorites-50@2x.png" highlightedImageName:@"FavoritesHighlighted-50@2x.png"];
        [button addTarget:self action:@selector(insertIntoFavorites:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect = screen.bounds;
    NSLog(@"width: %f", screenRect.size.width);
    button.frame = CGRectMake(screenRect.size.width - 47.0, 23.0, 34.0, 34.0);

    
    self.button = button;
    
    //Create window reference
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.window = window;
    
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
    [self.window addSubview:self.button];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.window addSubview:self.button];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.parentViewController == nil) {
        NSLog(@"viewDidDisappear doesn't have parent so it's been popped");
        //release stuff here
    } else {
//        NSLog(@"PersonViewController view just hidden");
    }

    [self.button removeFromSuperview];
}

- (void)insertIntoFavorites:(UIButton*)button
{
    NSLog(@"Button  clicked.");
    [self.sql insertIntoFavorites:self.abstractId];
    UIImage *image = [UIImage imageNamed:@"FavoritesHighlighted-50@2x.png"];
    [self.button setImage:image forState:UIControlStateNormal];
    [self.button removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
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
