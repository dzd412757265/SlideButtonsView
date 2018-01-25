//
//  ZCSlideButtonsView.m
//
//
//  Created by 古 on 2018/1/16.
//  Copyright © 2018年 ZCTechnology. All rights reserved.
//

#import "GGSlideButtonsView.h"

#define RGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface GGSlideBottomIcon : UIView

@property (nonatomic, strong) UIColor   *strokeColor;
@property (nonatomic, strong) UIColor   *fillColor;

@end

@implementation GGSlideBottomIcon

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _strokeColor = [UIColor colorWithRed:187/255.f green:163/255.f blue:97/255.f alpha:1];
        _fillColor = [UIColor colorWithRed:252/255.f green:252/255.f blue:252/255.f alpha:1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    //设置背景颜色
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画一个菱形
    CGContextMoveToPoint(context, 0, height/2.f);//起始点
    CGContextAddLineToPoint(context, width/2.f, 0); //终点
    CGContextAddLineToPoint(context, width, height/2.f); //终点
    CGContextAddLineToPoint(context, width/2.f, height); //终点
    CGContextAddLineToPoint(context, 0, height/2.f); //终点
    
    //描边的颜色
    CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
    
    //填充的颜色
    CGContextSetFillColorWithColor(context, _fillColor.CGColor);
    
    //线宽
    CGContextSetLineWidth(context, 1);
    
    //线的连接点的类型(miter尖角、round圆角、bevel平角)
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

@interface GGSlideBottomView : UIView

@property (nonatomic, strong) GGSlideBottomIcon *icon;

@end

@implementation GGSlideBottomView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:187/255.f green:163/255.f blue:97/255.f alpha:1];
        
        _icon = [[GGSlideBottomIcon alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _icon.backgroundColor = [UIColor clearColor];
        [self addSubview:_icon];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.icon.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

@end

@interface GGSlideButtonsView ()<UIScrollViewDelegate>

@property(nonatomic, strong) GGSlideBottomView *lineView;

@end

@implementation GGSlideButtonsView{
    CGFloat     mButtonSpace;
    CGFloat     mTitleFont;
    
    UIButton    *mCurrentButton;
}

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titleArr{
    self = [super initWithFrame:frame];
    if (self) {
        mButtonSpace = 18.f;
        mTitleFont = 13.f;

        self.pagingEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        
        self.titleArr = titleArr;
        
        [self confingSubviews];
    }
    return self;
}

-(void)confingSubviews{
    __block float contentWidth = 0.0;
    __block float originX = mButtonSpace/2;
    
    [self.titleArr enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setTitle:title forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:mTitleFont];
        [titleBtn setTitleColor:RGBColor(24, 25, 39) forState:UIControlStateNormal];
        [titleBtn setTitleColor:RGBColor(187, 163, 97) forState:UIControlStateSelected];
        [titleBtn addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize textSize = [titleBtn sizeThatFits:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height)];
        [self addSubview:titleBtn];

        titleBtn.frame = CGRectMake(originX, 0, textSize.width, self.bounds.size.height - 3);
        
        if (idx == 0) {
            mCurrentButton = titleBtn;
            titleBtn.selected = YES;
            self.lineView.frame = CGRectMake(originX, self.bounds.size.height - 3 - 1, textSize.width, 1);
        }
        
        contentWidth += (textSize.width + mButtonSpace);
        originX += textSize.width + mButtonSpace;
    }];
    
    contentWidth += mButtonSpace/2;
    self.contentSize = CGSizeMake(contentWidth, self.bounds.size.height);
    
    [self addSubview:self.lineView];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
}

- (UIView *)lineView{
    if (_lineView == nil) {
        _lineView = [[GGSlideBottomView alloc] init];
    }
    return _lineView;
}

- (void)titleButtonAction:(UIButton *)sender{
    if (mCurrentButton == sender) {
        return;
    }
    
    mCurrentButton.selected = NO;
    mCurrentButton = sender;
    mCurrentButton.selected = YES;
    
    
    CGFloat minOffsetX = 0;
    CGFloat maxOffsetX = self.contentSize.width - self.bounds.size.width;
    if (maxOffsetX > minOffsetX) {
        CGPoint curContentOffset = self.contentOffset;
        
        //向量偏移
        CGFloat desX = curContentOffset.x + self.bounds.size.width/2.f;
        CGFloat srcX = sender.center.x;
        CGFloat offsetX = desX - srcX;
        
        //位移的向量和contentOffset的向量方向相反,所以用减法
        CGFloat contentOffsetX = curContentOffset.x - offsetX;
        
        //超出范围取边界值
        contentOffsetX = contentOffsetX < minOffsetX ? minOffsetX : contentOffsetX;
        contentOffsetX = contentOffsetX > maxOffsetX ? maxOffsetX : contentOffsetX;
        
        [self setContentOffset:CGPointMake(contentOffsetX, curContentOffset.y) animated:YES];
    }
    
    if (self.clickTitleBlock) {
        self.clickTitleBlock(mCurrentButton.titleLabel.text, [self.titleArr indexOfObject:mCurrentButton.titleLabel.text]);
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.15f];
    CGRect originRect = self.lineView.frame;
    originRect.origin.x = mCurrentButton.frame.origin.x;
    originRect.size.width = mCurrentButton.bounds.size.width;
    self.lineView.frame = originRect;
    CGPoint center = self.lineView.icon.center;
    center.x = originRect.size.width/2.f;
    self.lineView.icon.center = center;
    [UIView commitAnimations];

}
@end
