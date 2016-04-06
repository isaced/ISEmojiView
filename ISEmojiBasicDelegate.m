//
//  EmojiBasicDelegate.m
//  CatchAppDemo
//
//  Created by Andrew Thomas on 4/6/16.
//  Copyright © 2016 catchapp. All rights reserved.
//

#import "ISEmojiBasicDelegate.h"

@implementation ISEmojiBasicDelegate

-(id)initWithField:(UITextField*)field
{
  self = [super init];
  _field = field;
  return self;
}



#pragma mark ISEmojiViewDelegate
-(void)emojiView:(ISEmojiView *)emojiView didSelectEmoji:(NSString *)emoji
{
  NSRange range = self.field.selectedRange;
  
  
  BOOL proceed;
  if ([self.field.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
  {
    proceed = [self.field.delegate textField:self.field shouldChangeCharactersInRange:range replacementString:emoji];
  }
  else
  {
    proceed = YES;
  }
  
  self.field.text = [self.field.text stringByReplacingCharactersInRange:range withString:emoji];
  
  self.field.selectedRange = NSMakeRange(range.location+emoji.length,0); //Restore caret position.  Correct both both insert and overtype
                                           
  
  //TODO: restore cursor position
}

-(void)emojiView:(ISEmojiView *)emojiView didPressDeleteButton:(UIButton *)deletebutton
{
  if (self.field.text.length > 0)
  {
    NSRange range = self.field.selectedRange;
    
    BOOL previousCharacterIsEmoji = YES; //TODO: actually check
    
    if (range.length == 0 && range.location > 0) //Nothing is selected ...
    {
      if (previousCharacterIsEmoji)
        range = NSMakeRange(range.location-2,2); //...so backspace previous emoji group
      else
        range = NSMakeRange(range.location-1,1); //...so backspace previous ascii char
     }
    
    BOOL proceed;
    if ([self.field.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
      proceed = [self.field.delegate textField:self.field shouldChangeCharactersInRange:range replacementString:@""];
    }
    else
    {
      proceed = YES;
    }
    
    self.field.text = [self.field.text stringByReplacingCharactersInRange:range withString:@""];
    
    self.field.selectedRange = NSMakeRange(range.location,0); //Restore caret position.  Correct for both kinds of backspace
    
    //TODO: other UITextViewDelegate methods
  }
}

//TODO: consider refactoring these two methods to reduce duplication

@end



@implementation UITextField(Range)
-(NSRange)selectedRange
{
  UITextRange *selectedTextRange = self.selectedTextRange;
  NSUInteger location = [self offsetFromPosition:self.beginningOfDocument
                                           toPosition:selectedTextRange.start];
  NSUInteger length = [self offsetFromPosition:selectedTextRange.start
                                         toPosition:selectedTextRange.end];
  NSRange selectedRange = NSMakeRange(location, length);
  return selectedRange;
}

-(void)setSelectedRange:(NSRange)range
{
  //How overcomplicated can Cocoa make things for me?!
  UITextPosition* start = [self positionFromPosition:self.beginningOfDocument offset:range.location];
  UITextPosition* end = [self positionFromPosition:start offset:range.length];
  self.selectedTextRange = [self textRangeFromPosition:start toPosition:end];
}
@end



@implementation ISEmojiView(Setup)
+(ISEmojiBasicDelegate*)addTo:(UITextField*)field
{
  ISEmojiView* emoji = [[ISEmojiView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 216)];
  
  ISEmojiBasicDelegate* delegate = [[ISEmojiBasicDelegate alloc] init];
  delegate.field = field;
  emoji.delegate = delegate;
  
  field.inputView = emoji;
  
  return delegate;
}
@end
