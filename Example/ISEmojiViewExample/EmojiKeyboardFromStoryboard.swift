//
//  EmojiKeyboardFromStoryboard.swift
//  ISEmojiViewExample
//
//  Created by Beniamin Sarkisyan on 04/08/2018.
//

import Foundation
import ISEmojiView

class EmojiKeyboardFromStoryboard: UIViewController, EmojiViewDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var emojiView: EmojiView! {
        didSet {
            emojiView.delegate = self
        }
    }
    
    // MARK: - EmojiViewDelegate
    
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        textView.insertText(emoji)
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        textView.deleteBackward()
    }
}
