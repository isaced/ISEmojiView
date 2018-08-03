//
//  ViewController.swift
//  ISEmojiViewExample
//
//  Created by isaced on 2016/11/8.
//
//

import UIKit
import ISEmojiView

class ViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let keyboardViewController = segue.destination as! EmojiKeyboardViewController
        
        switch segue.identifier {
        case "EmojiKeyboardWithPageControl":
            keyboardViewController.bottomType = .pageControl
        case "EmojiKeyboardWithCategories":
            keyboardViewController.bottomType = .categories
        case "EmojiKeyboardWithPageControlAndCustomEmojis":
            keyboardViewController.bottomType = .pageControl
            keyboardViewController.emojis = [
                EmojiCategory(
                    category: Category.custom("My Title", "ic_customCategory"),
                    emojis: [Emoji(emojis: ["😂"]), Emoji(emojis: ["🤣"])]
                )
            ]
        case "EmojiKeyboardWithCategoriesAndCustomEmojis":
            keyboardViewController.bottomType = .categories
            keyboardViewController.emojis = [
                EmojiCategory(
                    category: Category.custom("My Title", "ic_customCategory"),
                    emojis: [Emoji(emojis: ["😂"]), Emoji(emojis: ["🤣"])]
                )
            ]
        default:
            break
        }
    }
    
}
