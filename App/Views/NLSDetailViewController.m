//
//  NLSDetailViewController.m
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSDetailViewController.h"
#pragma GCC diagnostic ignored "-Wselector"


@interface NLSDetailViewController ()

@end

@implementation NLSDetailViewController

@synthesize abstractId = _abstractId;
@synthesize sql = _sql;
@synthesize button = _button;
@synthesize shareButton = _shareButton;
@synthesize window = _window;
@synthesize pmidRange = _pmidRange;
@synthesize tv = _tv;
@synthesize linkAttributes = _linkAttributes;
@synthesize meshView = _meshView;

- (void)loadView
{

    //DB
    self.sql = [NLSSQLAPI sharedManager];
    NLSDetailModel *dm = [self.sql getAbstractWithId:self.abstractId];
    
    //Attributes
    self.linkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:emaGreen],
                                     NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    
    
    UITextView *tv = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    tv.editable = NO;
    tv.scrollEnabled = YES;
    tv.dataDetectorTypes = UIDataDetectorTypeAll;
    tv.textAlignment = NSTextAlignmentLeft;
    tv.text = dm.abstract;
    tv.contentInset = UIEdgeInsetsMake(textInset,0,44,0);
    tv.linkTextAttributes = self.linkAttributes; // customizes the appearance of links
    tv.attributedText = [self makeAttributedAbstract:dm.abstract];
    tv.delegate = self;
    self.tv = tv;
    
    //Create Buttons
    [self drawFavoriteButton];
    [tv addSubview:[self makeShareButton]];
    [tv addSubview:[self makeMeshList]];
    
    //Create window reference
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.window = window;
    self.view = tv;

    //Adjust MeshView and TextView inset
    CGRect meshFrame = self.meshView.frame;
    meshFrame.size.height = [self meshViewContentHeight];
    self.meshView.frame = meshFrame;

    tv.contentInset = UIEdgeInsetsMake(textInset,0,(20 + meshFrame.size.height),0);
    
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
    [self.view addSubview:self.button];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.view addSubview:self.button];
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

