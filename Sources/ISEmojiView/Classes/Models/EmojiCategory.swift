//
//  EmojiCategory.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

public class EmojiCategory {
    
    // MARK: - Public variables
    
    public var category: Category!
    public var emojis: [Emoji]!
    
    // MARK: - Initial functions
    
    public init(category: Category, emojis: [Emoji]) {
        self.category = category
        self.emojis = emojis
    }
    
}
