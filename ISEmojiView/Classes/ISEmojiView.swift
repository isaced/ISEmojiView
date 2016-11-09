//
//  ISEmojiView.swift
//  Pods
//
//  Created by isaced on 2016/11/8.
//
//

import Foundation

public protocol ISEmojiViewDelegate: class {
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
        let podBundle = Bundle(for: ISEmojiView.classForCoder())
        if let bundleURL = podBundle.url(forResource: "ISEmojiView", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                if let plistPath = bundle.path(forResource: "ISEmojiList", ofType: "plist") {
                    if let emojiList = NSArray(contentsOfFile: plistPath) as? [String] {
                        return emojiList
                    }
                }
            }else{
                assertionFailure("Could not load the bundle")
            }
        }else{
            assertionFailure("Could not create a path to the bundle")
        }
        return []
    }()
    public weak var delegate: ISEmojiViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: defaultFrame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() {
        
        let rowNum: Int = Int(frame.height / EmojiHeight)
        let colNum: Int = Int(frame.width / EmojiWidth)
        let numOfPage: Int = Int(ceil(CGFloat(emojis.count) / CGFloat((rowNum * colNum))))
        
        guard rowNum != 0 && colNum != 0 else {
            return
        }
        
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
            }else if i % colNum == 0 {
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
                deleteButton.setTitle("⬅︎", for: .normal) // ←
                deleteButton.setTitleColor(.black, for: .normal)
                deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
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
                emojiButton.addTarget(self, action: #selector(emojiButtonPressed), for: .touchUpInside)
                scrollView.addSubview(emojiButton)
            }
            
            column = column + 1
        }
        
        // ScrollView
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: frame.width * CGFloat(numOfPage), height: frame.height)
        self.addSubview(scrollView)
        
        // PageControl
        let pageControlSizes = pageControl.size(forNumberOfPages: numOfPage)
        pageControl.frame = CGRect(x: frame.midX - pageControlSizes.width / 2.0,
                                   y: frame.height-pageControlSizes.height + 5,
                                   width: pageControlSizes.width, height:
            pageControlSizes.height)
        pageControl.addTarget(self, action: #selector(pageControlTouched), for: .touchUpInside)
        pageControl.numberOfPages = numOfPage
        self.addSubview(pageControl)
    }
    
    func emojiButtonPressed(sender: UIButton) {
        if let emoji = sender.titleLabel?.text {
            self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji)
        }
    }
    
    func deleteButtonPressed(sender: UIButton) {
        self.delegate?.emojiViewDidPressDeleteButton(emojiView: self)
    }
    
    func pageControlTouched(sender: UIPageControl) {
        var bounds = scrollView.bounds
        bounds.origin.x = bounds.width * CGFloat(sender.currentPage)
        scrollView.scrollRectToVisible(bounds, animated: true)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let newPageNumber = Int(floor((scrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1)
        if pageControl.currentPage != newPageNumber {
            pageControl.currentPage = newPageNumber
        }
    }
    
}
