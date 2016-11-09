//
//  ViewController.swift
//  ISEmojiViewExample
//
//  Created by isaced on 2016/11/8.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emojiView = ISEmojiView()
        textView.becomeFirstResponder()
    }

}

