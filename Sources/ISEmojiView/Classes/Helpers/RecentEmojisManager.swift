//
//  RecentEmojisManager.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

private let recentEmojisKey = "ISEmojiView.recent"
private let recentEmojisFreqStorageKey = "ISEmojiView.recent-freq"

final public class RecentEmojisManager {
    
    // MARK: - Public variables
    
    public static let sharedInstance = RecentEmojisManager()
    
    // MARK: - Public functions
    
    public func add(emoji: Emoji, selectedEmoji: String, maxCount: Int) -> Bool {
        if (maxCount == 0) {
            UserDefaults.standard.removeObject(forKey: recentEmojisKey)
            UserDefaults.standard.removeObject(forKey: recentEmojisFreqStorageKey)
            return false
        }
        
        var emojis = recentEmojis()
        var freqData = recentEmojisFreqData()
        
        emoji.selectedEmoji = selectedEmoji
        
        if let freq = freqData[selectedEmoji] {
            freqData[selectedEmoji] = freq+1
        } else {
            freqData[selectedEmoji] = 0
            
        }
        
        guard emojis.firstIndex(of: emoji) == nil else {
                UserDefaults.standard.set(freqData, forKey: recentEmojisFreqStorageKey)
                return true
        }

        if emojis.count > maxCount {
            emojis.removeLast(emojis.count-maxCount)
        }
        
        if emojis.count > 0 && emojis.count == maxCount {
            let toRemove = emojis.removeLast()
            let newIndex = maxCount/3
            let oldOne = emojis[newIndex].selectedEmoji ?? ""
            emojis.insert(emoji, at: newIndex)
            freqData[selectedEmoji] = (freqData[oldOne] ?? 0) + 1
            freqData.removeValue(forKey: toRemove.selectedEmoji ?? "")
        } else {
            emojis.append(emoji)
        }
        
        if let data = try? JSONEncoder().encode(emojis) {
            UserDefaults.standard.set(data, forKey: recentEmojisKey)
        }
        
        UserDefaults.standard.set(freqData, forKey: recentEmojisFreqStorageKey)
        
        return true
    }
    
    internal func recentEmojisFreqData() ->[String:Int] {
        guard let data = UserDefaults.standard.dictionary(forKey: recentEmojisFreqStorageKey) as? [String:Int] else {return [:]}
        return data
    }
    
    public func recentEmojis() -> [Emoji] {
        guard let data = UserDefaults.standard.data(forKey: recentEmojisKey) else {
            return []
        }
        
        guard let emojis = try? JSONDecoder().decode([Emoji].self, from: data) else {
            return []
        }
        let freqData = recentEmojisFreqData()
        let seq = emojis.sorted {
            let left = freqData[$0.selectedEmoji ?? ""] ?? 0
            let right = freqData[$1.selectedEmoji ?? ""] ?? 0
            return left > right
        }
        return seq
    }
    
}
