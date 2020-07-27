//
//  FTdashBoad.m
//  wifi
//
//  Created by 520coding on 2020/07/20.
//  Copyright © 2020 520coding. All rights reserved.
//

#import "FTdashBoad.h"
#import "UILabel+YJS.h"

@interface FTdashBoad ()
@property (nonatomic, assign) CGFloat arcAngle;
@property (nonatomic, assign) CGFloat arcRadius;
@property (nonatomic, assign) CGFloat scaleRadius;
@property (nonatomic, assign) CGFloat scaleValueRadius;
@property (nonatomic, assign) CGFloat lastAngle;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *insideProgressLayer;
@property (nonatomic, strong) CAGradientLayer *colorGradientLayer;

@property (nonatomic, strong) NSMutableArray *layerArray;
@property (nonatomic, strong) NSMutableArray *textArray;
@property (nonatomic, strong) UIImageView *innerCursorImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *touchView;

@property (nonatomic, strong) UIColor *scaleValueColor;

@end

@implementation FTdashBoad

- (NSMutableArray *)layerArray {
    if (!_layerArray) {
        _layerArray = [NSMutableArray arrayWithCapacity:100];
    }
    return _layerArray;
}

- (NSMutableArray *)textArray {
    if (!_textArray) {
        _textArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _textArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)createViewWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle divideOfUint:(NSInteger)divideOfUint countOfUnit:(NSInteger)countOfUnit
{
    _minValue = minValue;
    _maxValue = maxValue;
    _startAngle = startAngle;
    _endAngle = endAngle;
    _divideOfUint = divideOfUint;
    _countOfUnit = countOfUnit;
    _lastAngle = _startAngle - M_PI_2 * 3;
    [self drawArcWithStartAngle:_startAngle endAngle:_endAngle lineWidth:self.lineWidth color:self.normalColor];
    [self drawScaleWithDivideOfUint:_divideOfUint countOfUnit:_countOfUnit color:self.normalColor normalWidth:self.scaleLineNormalWidth bigWidth:self.scaleLineBigWidth];
    [self addTouchView];
}

- (void)drawArcWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    self.arcAngle = endAngle - startAngle;
    self.arcRadius = [self maxRadius] - self.lineWidth / 2;
    self.scaleRadius = self.arcRadius - self.lineWidth / 2 - 20;
    self.scaleValueRadius = self.scaleRadius - 15;
    [self addSubview:self.backgroundImageView];

    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIBezierPath *outArc = [UIBezierPath bezierPathWithArcCenter:center radius:self.arcRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.path = outArc.CGPath;
    shapeLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:shapeLayer];

    UIBezierPath *insideArc = [UIBezierPath bezierPathWithArcCenter:center radius:self.arcRadius - self.lineWidth / 2 - 10 startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *insideShapeLayer = [CAShapeLayer layer];
    insideShapeLayer.lineWidth = 0.25;
    insideShapeLayer.fillColor = [UIColor clearColor].CGColor;
    insideShapeLayer.strokeColor = color.CGColor;
    insideShapeLayer.path = insideArc.CGPath;
    insideShapeLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:insideShapeLayer];

    [self addSubview:self.innerCursorImageView];
}

//获取刻度线图层
- (CAShapeLayer *)scaleIndex:(NSInteger)i strokeColor:(UIColor *_Nonnull)strokeColor {
    CGFloat perAngle = _arcAngle / (_divideOfUint * _countOfUnit);
    CGFloat startAngel = (_startAngle + perAngle * i);
    CGFloat endAngel = startAngel + perAngle / 5;
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);

    UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:center radius:self.scaleRadius startAngle:startAngel endAngle:endAngel clockwise:YES];
    CAShapeLayer *perLayer = [CAShapeLayer layer];
    perLayer.fillColor = [UIColor clearColor].CGColor;
    if ((i % _divideOfUint) == 0) {
        perLayer.strokeColor = strokeColor.CGColor;
        perLayer.lineWidth = _scaleLineBigWidth;
    } else {
        perLayer.strokeColor = strokeColor.CGColor;
        perLayer.lineWidth = _scaleLineNormalWidth;
    }
    perLayer.path = tickPath.CGPath;
    return perLayer;
}

