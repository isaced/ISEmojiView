//
//  ViewController.swift
//  ISEmojiViewExample
//
//  Created by isaced on 2016/11/8.
//
//

import UIKit
import ISEmojiView

class ViewController: UIViewController, ISEmojiViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emojiView = ISEmojiView()
        emojiView.delegate = self
        textView.inputView = emojiView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    //MARK: <ISEmojiViewDelegate>
    
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        textView.insertText(emoji)
    }
    
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        textView.deleteBackward()
    }
}

