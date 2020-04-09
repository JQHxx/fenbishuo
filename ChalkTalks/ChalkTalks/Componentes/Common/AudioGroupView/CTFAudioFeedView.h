//
//  CTFAudioFeedView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTFAudioFeedView : UIView

@property (nonatomic,assign) BOOL    autoScroll;           //自动滚动

-(void)fillAudioImageData:(NSArray<AudioImageModel *>*)audioImages
                indexPath:(NSIndexPath *)indexPath
             currentIndex:(NSInteger)currentIndex
                   status:(NSString *)status;

/*
 * 开始播放
 */
- (void)startPlayAudio;

/*
 * 停止播放
 */
- (void)stopPlayAudio;


@end

NS_ASSUME_NONNULL_END