- (void)drawScaleWithDivideOfUint:(NSInteger)divideOfUint countOfUnit:(NSInteger)countOfUnit color:(UIColor *)color normalWidth:(CGFloat)normalWidth bigWidth:(CGFloat)bigWidth {
    assert(countOfUnit > 0);
    for (NSInteger i = 0; i <= divideOfUint * countOfUnit; i++) {
        CAShapeLayer *perLayer = [self scaleIndex:i strokeColor:color];
        [self.layer addSublayer:perLayer];
    }

    CGFloat textAngel = self.arcAngle / countOfUnit;
    for (NSUInteger i = 0; i <= countOfUnit; i++) {
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGPoint point = [self calculateTextPositonWithArcCenter:center angle:textAngel * i];
        NSString *tickText = [NSString stringWithFormat:@"%ld", (long)(i * ((_maxValue - _minValue) / countOfUnit) + _minValue)];

        UILabel *text = [[UILabel alloc] initWithFrame:CGRectZero];
        text.text = tickText;
        text.font = [UIFont systemFontOfSize:14.f];
        text.textColor = color;
        text.textAlignment = NSTextAlignmentCenter;
        CGFloat width = [UILabel getWidthWithTitle:tickText font:text.font];
        CGFloat height = [UILabel getHeightByWidth:width title:tickText font:text.font];
        text.frame = CGRectMake(0, 0, width, height);
        text.center = point;
        [self.textArray addObject:text];
        [self addSubview:text];
        [self sendSubviewToBack:text];
    }
    [self.layer addSublayer:self.colorGradientLayer];
}

//计算文本中心位置
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center angle:(CGFloat)angle {
    CGFloat x = self.scaleValueRadius * cosf(angle + self.startAngle);
    CGFloat y = self.scaleValueRadius * sinf(angle + self.startAngle);
    return CGPointMake(center.x + x, center.y + y);
}

- (void)refreshDashboard:(CGFloat)currentValue {
    if (currentValue > self.maxValue) {
        currentValue = self.maxValue;
    }
    if (currentValue  <=  self.minValue) {
        currentValue = self.minValue;
    }
    self.currentValue = currentValue;
    if (self.progressLayer) {
        [self.progressLayer removeFromSuperlayer];
    }
    if (self.insideProgressLayer) {
        [self.insideProgressLayer removeFromSuperlayer];
    }
    if (self.layerArray.count > 0) {
        for (CAShapeLayer *layer in self.layerArray) {
            [layer removeFromSuperlayer];
        }
        [self.layerArray removeAllObjects];
    }

    CGFloat percent = (currentValue - self.minValue) / (self.maxValue - self.minValue);
    CGFloat currentAngle = self.startAngle + (fabs(self.endAngle - self.startAngle) * percent);

    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:center radius:self.arcRadius startAngle:_startAngle endAngle:currentAngle clockwise:YES];
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    self.progressLayer = progressLayer;
    progressLayer.lineWidth = self.lineWidth;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeColor = self.highlightColor.CGColor;
    progressLayer.path = progressPath.CGPath;
    progressLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:progressLayer];

    UIBezierPath *insideProgressPath = [UIBezierPath bezierPathWithArcCenter:center radius:self.arcRadius - self.lineWidth / 2 - 10 startAngle:_startAngle endAngle:currentAngle clockwise:YES];
    CAShapeLayer *insideProgressLayer = [CAShapeLayer layer];
    self.insideProgressLayer = insideProgressLayer;
    insideProgressLayer.lineWidth = 0.5;
    insideProgressLayer.fillColor = [UIColor clearColor].CGColor;
    insideProgressLayer.strokeColor = self.highlightColor.CGColor;
    insideProgressLayer.path = insideProgressPath.CGPath;
    insideProgressLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:insideProgressLayer];
    self.colorGradientLayer.mask = progressLayer;

    for (NSInteger i = 0; i <=  _divideOfUint * _countOfUnit * percent; i++) {
        CAShapeLayer *perLayer = [self scaleIndex:i strokeColor:self.highlightColor];
        [self.layerArray addObject:perLayer];
        [self.layer addSublayer:perLayer];
    }

    for (UILabel *textLabel in self.textArray) {
        if (currentValue >= [textLabel.text floatValue]) {
            textLabel.textColor = self.highlightColor;
        } else {
            textLabel.textColor = self.normalColor;
        }
    }
    [self rotationInnerCursor:currentAngle];
}

//指针图片
- (UIImageView *)innerCursorImageView {
    if (!_innerCursorImageView) {
        UIImageView *innerCursorImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"指针new"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        innerCursorImageView.tintColor = self.highlightColor;
        innerCursorImageView.image = image;
        innerCursorImageView.frame = CGRectMake(0, 0, self.arcRadius * 2, self.arcRadius * 2);
        innerCursorImageView.contentMode = UIViewContentModeScaleAspectFit;
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        innerCursorImageView.center = center;
        _innerCursorImageView = innerCursorImageView;
        [self rotationInnerCursor:_startAngle];
    }
    return _innerCursorImageView;
}

