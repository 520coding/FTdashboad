//
//  FTdashBoad.h
//  wifi
//
//  Created by 520coding on 2020/07/20.
//  Copyright © 2020 520coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBA(r, g, b, a)      [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define KAngleToradian(angle) (M_PI / 180.0 * (angle))

NS_ASSUME_NONNULL_BEGIN

@interface FTdashBoad : UIView<CAAnimationDelegate>

/** 最小值 */
@property (nonatomic, assign) CGFloat minValue;
/** 最大值 */
@property (nonatomic, assign) CGFloat maxValue;
/** 当前值 */
@property (nonatomic, assign) CGFloat currentValue;
/** 初始角 */
@property (nonatomic, assign) CGFloat startAngle;
/** 终止角 */
@property (nonatomic, assign) CGFloat endAngle;
/** 进度条线宽 */
@property (nonatomic, assign) CGFloat lineWidth;
/** 大刻度线宽 */
@property (nonatomic, assign) CGFloat scaleLineNormalWidth;
/** 小刻度线宽 */
@property (nonatomic, assign) CGFloat scaleLineBigWidth;
/** 每份分为多少小份 */
@property (nonatomic, assign) NSInteger divideOfUint;
/** 总共分为多少份 */
@property (nonatomic, assign) NSInteger countOfUnit;
/** 默认颜色 */
@property (nonatomic, strong) UIColor *normalColor;
/** 高亮颜色 */
@property (nonatomic, strong) UIColor *highlightColor;

/**
* 创建表盘
*/
-(void)createViewWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle divideOfUint:(NSInteger)divideOfUint countOfUnit:(NSInteger)countOfUnit;
/**
* 刷新表盘
*/
- (void)refreshDashboard:(CGFloat)currentValue;

@end

NS_ASSUME_NONNULL_END