-(NLSButton *)makeShareButton
{
    NLSButton *button;

    button = [NLSButton buttonWithNormalImageName:@"Share-50@2x.png" highlightedImageName:@"Share-50@2x.png"];
    [button addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    
    button.frame = CGRectMake((textInset + 5.0f), ([self textViewContentHeight] + 10.0f), 34.0f, 34.0f);
    
    self.shareButton = button;
    return button;
}

-(void)share:(UIButton*)button
{
    NSLog(@"Share clicked.");
    NSString *str = [NSString stringWithFormat:pubMedUrl, [self.sql getPmidForId:self.abstractId]];
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"url %@",url);
    [self shareText:self.tv.text andImage:nil andUrl:url withSubject:shareSubject];
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url withSubject:(NSString *)subj
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [activityController setValue:subj forKey:@"subject"];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(CGFloat)textViewContentHeight
{
    NSLog(@"tv frame: %f", [self.tv sizeThatFits:CGSizeMake(self.tv.frame.size.width, FLT_MAX)].height);
    return [self.tv sizeThatFits:CGSizeMake(self.tv.frame.size.width, FLT_MAX)].height;
}

-(CGFloat)meshViewContentHeight
{
    NSLog(@"mesh frame: %f", [self.meshView sizeThatFits:CGSizeMake(self.meshView.frame.size.width, FLT_MAX)].height);
    return [self.meshView sizeThatFits:CGSizeMake(self.meshView.frame.size.width, FLT_MAX)].height;
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

-(UITextView *)makeMeshList
{
    UITextView *meshView = [[UITextView alloc] initWithFrame:CGRectMake((textInset + 40.0f), ([self textViewContentHeight]), 270.0f, 0.0f)];
    
    NSArray *meshes = [[NSArray alloc] initWithArray:[self.sql getMeshDescriptorsForId:self.abstractId]];
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    for(NSDictionary *dict in meshes)
    {
        NSString *tmp = [[NSString alloc] initWithFormat:@"%@, ", [dict valueForKey:@"name"]];
        NSString *meshLink = [[NSString alloc] initWithFormat:@"mesh://%@", [dict valueForKey:@"id"]];
        NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:[tmp lowercaseString]];
        
        [aStr addAttribute:NSLinkAttributeName value:meshLink range:NSMakeRange(0, aStr.length)];
        [finalString appendAttributedString:aStr];
    }

    //trim last comma
    NSRange endComma;
    endComma.location = ([finalString length] - 2);
    endComma.length = 1;
    [finalString deleteCharactersInRange:endComma];

    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    [pStyle setLineSpacing:6];
    
    [finalString addAttribute:NSParagraphStyleAttributeName
                      value:pStyle
                      range:NSMakeRange(0, [finalString length])];
    
    //Prop out meshView
    meshView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    meshView.attributedText = finalString;
    meshView.editable = NO;
    meshView.scrollEnabled = NO;
    meshView.linkTextAttributes = self.linkAttributes;
    meshView.delegate = self;
    self.meshView = meshView;
    
    return meshView;
}

#pragma mark - Data Detectors

- (NSAttributedString *)makeAttributedAbstract:(NSString*)str
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    [mutableAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont fontWithName:@"Helvetica Neue" size:12]
                                    range:NSMakeRange(0, [mutableAttributedString length])];
    

    NSMutableArray *attributes = [[NSMutableArray alloc] initWithArray:[self getAttributes]];
    [attributes addObjectsFromArray:[self additionalAttributes]];
    
    for(NSDictionary *dict in attributes){
        if(dict){
            NSLog(@"dict regex:, %@",[dict objectForKey:@"regex"]);
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[dict objectForKey:@"regex"] options:kNilOptions error:nil];
            NSRange range = NSMakeRange(0, mutableAttributedString.length);
            
            [regex enumerateMatchesInString:str options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {

                [[dict objectForKey:@"attributes"] enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stops) {
                    NSLog(@"%@ = %@", key, object);
                    NSRange subStringRange = [result rangeAtIndex:1];
                    [mutableAttributedString addAttribute:key value:object range:subStringRange];
                }];
                
            }];
        }
    }
    
    NSAttributedString *pLink = [self createPubMedCentralLink];
    
    [mutableAttributedString appendAttributedString:pLink];

    return (NSAttributedString*)mutableAttributedString;
}

-(NSArray*)getAttributes
{
    NSDictionary *pmidAttr = @{
                               @"regex"    : @"(PMID: [0-9]+)",
                               @"attributes" : @{NSLinkAttributeName:@"pmid://"}
                               
                               };
    
    NSDictionary *firstLine = @{
                                @"regex"    : @"(^.*)\\n\\n",
                                @"attributes" : @{
                                        NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:14],
                                        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                                        }
                                };
    
    NSArray *attributes = [NSArray arrayWithObjects:pmidAttr,firstLine,nil];
    return attributes;
}

-(NSArray*)additionalAttributes
{
    return @[];
}

-(NSAttributedString *)createPubMedCentralLink
{
    NSString *str = [[NSString alloc] initWithFormat:@"\nPubMed Central Citations"];
    NSMutableAttributedString *link = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range = NSMakeRange(0, [link length]);
    [link addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:@"Helvetica Neue" size:12]
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
        NSString *pmid = [NSString stringWithFormat:pubMedUrl, [self.sql getPmidForId:self.abstractId]];


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
    
    if ([[URL scheme] isEqualToString:@"mesh"]) {
        
        NSString *meshURL = [[NSString alloc] initWithFormat:@"%@",URL];
        NSLog(@"meshPath: %@", meshURL);
        NSInteger meshId = [[meshURL stringByReplacingOccurrencesOfString:@"mesh://"withString:@""] integerValue];
            
        NLSDescriptorTitlesViewController *dtvc = [[NLSDescriptorTitlesViewController alloc] init];
        dtvc.letters = nil;
        dtvc.meshId = meshId;
        dtvc.descriptor = [self.sql getMeshForId:meshId];
        
        //Push new view
        [self.navigationController pushViewController:dtvc animated:TRUE];
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
