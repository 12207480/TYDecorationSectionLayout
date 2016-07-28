//
//  TYSectionBackgroundLayout.h
//  TYBackgroundSectionLayout
//
//  Created by tanyang on 15/12/29.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYDecorationSectionLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) BOOL alternateDecorationViews; // 交替DecorationView
@property (nonatomic, assign) BOOL decorationViewContainXib; // default YES decorationView contain xib
@property (nonatomic, strong) NSArray *decorationViewOfKinds;// if decorationViewContainXib is YES xib names,else view names. custom view or xib need inherit UICollectionReusableView

@property (nonatomic, assign) BOOL sectionHeaderViewHovering; // header悬停
@property (nonatomic, assign) BOOL sectionHeaderViewHoveringTopEdging; // 悬停距离top的间距
@end
