//
//  NLSDetailViewController.m
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSDetailViewController.h"
#import "NLSDetailModel.h"
#import "EDColor.h"
#pragma GCC diagnostic ignored "-Wselector"


@interface NLSDetailViewController ()

@end

@implementation NLSDetailViewController

@synthesize abstractId = _abstractId;
@synthesize sql = _sql;
@synthesize button = _button;
@synthesize window = _window;
@synthesize pmidRange = _pmidRange;


- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    self.view = view;
    NSLog(@"abstractId: %ld", (unsigned long)self.abstractId);
    
    self.sql = [NLSSQLAPI sharedManager];
    
    
    NLSDetailModel *dm = [self.sql getAbstractWithId:self.abstractId];
    
    //NSLog(@"UIViewController loadView. Abstract: %@", dm.abstract);
    
    UITextView *tv = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tv.editable = NO;
    tv.dataDetectorTypes = UIDataDetectorTypeAll;
    tv.textAlignment = NSTextAlignmentLeft;
    tv.text = dm.abstract;
    tv.contentInset = UIEdgeInsetsMake(4,0,10,0);

    
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:emaGreen],
                                     NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    
    // assume that textView is a UITextView previously created (either by code or Interface Builder)
    tv.linkTextAttributes = linkAttributes; // customizes the appearance of links
    tv.attributedText = [self makeAttributedAbstract:dm.abstract];
    tv.delegate = self;
    
    [view addSubview:tv];
    
    
    //Add favorite button
    [self drawFavoriteButton];
    
    
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

-(void)drawFavoriteButton
{
    NLSButton *button;
    BOOL isFave = [self.sql checkForFavoriteId:self.abstractId];
    if(isFave){
        button = [NLSButton buttonWithNormalImageName:@"FavoritesHighlighted-50@2x.png" highlightedImageName:@"FavoritesHighlighted-50@2x.png"];
        [button addTarget:self action:@selector(removeFromFavorites:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        button = [NLSButton buttonWithNormalImageName:@"Favorites-50@2x.png" highlightedImageName:@"FavoritesHighlighted-50@2x.png"];
        [button addTarget:self action:@selector(insertIntoFavorites:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect = screen.bounds;
    NSLog(@"width: %f", screenRect.size.width);
    button.frame = CGRectMake(screenRect.size.width - 47.0f, 23.0f, 34.0f, 34.0f);
    
    
    self.button = button;

}

- (void)insertIntoFavorites:(UIButton*)button
{
    NSLog(@"Button  clicked.");
    [self.sql insertIntoFavorites:self.abstractId];
    UIImage *image = [UIImage imageNamed:@"FavoritesHighlighted-50@2x.png"];
    [button setImage:image forState:UIControlStateNormal];
    [button removeTarget:nil
                  action:NULL
        forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(removeFromFavorites:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeFromFavorites:(UIButton*)button
{
    NSLog(@"Button  clicked.");
    [self.sql deleteFromFavorites:self.abstractId];
    UIImage *image = [UIImage imageNamed:@"Favorites-50@2x.png"];
    [button setImage:image forState:UIControlStateNormal];
    [button removeTarget:nil
                  action:NULL
        forControlEvents:UIControlEventAllTouchEvents];
    [button addTarget:self action:@selector(insertIntoFavorites:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Data Detectors

- (NSAttributedString *)makeAttributedAbstract:(NSString*)str
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(PMID: [0-9]+)" options:kNilOptions error:nil];
    
    NSRange range = NSMakeRange(0, str.length);
    
    [mutableAttributedString addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
                 range:NSMakeRange(0, [mutableAttributedString length])];
    
    [regex enumerateMatchesInString:str options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSLinkAttributeName value:@"pmid://" range:subStringRange];
    }];
    
    NSAttributedString *pLink = [self createPubMedCentralLink];
    
    [mutableAttributedString appendAttributedString:pLink];

    return (NSAttributedString*)mutableAttributedString;
}

-(NSAttributedString *)createPubMedCentralLink
{
    NSString *str = [[NSString alloc] initWithFormat:@"\nPubMed Central Citations"];
    NSMutableAttributedString *link = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range = NSMakeRange(0, [link length]);
    [link addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
                 range:range];
    
    [link addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:@"#15829e"]
                 range:range];
    
    [link addAttribute:NSLinkAttributeName value:@"pmc://" range:range];
    
    return (NSAttributedString *)link;
}

- (NSRange)getRangeFrom:(NSString*)str ofPattern:(NSString*)pat
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pat options:0 error:&error];
    NSRange range = [regex rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
    return range;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"pmid"]) {
//        NSString *username = [URL host];
        // do something with this username

        // ...
        NSString *pmid = [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/pubmed/%@", [self.sql getPmidForId:self.abstractId]];


        NSURL *url = [NSURL URLWithString:pmid];
                NSLog(@"pmid: %@", url);
        [self pushWebViewWithURL:url];
        
        return NO;
    }
    
    if ([[URL scheme] isEqualToString:@"pmc"]) {

        NSString *pmc = [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/pmc/articles/pmid/%@/citedby/?tool=pubmed", [self.sql getPmidForId:self.abstractId]];
        
        NSURL *url = [NSURL URLWithString:pmc];
        NSLog(@"pmid: %@", url);
        [self pushWebViewWithURL:url];
        
        return NO;
    }
    
    return YES; // let the system open this URL
}

#pragma mark push web views
-(void)pushWebViewWithURL:(NSURL*)url
{
    UIViewController *webViewController = [[UIViewController alloc] init];
    webViewController.title = @"PubMed";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    webView.delegate = self;
    
    [webViewController.view addSubview: webView];
    [self.navigationController pushViewController: webViewController animated:YES];
}


@end
