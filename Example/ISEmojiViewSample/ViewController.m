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
    [self.view addSubview:self.textView];
    
    // init ISEmojiView
    ISEmojiView *emojiView = [[ISEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    emojiView.delegate = self;
    self.textView.inputView = emojiView;
    
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)emojiView:(ISEmojiView *)emojiView didSelectEmoji:(NSString *)emoji{
    self.textView.text = [self.textView.text stringByAppendingString:emoji];
}

@end
