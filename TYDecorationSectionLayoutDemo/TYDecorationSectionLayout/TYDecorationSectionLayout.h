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

@property (nonatomic, strong) NSArray *decorationViewOfKinds;// (xib names) custom xib inherit UICollectionReusableView

@end
