//
//  CTFAudioCollectionViewFlowLayout.m
//  ChalkTalks
//
//  Created by vision on 2020/3/4.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAudioCollectionViewFlowLayout.h"

@implementation CTFAudioCollectionViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 0;
}

//设置缩放动画
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    // 拿到系统已经帮我们计算好的布局属性数组，然后对其进行拷贝一份，后续用这个新拷贝的数组去操作
    NSArray *originalArray = [super layoutAttributesForElementsInRect:rect];
    NSArray *attributesArr = [[NSArray alloc] initWithArray:originalArray copyItems:YES];
    //屏幕中线
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width/2.0f;
    //刷新cell缩放
    for (UICollectionViewLayoutAttributes *attributes in attributesArr) {
        //获取cell中心和屏幕中心的距离
        CGFloat dinstance = fabs(attributes.center.x - centerX);
        //计算比例
        CGFloat scale = 1 -  dinstance / (self.collectionView.bounds.size.width * 0.5 ) * 0.05;
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return attributesArr;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    // 拖动比较快 最终偏移量 不等于 手指离开时偏移量
    CGFloat collectionW = self.collectionView.bounds.size.width;

    // 最终偏移量
    CGPoint targetP = [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    // 0.获取最终显示的区域
    CGRect targetRect = CGRectMake(targetP.x, 0, collectionW, MAXFLOAT);
    // 1.获取最终显示的cell
    NSArray *attrs = [super layoutAttributesForElementsInRect:targetRect];
    
    // 计算获取最小间距
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        CGFloat distance = attr.center.x - targetP.x - self.collectionView.bounds.size.width * 0.5;
        if (fabs(distance) < fabs(minDelta)) {
            minDelta = distance ;
        }
    }
    //移动距离
    targetP.x += minDelta;
    if (targetP.x < 0) {
        targetP.x = 0;
    }
    return targetP;
}

//是否实时刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
}

@end
