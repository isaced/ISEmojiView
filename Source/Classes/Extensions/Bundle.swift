//
//  Bundle.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

extension Bundle {
    
    class var podBundle: Bundle {
        var podBundle = Bundle(for: EmojiView.classForCoder())
        
        // CocoaPods -> ISEmojiView.framework/ISEmojiView.bundle
        // Carthage  -> ISEmojiView.framework/
        if let bundleURL = podBundle.url(forResource: "ISEmojiView", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                podBundle = bundle
            }
        }
        
        return podBundle
    }
    
}
