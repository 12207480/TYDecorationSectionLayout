//
//  TYSectionBackgroundLayout.m
//  TYBackgroundSectionLayout
//
//  Created by tanyang on 15/12/29.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "TYDecorationSectionLayout.h"

@interface TYDecorationSectionLayout (){
    BOOL _insetForSectionAtIndexFlag;
}

@property (nonatomic, strong) NSArray *decorationAttributes;

@end

@implementation TYDecorationSectionLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (_decorationViewOfKinds.count == 0) {
        return;
    }
    
    _insetForSectionAtIndexFlag = [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)];
    
    [self configureDecorationAttributes];
}

- (void)configureDecorationAttributes
{
    NSInteger numberOfSection = self.collectionView.numberOfSections;
    NSMutableArray *decorationAttributes = [NSMutableArray arrayWithCapacity:numberOfSection];
    
    for (NSInteger section = 0; section < numberOfSection; ++section) {
        if (!_alternateDecorationViews && section >= _decorationViewOfKinds.count) {
            break;
        }
        
        NSString *decorationViewOfKind = self.decorationViewOfKinds[section % self.decorationViewOfKinds.count];
        if ([decorationViewOfKind isKindOfClass:[NSNull class]])
            continue;
        
        if (section < numberOfSection) {
            [self registerNib:[UINib nibWithNibName:decorationViewOfKind bundle:nil] forDecorationViewOfKind:decorationViewOfKind];
        }
        
        CGRect sectionFrame = [self frameOfSectionViewWithSection:section];
        
        if (CGRectEqualToRect(sectionFrame, CGRectZero)) {
            continue;
        }
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewOfKind withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        attributes.zIndex = -1;
        attributes.frame = sectionFrame;
        [decorationAttributes addObject:attributes];
    }
    _decorationAttributes = [decorationAttributes copy];
    
}

- (CGRect)frameOfSectionViewWithSection:(NSInteger)section
{
    
    NSInteger lastIndex = [self.collectionView numberOfItemsInSection:section] - 1;
    if (lastIndex < 0)
        return CGRectZero;

    UICollectionViewLayoutAttributes *firstItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    UICollectionViewLayoutAttributes *lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:section]];
    
    UIEdgeInsets sectionInset = _insetForSectionAtIndexFlag ? [((id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self insetForSectionAtIndex:section] : self.sectionInset;
    
    CGRect frame = CGRectUnion(firstItem.frame, lastItem.frame);
    frame.origin.x -= sectionInset.left;
    frame.origin.y -= sectionInset.top;
    
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        frame.size.width += sectionInset.left + sectionInset.right;
        frame.size.height = self.collectionView.frame.size.height;
    }
    else
    {
        frame.size.width = self.collectionView.frame.size.width;
        frame.size.height += sectionInset.top + sectionInset.bottom;
    }
    
    return frame;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    for (UICollectionViewLayoutAttributes *attribute in _decorationAttributes)
    {
        if (!CGRectIntersectsRect(rect, attribute.frame))
            continue;
        
        [attributes addObject:attribute];
    }
    return attributes;
}

@end
