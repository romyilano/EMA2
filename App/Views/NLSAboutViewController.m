//
//  NLSAboutViewController.m
//  App
//
//  Created by Amir on 9/15/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "NLSAboutViewController.h"

#pragma GCC diagnostic ignored "-Wselector"

@interface NLSAboutViewController ()

@end

@implementation NLSAboutViewController

@synthesize pmcString = _pmcString;


- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    self.view = view;
    
    
    NLSDetailModel *dm = [[NLSDetailModel alloc] init];
    
    self.pmcString = @"PMC4076127";
    
    dm.abstract =
    
    @"Colleen's - The Emergency Medicine Abstract 2015.\n\n"

    "The Emergency Medicine Abstract is a collection of relevant literature from a broad spectrum of biomedical information.  The Abstract contains relevant Emergency Medicine literature from over 1400 of the world's medical and scientific journals.  Abstracts are sourced from the National Library of Medicine PubMed Database. Publication dates range from 1978 to 2006.\n\n"

    "Read more about EMA:\n"
    "http://www.ccme.org/EMA/ \n\n"
    
    "Colleen's EMA Edition contains over 100,000 abstracts from EMA which are stored in the App. You do not need a network connection to read or search them. (A network connection is required to view related citations).\n\n"
    
    "This edition covers 12,000 Medical Subject Headings, or \"MeSH\" descriptors.  The Descriptors can be used to narrow down search results or specific topics.  Boolean search controllers allow you to do a full text search of the database using inline \"AND, OR, NOT\" (case insensitive) operators.  Descriptors, years and titles are included in the basic search.\n\n"

    "Read more about evidence-based medicine:\n"
    "PMID: PMC4076127\n\n"
    
    "[Legal Terms and Information]\n\n"
    "Copyright 2014-2015 Colleen's Inc.\n\n"
    
    "Licensed under the Apache License, Version 2.0 (the \"License\"); "
    "you may not use this software except in compliance with the License. "
    "You may obtain a copy of the License at\n\n"
    
    "http://www.apache.org/licenses/LICENSE-2.0\n\n"
    
    "Unless required by applicable law or agreed to in writing, software "
    "distributed under the License is distributed on an \"AS IS\" BASIS, "
    "WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. "
    "See the License for the specific language governing permissions and "
    "limitations under the License."
    "";
    
    
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
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"About";
    }
    return self;
}

#pragma mark - Data Detectors

- (NSAttributedString *)makeAttributedAbstract:(NSString*)str
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(PMID: PMC[0-9]+)" options:kNilOptions error:nil];
    
    NSRange range = NSMakeRange(0, str.length);
    
    [mutableAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont fontWithName:@"Helvetica Neue" size:12]
                                    range:NSMakeRange(0, [mutableAttributedString length])];
    
    [regex enumerateMatchesInString:str options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSLinkAttributeName value:@"pmid://" range:subStringRange];
    }];
    
    return (NSAttributedString*)mutableAttributedString;
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
                 value:[UIColor colorWithHexString:emaGreen]
                 range:range];
    
    [link addAttribute:NSLinkAttributeName value:@"pmc://" range:range];
    
    return (NSAttributedString *)link;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"pmid"]) {
        //        NSString *username = [URL host];
        // do something with this username
        
        // ...
        NSString *pmid = @"http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4076127/?report=reader";
        
        
        NSURL *url = [NSURL URLWithString:pmid];
        NSLog(@"pmid: %@", url);
        [self pushWebViewWithURL:url];
        
        return NO;
    }
    
    if ([[URL scheme] isEqualToString:@"pmc"]) {
        
        NSString *pmc = @"http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4076127/?report=reader";
        
        NSURL *url = [NSURL URLWithString:pmc];
        NSLog(@"pmid: %@", url);
        [self pushWebViewWithURL:url];
        
        return NO;
    }
    
    return YES; // let the system open this URL
}



@end
