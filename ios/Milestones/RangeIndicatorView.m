//
//  RangeIndicatorView.m
//  EssentialTips
//
//  Created by Nathan  Pahucki on 6/25/14.
//  Copyright (c) 2015 InfantIQ. All rights reserved.
//

#import "RangeIndicatorView.h"

#define SELECTED_BORDER_COLOR [UIColor appSelectedColor].CGColor
#define SELECTED_FILL_COLOR [UIColor colorWithRed: (float)198 / 255 green:(float)221 / 255 blue:(float)225 / 255 alpha:1.0].CGColor
#define BORDER_COLOR UIColorFromRGB(0xA9A9B1).CGColor
#define BORDER_WIDTH 3
#define REFERENCE_SIZE 7
#define ANIMATION_DURATION 1;


@interface PieSliceLayer : CALayer
@property(nonatomic) CGFloat startAngle;
@property(nonatomic) CGFloat endAngle;
@property CGFloat animationDuration;
@end

@implementation PieSliceLayer

@dynamic startAngle, endAngle;

- (CABasicAnimation *)makeAnimationForKey:(NSString *)key {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
    anim.fromValue = [[self presentationLayer] valueForKey:key];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = ANIMATION_DURATION;
    return anim;
}

- (id <CAAction>)actionForKey:(NSString *)event {
    if ([event isEqualToString:@"startAngle"] ||
            [event isEqualToString:@"endAngle"]) {
        return [self makeAnimationForKey:event];
    }

    return [super actionForKey:event];
}

- (id)init {
    self = [super init];
    if (self) {
        self.animationDuration = ANIMATION_DURATION;
        [self setNeedsDisplay];
    }
    return self;
}

- (id)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[PieSliceLayer class]]) {
            PieSliceLayer *other = (PieSliceLayer *) layer;
            self.startAngle = other.startAngle;
            self.endAngle = other.endAngle;
            self.animationDuration = other.animationDuration;
        }
    }

    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"startAngle"] || [key isEqualToString:@"endAngle"] || [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    // Create the path
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(center.x, center.y);


    int clockwise = self.startAngle > self.endAngle;

    // Draw the filled in section
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, radius - BORDER_WIDTH, self.startAngle, self.endAngle, clockwise);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, SELECTED_FILL_COLOR);
    CGContextSetStrokeColorWithColor(ctx, SELECTED_BORDER_COLOR);
    CGContextSetLineWidth(ctx, 0); // No border line
    CGContextDrawPath(ctx, kCGPathFillStroke);


    // Draw the highlighted border section.
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, center.x, center.y, radius - BORDER_WIDTH, self.startAngle, self.endAngle, clockwise);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, SELECTED_BORDER_COLOR);
    CGContextSetLineWidth(ctx, BORDER_WIDTH);
    CGContextDrawPath(ctx, kCGPathFillStroke);

}

@end


@implementation RangeIndicatorView {
    PieSliceLayer *_shapeLayer;
    CAShapeLayer *_circleLayer;
    CAShapeLayer *_referencePointLayer;
    NSInteger _startRange;
    NSInteger _endRange;
    NSInteger _rangeScale;
    NSInteger _rangeReferencePoint;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initShapeLayer];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // Called when used from storyboard
    self = [super initWithCoder:aDecoder];
    [self initShapeLayer];
    return self;
}

- (void)initShapeLayer {
    _shapeLayer = [[PieSliceLayer alloc] init];
    _shapeLayer.frame = CGRectZero; // Don't show, this will also keep the layer form being drawn.
    _shapeLayer.contentsScale = [[UIScreen mainScreen] scale];
    [self.layer addSublayer:_shapeLayer];

    _circleLayer = [CAShapeLayer layer];
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.strokeColor = BORDER_COLOR;
    _circleLayer.lineWidth = BORDER_WIDTH;
    [self.layer insertSublayer:_circleLayer below:_shapeLayer];

}

- (NSInteger)startRange {
    return _startRange;
}

- (NSInteger)endRange {
    return _endRange;
}

- (void)setStartRange:(NSInteger)startRange {
    NSAssert(_rangeScale > 0, @"Expected rangeScale to be set first!");
    NSAssert(startRange >= 0, @"startRange(%ld) must be greater than 0", (long) startRange);
    _startRange = startRange;
    // Get ratio of start range to max
    float ratio = (float) _startRange / (float) _rangeScale;
    _shapeLayer.startAngle = (2 * M_PI * ratio) - M_PI / 2; // Quarter turn left
}

- (void)setEndRange:(NSInteger)endRange {
    NSAssert(_rangeScale > 0, @"Expected rangeScale to be set first!");
    if (endRange > _rangeScale) endRange = _rangeScale;
    _endRange = endRange;
    float ratio = (float) endRange / (float) _rangeScale;
    _shapeLayer.endAngle = (2 * M_PI * ratio) - M_PI / 2; // Quarter turn left
}

- (void)setRangeReferencePoint:(NSInteger)rangeReferencePoint {
    _rangeReferencePoint = rangeReferencePoint;
    if (!_referencePointLayer) {
        _referencePointLayer = [CAShapeLayer layer];
        _referencePointLayer.fillColor = [UIColor whiteColor].CGColor;
        _referencePointLayer.strokeColor = [UIColor appNormalColor].CGColor;
        _referencePointLayer.lineWidth = 2;
        [self.layer insertSublayer:_referencePointLayer above:_shapeLayer];
    }
    [self setNeedsLayout];
}

- (NSInteger)rangeReferencePoint {
    return _rangeReferencePoint;
}


- (void)setRangeScale:(NSInteger)rangeScale {
    NSAssert(rangeScale > 0, @"Expected rangeScale to be greater than 0!");
    _rangeScale = rangeScale;
    [self setNeedsLayout];
}

- (NSInteger)rangeScale {
    return _rangeScale;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_rangeScale > 0 && self.frame.size.height > 0 && self.frame.size.width > 0) {
        _shapeLayer.frame = self.bounds; // Show the indicator.
        _circleLayer.frame = self.bounds;

        CGRect circleRect = CGRectInset(self.bounds, BORDER_WIDTH, BORDER_WIDTH);
        _circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:circleRect].CGPath;

        if (_referencePointLayer) {
            float ratio = (float) _rangeReferencePoint / (float) _rangeScale;
            double referenceAngle = M_PI * ((ratio * 360.0) - 180.0) / 180.0;
            double radius = circleRect.size.height / 2.0;
            double x = radius - ((radius) * sin(referenceAngle));
            double y = radius + ((radius) * cos(referenceAngle));
            _referencePointLayer.position = CGPointMake(x, y);
            _referencePointLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, REFERENCE_SIZE, REFERENCE_SIZE)].CGPath;

        }

    }
}


@end
