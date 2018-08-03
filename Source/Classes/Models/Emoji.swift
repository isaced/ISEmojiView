//
//  Emoji.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 03/08/2018.
//

import Foundation

public class Emoji: Codable {
    
    // MARK: - Public variables
    
    var selectedEmoji: String?
    var emojis: [String]!
    var emoji: String {
        return emojis[0]
    }
    
    // MARK: - Initial functions
    
    public init(emojis: [String]) {
        self.emojis = emojis
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case selectedEmoji, emojis
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        selectedEmoji = try values.decode(String.self, forKey: .selectedEmoji)
        emojis = try values.decodeIfPresent([String].self, forKey: .emojis)
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(selectedEmoji, forKey: .selectedEmoji)
        try values.encode(emojis, forKey: .emojis)
    }
    
}

