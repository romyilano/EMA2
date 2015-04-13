//
//  NLSDetailViewController.h
//  App
//
//  Created by Amir Djavaherian on 7/25/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "NLSSQLAPI.h"
#import "NLSButton.h"
#import "NLSDescriptorTitlesViewController.h"
#import "NLSDetailModel.h"
#import "NLSDetailQuery.h"
#import "EDColor.h"
#include "EMAConstants.h"


@interface NLSDetailViewController : UIViewController<UITextViewDelegate, UIWebViewDelegate, NLSDetailQueryDelegate>

@property (readwrite, assign) NSInteger abstractId;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NLSButton *button;
@property (strong, nonatomic) NLSButton *shareButton;
@property (strong, nonatomic) UIWindow *window;
@property (readwrite, assign) NSRange pmidRange;
@property (strong, nonatomic) UITextView *tv;
@property (strong, nonatomic) UITextView *meshView;
@property (strong, nonatomic) NSDictionary *linkAttributes;
@property (strong, nonatomic) NLSPendingOperations *pendingOperations;
@property (strong, nonatomic) NLSDetailModel *dm;

- (NLSDetailViewController*)initWithId:(NSInteger)rowId;
- (void)removeFromFavorites:(UIButton*)button;
- (void)insertIntoFavorites:(UIButton*)button;
- (void)pushWebViewWithURL:(NSURL*)url;


@end
