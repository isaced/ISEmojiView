//
//  ISEmojiView.swift
//  Pods
//
//  Created by isaced on 2016/11/8.
//
//

import Foundation

public protocol ISEmojiViewDelegate {
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String)
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView)
}

fileprivate let defaultFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216.0)

public class ISEmojiView: UIView, UIScrollViewDelegate {
    
    let EmojiWidth = CGFloat(53.0)
    let EmojiHeight = CGFloat(50.0)
    let EmojiFontSize = CGFloat(32.0)
    
    var scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: defaultFrame)
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        return scroll
    }()
    var pageControl: UIPageControl = {
        let pageContr = UIPageControl()
        pageContr.hidesForSinglePage = true
        pageContr.currentPage = 0
        pageContr.backgroundColor = .clear
        return pageContr
    }()
    var emojis: [String] = {
        let bundle = Bundle(for: ISEmojiView.self)
        if let plistPath = bundle.path(forResource: "ISEmojiView", ofType: "plist"){
            if let emojiList = NSArray(contentsOfFile: plistPath) as? [String] {
                return emojiList
            }
        }
        return []
    }()
    
    func setupUI() {
        
        let rowNum: Int = Int(frame.height / EmojiHeight)
        let colNum: Int = Int(frame.width / EmojiWidth)
        let numOfPage: Int = Int(ceil(CGFloat(emojis.count) / CGFloat(rowNum * colNum)))
        
        guard rowNum == 0 && colNum == 0 else {
            return
        }
        
        // ScrollView
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: frame.width * CGFloat(numOfPage), height: frame.height)
        
        // Add emojis
        var row: Int = 0
        var column: Int = 0
        var page: Int = 0
        var emojiPointer: Int = 0
        
        for var i in 0..<emojis.count {
            if i % Int(rowNum * colNum) == 0 {
                page = page + 1 // Increase the number of pages
                row = 0         // the number of lines is 0
                column = 0      // the number of columns is 0
            }else if i % column == 0 {
                // NewLine
                row = row + 1   // Increase the number of lines
                column = 0      // The number of columns is 0
            }
            
            let currentRect = CGRect(x: (CGFloat((page-1)) * frame.width) + (CGFloat(column) * EmojiWidth),
                                     y: CGFloat(row) * EmojiHeight,
                                     width: EmojiWidth,
                                     height: EmojiHeight)
            
            if (row == (rowNum - 1) && column == (colNum - 1)) {
                // last position of page, add delete button
                let deleteButton = UIButton()
                deleteButton.frame = currentRect
                deleteButton.tintColor = .black
                scrollView.addSubview(deleteButton)
            }else{
                let emoji = emojis[emojiPointer]
                emojiPointer = emojiPointer + 1
                
                // init Emoji Button
                
                let emojiButton = UIButton()
                emojiButton.frame = currentRect
                emojiButton.tintColor = .black
                emojiButton.titleLabel?.font = UIFont(name: "Apple color emoji", size: EmojiFontSize)
                emojiButton.setTitle(emoji, for: .normal)
                scrollView.addSubview(emojiButton)
            }
            
            column = column + 1
        }
        
        // PageControl
//        let pageControlSizes = pageControl.size(forNumberOfPages: numOfPage)
//        pageControl.frame = CGRect(x: frame.midX - pageControlSizes.width, y: frame.h, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
//        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:numOfPage];
//        self.pageControl.frame = CGRectMake(CGRectGetMidX(frame) - (pageControlSize.width / 2),
//                                            CGRectGetHeight(frame) - pageControlSize.height + 5,
//                                            pageControlSize.width,
//                                            pageControlSize.height);
    }
}
