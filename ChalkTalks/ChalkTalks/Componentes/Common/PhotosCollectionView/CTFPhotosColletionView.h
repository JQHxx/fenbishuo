//
//  CTFPhotosColletionView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/2.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTFPhotosColletionView : UICollectionView

@property (nonatomic,assign) BOOL    isLocal;

- (void)fillImagesData:(NSArray *)images status:(NSString *)status;

@end

