//
//  NLSDetailModel.h
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSDetailModel : NSObject

@property (readwrite, assign) NSInteger rowId;
@property (strong, atomic) NSString *abstract;

@end
