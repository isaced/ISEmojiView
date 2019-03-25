//
//  RecentEmojisManager.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

private let RecentEmojisKey = "ISEmojiView.recent"

final internal class RecentEmojisManager {
    
    // MARK: - Public variables
    
    static let sharedInstance = RecentEmojisManager()
    
    internal var maxCountOfCenetEmojis: Int!
    
    // MARK: - Public functions
    
    internal func add(emoji: Emoji, selectedEmoji: String) -> Bool {
        var emojis = recentEmojis()
        
        emoji.selectedEmoji = selectedEmoji
        
        let hasEmoji = emojis.firstIndex(of: emoji)// 'contains' is slow
        
        if let index = hasEmoji {
            emojis.remove(at: index)
        }// now recent emoji will always appear as first
        
        emojis.insert(emoji, at: 0)
        
        if emojis.count > maxCountOfCenetEmojis {
            emojis.removeLast(emojis.count-maxCountOfCenetEmojis)
        }
        
        if let data = try? JSONEncoder().encode(emojis) {
            UserDefaults.standard.set(data, forKey: RecentEmojisKey)
        }
        
        return true
    }
    
    internal func recentEmojis() -> [Emoji] {
        guard let data = UserDefaults.standard.data(forKey: RecentEmojisKey) else {
            return []
        }
        
        guard let emojis = try? JSONDecoder().decode([Emoji].self, from: data) else {
            return []
        }
        
        return emojis
    }
    
}
