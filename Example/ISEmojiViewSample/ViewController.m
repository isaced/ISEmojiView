//
//  ViewController.m
//  ISEmojiViewSample
//
//  Created by isaced on 14/12/25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "ViewController.h"
#import "ISEmojiView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init TextView
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:textView];
    
    // init ISEmojiView
    ISEmojiView *emojiView = [[ISEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    textView.inputView = emojiView;
    
    [textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
