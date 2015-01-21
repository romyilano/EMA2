//
//  NLSSettingsViewController.h
//  App
//
//  Created by Amir on 1/12/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"

@interface NLSSettingsViewController : UIViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet NMRangeSlider *standardSlider;
@property (strong, nonatomic) IBOutlet UILabel *lowerLabel;
@property (strong, nonatomic) IBOutlet UILabel *upperLabel;
@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;

@end
