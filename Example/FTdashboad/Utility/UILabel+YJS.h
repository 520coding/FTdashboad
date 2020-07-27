//
//  UILabel+YJS.h
//  wifi
//
//  Created by 520coding on 2020/07/20.
//  Copyright © 2020 520coding. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (YJS)

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont*)font;

+ (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