//渐变图层
- (CAGradientLayer *)colorGradientLayer {
    if (!_colorGradientLayer) {
        CAGradientLayer *colorGradientLayer = [CAGradientLayer layer];
        colorGradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self.layer addSublayer:colorGradientLayer];
        [colorGradientLayer setColors:@[(id)[UIColor colorWithRed:72.0 / 255.0 green:178.0 / 255.0 blue:220.0 / 255.0 alpha:255.0 / 255.0].CGColor,
                                        (id)[UIColor colorWithRed:222.0 / 255.0 green:215.0 / 255.0 blue:78.0 / 255.0 alpha:255.0 / 255.0].CGColor,
                                        (id)[UIColor colorWithRed:240.0 / 255.0 green:42.0 / 255.0 blue:36.0 / 255.0 alpha:255.0 / 255.0].CGColor]];
        [colorGradientLayer setLocations:@[@0.1, @0.5, @0.9]];
        [colorGradientLayer setStartPoint:CGPointMake(0, 0.5)];
        [colorGradientLayer setEndPoint:CGPointMake(1, 0.5)];
        colorGradientLayer.mask = [CALayer layer];
        _colorGradientLayer = colorGradientLayer;
    }
    return _colorGradientLayer;
}

//背景图片
- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        UIImageView *backgroundImageView = [[UIImageView alloc] init];
        backgroundImageView.image = [UIImage imageNamed:@"仪表盘new"];
        backgroundImageView.frame = CGRectMake(0, 0, self.arcRadius * 2 + 20, self.arcRadius * 2 + 20);
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        backgroundImageView.center = center;
        _backgroundImageView = backgroundImageView;
    }
    return _backgroundImageView;
}

- (void)rotationInnerCursor:(CGFloat)angle {
    _innerCursorImageView.transform = CGAffineTransformMakeRotation(-(M_PI_4 * 6) + angle);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _innerCursorImageView.transform = CGAffineTransformMakeRotation(self.lastAngle);
}

//默认参数
- (CGFloat)lineWidth {
    if (!_lineWidth) {
        _lineWidth = 12.0f;
    }
    return _lineWidth;
}

- (CGFloat)scaleLineNormalWidth {
    if (!_scaleLineNormalWidth) {
        _scaleLineNormalWidth = 5.0f;
    }
    return _scaleLineNormalWidth;
}

- (CGFloat)scaleLineBigWidth {
    if (!_scaleLineBigWidth) {
        _scaleLineBigWidth = 10.0f;
    }
    return _scaleLineBigWidth;
}

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = RGBA(95, 93, 126, 1);
    }
    return _normalColor;
}

- (UIColor *)highlightColor {
    if (!_highlightColor) {
        _highlightColor = RGBA(0, 0, 0, 1);
    }
    return _highlightColor;
}

#pragma mark   *** Tool ***

- (CGFloat)maxRadius {
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    if (height > width) {
        return width * 0.5;
    } else {
        return height * 0.5;
    }
}

#pragma mark   *** touch ***
- (void)addTouchView {
    UIView *touchView = [UIView new];
    self.touchView = touchView;
    [self insertSubview:touchView atIndex:0];
    touchView.backgroundColor = [UIColor clearColor];

    UILongPressGestureRecognizer *pan = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
    [self.touchView addGestureRecognizer:pan];
    pan.minimumPressDuration = 0;
    pan.allowableMovement = CGFLOAT_MAX;
    self.touchView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)touchAction:(UILongPressGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self.touchView];
    CGFloat pointAngle = 0;

    if (point.x > self.bounds.size.width / 2 && point.y > self.bounds.size.height / 2) {
        CGFloat tanValue = fabs(point.y - self.bounds.size.height / 2) / fabs(point.x - self.bounds.size.width / 2);
        CGFloat tanRadian = atan(tanValue);
        pointAngle = M_PI * 2 + tanRadian;
    }
    if (point.x > self.bounds.size.width / 2 && point.y < self.bounds.size.height / 2) {
        CGFloat tanValue = fabs(point.x - self.bounds.size.width / 2) / fabs(point.y - self.bounds.size.height / 2);
        CGFloat tanRadian = atan(tanValue);
        pointAngle = M_PI_2 * 3 + tanRadian;
    }
    if (point.x < self.bounds.size.width / 2 && point.y < self.bounds.size.height / 2) {
        CGFloat tanValue = fabs(point.y - self.bounds.size.height / 2) / fabs(point.x - self.bounds.size.width / 2);
        CGFloat tanRadian = atan(tanValue);
        pointAngle = M_PI + tanRadian;
    }
    if (point.x < self.bounds.size.width / 2 && point.y > self.bounds.size.height / 2) {
        CGFloat tanValue = fabs(point.x - self.bounds.size.width / 2) / fabs(point.y - self.bounds.size.height / 2);
        CGFloat tanRadian = atan(tanValue);
        pointAngle = M_PI_2 + tanRadian;
    }

//    if (pointAngle >= self.startAngle && pointAngle <= self.endAngle) {
    CGFloat percent = (pointAngle - self.startAngle) / (self.endAngle - self.startAngle);
    CGFloat currentValue = self.minValue + (fabs(self.maxValue - self.minValue) * percent);
    [self refreshDashboard:currentValue];
//    }
}


@end
