//
//  NLSUIKitExtras.m
//
//  Created by Patrick Piemonte on 2/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NLSUIKitExtras.h"
#import "NLSFoundationExtras.h"
#import "NLSNSStringExtras.h"

#import "EDColor.h"

@implementation UIColor (NLSUIKitExtras)

// base tones

+ (UIColor *)greenLightNLSColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"35F1B7"];
    });
    return color;
}

+ (UIColor *)greenNLSColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"2DE386"];
    });
    return color;
}

+ (UIColor *)greenDarkNLSColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"24b56b"];
    });
    return color;
}

+ (UIColor *)redNLSColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"FB2025"];
    });
    return color;
}

+ (UIColor *)pinkNLSColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"ff6d6d"];
    });
    return color;
}

+ (UIColor *)blueNLSColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"6c6ff3"];
    });
    return color;
}

+ (UIColor *)goldNLSColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"FFC11A"];
    });
    return color;
}

// neon tones

+ (UIColor *)neonPurpleColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"ac83ff"];
    });
    return color;
}

+ (UIColor *)neonPinkColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"ff7ae8"];
    });
    return color;
}

+ (UIColor *)neonGreenColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"4bff93"];
    });
    return color;
}

+ (UIColor *)neonMellowYellowColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"fff82d"];
    });
    return color;
}

+ (UIColor *)neonOrangeColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"ff7713"];
    });
    return color;
}

+ (UIColor *)neonLightBlueColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"00e0e0"];
    });
    return color;
}

// neutral tones

+ (UIColor *)neutralLightestColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"EBEBEB"];
    });
    return color;
}

+ (UIColor *)neutralLighterColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"E6E6E6"];
    });
    return color;
}

+ (UIColor *)neutralLightColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"DBDBDB"];
    });
    return color;
}

+ (UIColor *)neutralMediumColor
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"CCCCCC"];
    });
    return color;
}

+ (UIColor *)grayColor05
{
    static dispatch_once_t onceToken;
    static UIColor *color;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHexString:@"818486"];
    });
    return color;
}

@end

@implementation UIFont (NLSUIKitExtras)

+ (UIFont *)NLSFontSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

//+ (UIFont *)fontSymbolSize:(CGFloat)size
//{
//    return [UIFont fontWithName:NLSFontSymbol size:size];
//}

@end

@implementation UIImage (NLSUIKitExtras)

+ (UIImage*) fillImgOfSize:(CGSize)imgSize withColor:(UIColor*)imgColor{
    
    /* begin the graphic context */
    UIGraphicsBeginImageContext(imgSize);
    
    /* set the color */
    [imgColor set];
    
    /* fill the rect */
    UIRectFill(CGRectMake(0, 0, imgSize.width, imgSize.height));
    
    /* get the image, end the context */
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    /* return the value */
    return scaledImage;
}

@end

@implementation UINavigationController (NLSUIKitExtras)

+ (UINavigationController*) initStyled{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:nil toolbarClass:nil];
    UINavigationBar *navigationBar = navigationController.navigationBar;
    
    [navigationBar setBackgroundImage:[UIImage fillImgOfSize:CGSizeMake(1,1) withColor:[UIColor colorWithHexString:searchGreen]]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    
    navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithHexString:@"#FFFFFF"], NSForegroundColorAttributeName,
                                         [UIFont fontWithName:@"Helvetica Neue" size:20.0], NSFontAttributeName, nil];
    
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navigationBar.tintColor = [UIColor  whiteColor];
    navigationBar.barTintColor = [UIColor colorWithHexString:searchGreen];
    
    [[navigationController navigationBar] setTranslucent:YES];
    
    return navigationController;
}
@end