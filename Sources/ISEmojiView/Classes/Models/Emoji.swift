//
//  Emoji.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 03/08/2018.
//

import Foundation

public class Emoji: Codable {
    
    // MARK: - Public variables
    
    /// The emoji variants, e.g. the base glyph plus skin tones.
    public var variants: [String]
    
    /// The variant currently selected by the user, if any.
    public var selectedEmoji: String?
    
    /// The representative glyph of this emoji (its first variant).
    public var emoji: String {
        return variants.first ?? ""
    }
    
    // MARK: - Initial functions
    
    public init(variants: [String]) {
        self.variants = variants
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case selectedEmoji
        case variants = "emojis"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        selectedEmoji = try values.decodeIfPresent(String.self, forKey: .selectedEmoji)
        variants = try values.decodeIfPresent([String].self, forKey: .variants) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encodeIfPresent(selectedEmoji, forKey: .selectedEmoji)
        try values.encode(variants, forKey: .variants)
    }
    
}

extension Emoji: Equatable {
    public static func == (lhs: Emoji, rhs: Emoji) -> Bool {
        return lhs.selectedEmoji == rhs.selectedEmoji && lhs.variants == rhs.variants
    }
}
