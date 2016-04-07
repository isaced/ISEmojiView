//
//  ViewController.m
//  ISEmojiViewSample
//
//  Created by isaced on 14/12/25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "ViewController.h"
#import "ISEmojiView.h"

@interface ViewController ()<ISEmojiViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init TextView
    self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.textView];
    
    // init ISEmojiView
    ISEmojiView *emojiView = [[ISEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    emojiView.delegate = self;
    emojiView.textField = self.textView;
    self.textView.inputView = emojiView;
    
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)emojiView:(ISEmojiView *)emojiView didSelectEmoji:(NSString *)emoji{
    self.textView.text = [self.textView.text stringByAppendingString:emoji];
}

-(void)emojiView:(ISEmojiView *)emojiView didPressDeleteButton:(UIButton *)deletebutton{
    if (self.textView.text.length > 0) {
        NSRange lastRange = [self.textView.text rangeOfComposedCharacterSequenceAtIndex:self.textView.text.length-1];
        self.textView.text = [self.textView.text substringToIndex:lastRange.location];
    }
}

@end
