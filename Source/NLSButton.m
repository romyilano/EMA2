//
//  NLSButton.m
//
//  Created by Patrick Piemonte on 2/23/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NLSButton.h"
#import "NLSUIKitExtras.h"
#import "NLSNSStringExtras.h"

@implementation NLSButton

+ (id)button
{
    return nil;
}

+ (id)genericButtonWithFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.adjustsImageWhenDisabled = NO;
    button.adjustsImageWhenHighlighted = NO;
    return button;
}

+ (id)buttonWithNormalImageName:(NSString *)normalImageName highlightedImageName:(NSString *)highlightedImageName
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonImage = [UIImage imageNamed:normalImageName];
    [button setImage:buttonImage forState:UIControlStateNormal];
    
    UIImage *hightlightedImage = [UIImage imageNamed:highlightedImageName];
    [button setImage:hightlightedImage forState:UIControlStateHighlighted];

    CGSize size = buttonImage.size;
    CGRect buttonBounds = CGRectMake(0, 0, size.width, size.height);
    [button setFrame:buttonBounds];
    
    return button;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated completionHandler:(NLSButtonCompletionHandler)completionHandler
{
    self.selected = selected;
    if (completionHandler)
        completionHandler(selected);
}

@end

@implementation NLSExtendedHitAreaButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-35, -35, -35, -35);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end

@implementation NLSIconButton

+ (id)buttonWithImage:(UIImage *)image
{
    NLSIconButton *button = [NLSIconButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor        = [UIColor greenNLSColor];
    button.layer.cornerRadius     = 6.0f;
    
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(8, 10, 8, 10)];
    button.imageView.backgroundColor = [UIColor greenNLSColor];
    
    return button;
}

@end

@interface NLSGenericButton ()
{
    UIColor *_genericBackgroundColor;
    UIColor *_genericHighlightedBackgroundColor;
}

@end

@implementation NLSGenericButton

+ (id)buttonWithFrame:(CGRect)frame
{
    NLSGenericButton *button = [NLSGenericButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    button.backgroundColor        = [UIColor greenNLSColor];
    button.layer.cornerRadius     = 6.0f;
    [button setImage:nil forState:UIControlStateNormal];
    
    [button setTitle:@"" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont NLSFontSize:20.0f];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.backgroundColor = [UIColor clearColor];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(4.0f, 0.0f, 0.0f, 0.0f)];
    
    [button setButtonBackgroundColor:[UIColor greenNLSColor]];
    [button setButtonHighlightedBackgroundColor:[UIColor greenDarkNLSColor]];
    
    [button addTarget:button action:@selector(_handleButtonPress:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:button action:@selector(_handleButtonRelease:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:button action:@selector(_handleButtonRelease:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:button action:@selector(_handleButtonRelease:) forControlEvents:UIControlEventTouchCancel];
    
    return button;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled) {
        self.backgroundColor = _genericBackgroundColor;
        self.titleLabel.backgroundColor = _genericBackgroundColor;
        self.imageView.backgroundColor = _genericBackgroundColor;
    } else {
        self.backgroundColor = [UIColor neutralMediumColor];
        self.titleLabel.backgroundColor = [UIColor neutralMediumColor];
        self.imageView.backgroundColor = [UIColor neutralMediumColor];
    }
}

- (void)setButtonBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _genericBackgroundColor = backgroundColor;
}

- (void)setButtonHighlightedBackgroundColor:(UIColor *)backgroundColor
{
    _genericHighlightedBackgroundColor = backgroundColor;
}

- (void)_handleButtonPress:(UIButton *)button
{
    button.backgroundColor        = _genericHighlightedBackgroundColor;
    button.titleLabel.backgroundColor = [UIColor clearColor];
    button.imageView.backgroundColor = [UIColor clearColor];
}

- (void)_handleButtonRelease:(UIButton *)button
{
    button.backgroundColor        = _genericBackgroundColor;
    button.titleLabel.backgroundColor = _genericBackgroundColor;
    button.imageView.backgroundColor = _genericBackgroundColor;
}

@end

@interface NLSSymbolButton ()
{
    UIColor *_genericBackgroundColor;
    UIColor *_genericHighlightedBackgroundColor;
}

@end

@implementation NLSSymbolButton

+ (id)buttonWithFrame:(CGRect)frame
{
    NLSSymbolButton *button = [NLSSymbolButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    button.backgroundColor        = [UIColor whiteColor];
    button.layer.cornerRadius     = 6.0f;
    button.layer.borderColor      = [[UIColor greenNLSColor] CGColor];
    button.layer.borderWidth      = 2.0f;
    [button setImage:nil forState:UIControlStateNormal];
    
    [button setTitle:@"" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontSymbolSize:30.0f];
    [button setTitleColor:[UIColor neutralMediumColor] forState:UIControlStateNormal];
    button.titleLabel.backgroundColor = [UIColor clearColor];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(4.0f, 0.0f, 0.0f, 0.0f)];
    
    [button setButtonBackgroundColor:[UIColor greenNLSColor]];
    [button setButtonHighlightedBackgroundColor:[UIColor greenDarkNLSColor]];
    
    [button addTarget:button action:@selector(_handleButtonPress:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:button action:@selector(_handleButtonRelease:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:button action:@selector(_handleButtonRelease:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:button action:@selector(_handleButtonRelease:) forControlEvents:UIControlEventTouchCancel];
    
    return button;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled) {
        self.layer.borderColor = [_genericBackgroundColor CGColor];
    } else {
        self.layer.borderColor = [[UIColor neutralMediumColor] CGColor];
    }
}

- (void)setButtonBackgroundColor:(UIColor *)backgroundColor
{
    self.layer.borderColor = [backgroundColor CGColor];
    _genericBackgroundColor = backgroundColor;
}

- (void)setButtonHighlightedBackgroundColor:(UIColor *)backgroundColor
{
    _genericHighlightedBackgroundColor = backgroundColor;
}

- (void)_handleButtonPress:(UIButton *)button
{
//    button.backgroundColor        = _genericHighlightedBackgroundColor;
//    button.titleLabel.backgroundColor = [UIColor clearColor];
//    button.imageView.backgroundColor = [UIColor clearColor];
}

- (void)_handleButtonRelease:(UIButton *)button
{
//    button.backgroundColor        = _genericBackgroundColor;
//    button.titleLabel.backgroundColor = _genericBackgroundColor;
//    button.imageView.backgroundColor = _genericBackgroundColor;
}

@end

@implementation NLSBarButtonItem

+ (NLSBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
{
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    NLSExtendedHitAreaButton *button = [NLSExtendedHitAreaButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:buttonFrame];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    return [[NLSBarButtonItem alloc] initWithCustomView:button];
}

@end
