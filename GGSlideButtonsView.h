//
//  ZCSlideButtonsView.h
//  
//
//  Created by 古 on 2018/1/16.
//  Copyright © 2018年 ZCTechnology. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    自定义的多按钮SegmentControl
 
    button1  button2  button3  button4  button5
             ￣￣ˇ￣￣
 */

typedef void(^SliderButtonViewBlock)(NSInteger index);

@interface GGSlideButtonsView : UIScrollView
 
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, copy) void(^clickTitleBlock)(NSString *,NSUInteger);

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titleArr;



@end
