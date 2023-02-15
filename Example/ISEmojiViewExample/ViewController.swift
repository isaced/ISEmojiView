//
//  ViewController.swift
//  ISEmojiViewExample
//
//  Created by isaced on 2016/11/8.
//
//

import ISEmojiView
import UIKit

class ViewController: UITableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let keyboardViewController = segue.destination as? EmojiKeyboardViewController else {
            return
        }

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
