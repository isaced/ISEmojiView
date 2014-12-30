//
//  ISEmojiView.h
//  ISEmojiViewSample
//
//  Created by isaced on 14/12/25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ISEmojiViewDelegate;

@interface ISEmojiView : UIView

@property (nonatomic, assign) id<ISEmojiViewDelegate> delegate;

@end

@protocol ISEmojiViewDelegate <NSObject>

-(void)emojiView:(ISEmojiView *)emojiView didSelectEmoji:(NSString *)emoji;
-(void)emojiView:(ISEmojiView *)emojiView didPressDeleteButton:(UIButton *)deletebutton;

@end

@interface ISDeleteButton : UIButton

@end