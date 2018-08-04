//
//  Bundle.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

extension Bundle {
    
    class var podBundle: Bundle {
        let podBundle = Bundle(for: EmojiView.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "ISEmojiView", withExtension: "bundle") else {
            fatalError("Could not create a path to the bundle")
        }
        
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not load the bundle")
        }
        
        return bundle
    }
    
}
