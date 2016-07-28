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

- (instancetype)init
{
    if (self = [super init]) {
        _decorationViewContainXib = YES;
        _sectionHeaderViewHovering = YES;
    }
    return self;
}

// override
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
    if (_decorationViewOfKinds.count == 0) {
        return;
    }
    
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
            if (_decorationViewContainXib) {
                [self registerNib:[UINib nibWithNibName:decorationViewOfKind bundle:nil] forDecorationViewOfKind:decorationViewOfKind];
            }else {
                [self registerClass:NSClassFromString(decorationViewOfKind) forDecorationViewOfKind:decorationViewOfKind];
            }
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

// override
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if (_decorationAttributes.count == 0 && !_sectionHeaderViewHovering) {
        return [super layoutAttributesForElementsInRect:rect];
    }
    
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    for (UICollectionViewLayoutAttributes *attribute in _decorationAttributes)
    {
        if (!CGRectIntersectsRect(rect, attribute.frame))
            continue;
        
        [attributes addObject:attribute];
    }
    
    if (_sectionHeaderViewHovering) {
        [self layoutHeaderFooterAttributesForElementsInRect:rect attributes:attributes];
    }
    
    return [attributes copy];
}


// 引用了XLPlainFlowLayout
- (void)layoutHeaderFooterAttributesForElementsInRect:(CGRect)rect attributes:(NSMutableArray *)superAttributes
{
    NSMutableIndexSet *noneHeaderSections = [NSMutableIndexSet indexSet];
    for (UICollectionViewLayoutAttributes *attributes in superAttributes)
    {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell)
        {
            [noneHeaderSections addIndex:attributes.indexPath.section];
        }
    }
    
    for (UICollectionViewLayoutAttributes *attributes in superAttributes)
    {
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
        {
            [noneHeaderSections removeIndex:attributes.indexPath.section];
        }
    }

    [noneHeaderSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (attributes)
        {
            [superAttributes addObject:attributes];
        }
    }];
    
    for (UICollectionViewLayoutAttributes *attributes in superAttributes) {
        
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
        {
            NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:attributes.indexPath.section];
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:attributes.indexPath.section];
            NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:MAX(0, numberOfItemsInSection-1) inSection:attributes.indexPath.section];
            
            UICollectionViewLayoutAttributes *firstItemAttributes, *lastItemAttributes;
            if (numberOfItemsInSection>0)
            {
                firstItemAttributes = [self layoutAttributesForItemAtIndexPath:firstItemIndexPath];
                lastItemAttributes = [self layoutAttributesForItemAtIndexPath:lastItemIndexPath];
            }else
            {
                firstItemAttributes = [UICollectionViewLayoutAttributes new];
                CGFloat y = CGRectGetMaxY(attributes.frame)+self.sectionInset.top;
                firstItemAttributes.frame = CGRectMake(0, y, 0, 0);
                lastItemAttributes = firstItemAttributes;
            }
            
            CGRect rect = attributes.frame;
            CGFloat offset = self.collectionView.contentOffset.y + _sectionHeaderViewHoveringTopEdging;
            
            UIEdgeInsets sectionInset = _insetForSectionAtIndexFlag ? [((id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self insetForSectionAtIndex:attributes.indexPath.section] : self.sectionInset;

            CGFloat headerY = firstItemAttributes.frame.origin.y - rect.size.height - sectionInset.top;
            CGFloat maxY = MAX(offset,headerY);

            CGFloat headerMissingY = CGRectGetMaxY(lastItemAttributes.frame) + sectionInset.bottom - rect.size.height;
            rect.origin.y = MIN(maxY,headerMissingY);
            
            attributes.frame = rect;
            attributes.zIndex = 1;
        }
    }

}

//return YES;表示一旦滑动就实时调用上面这个layoutAttributesForElementsInRect:方法
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    if (_sectionHeaderViewHovering) {
        return YES;
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBound];
}

@end
