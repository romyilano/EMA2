//
//  NLSButton.h
//
//  Created by Patrick Piemonte on 2/23/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NLSButtonCompletionHandler)(BOOL selected);

// buttons

@interface NLSButton : UIButton
+ (id)button;
+ (id)genericButtonWithFrame:(CGRect)frame;
+ (id)buttonWithNormalImageName:(NSString *)normalImageName highlightedImageName:(NSString *)highlightedImageName;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated completionHandler:(NLSButtonCompletionHandler)completionHandler;
@end

@interface NLSExtendedHitAreaButton : NLSButton

@end

@interface NLSIconButton : NLSButton
+ (id)buttonWithImage:(UIImage *)image;
@end

// TODO: update to scale and fade bounce
@interface NLSGenericButton : NLSButton
+ (id)buttonWithFrame:(CGRect)frame;
- (void)setButtonBackgroundColor:(UIColor *)backgroundColor;
- (void)setButtonHighlightedBackgroundColor:(UIColor *)backgroundColor;
@end

// TODO: update to scale and fade bounce
@interface NLSSymbolButton : NLSButton
+ (id)buttonWithFrame:(CGRect)frame;
- (void)setButtonBackgroundColor:(UIColor *)backgroundColor;
- (void)setButtonHighlightedBackgroundColor:(UIColor *)backgroundColor;
@end

// bar button items

@interface NLSBarButtonItem : UIBarButtonItem
+ (NLSBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
@end
