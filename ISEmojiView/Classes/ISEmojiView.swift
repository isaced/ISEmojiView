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
    
    let EmojiSize = CGSize(width: 50, height: 50)
    let EmojiFontSize = CGFloat(32.0)
    
    var scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: defaultFrame)
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        scroll.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
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
        if let filePath = ISEmojiView.pathOfResourceInBundle(filename: "ISEmojiList", filetype: "plist") {
            if let emojiList = NSArray(contentsOfFile: filePath) as? [String] {
                return emojiList
            }
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
        
        let rowNum: Int = Int(frame.height / EmojiSize.height)
        let colNum: Int = Int(frame.width / EmojiSize.width)
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
            
            let currentRect = CGRect(x: (CGFloat((page-1)) * frame.width) + (CGFloat(column) * EmojiSize.width),
                                     y: CGFloat(row) * EmojiSize.height,
                                     width: EmojiSize.width,
                                     height: EmojiSize.height)
            
            if (row == (rowNum - 1) && column == (colNum - 1)) {
                // last position of page, add delete button
                let deleteButton = UIButton(type: .custom)
                deleteButton.frame = currentRect
                let deleteButtonImage = UIImage(named: "icon_delete", in: ISEmojiView.thisBundle(), compatibleWith: nil)
                deleteButton.setImage(deleteButtonImage, for: .normal)
                deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
                deleteButton.tintColor = .lightGray
                scrollView.addSubview(deleteButton)
            }else{
                let emoji = emojis[emojiPointer]
                emojiPointer = emojiPointer + 1
                
                // init Emoji Button
                
                let emojiButton = UIButton(type: .custom)
                emojiButton.frame = currentRect
                emojiButton.tintColor = .black
                emojiButton.titleLabel?.font = UIFont(name: "Apple color e  moji", size: EmojiFontSize)
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
        pageControl.pageIndicatorTintColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
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
    
    static func thisBundle() -> Bundle {
        let podBundle = Bundle(for: ISEmojiView.classForCoder())
        if let bundleURL = podBundle.url(forResource: "ISEmojiView", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }else{
                assertionFailure("Could not load the bundle")
            }
        }else{
            assertionFailure("Could not create a path to the bundle")
        }
        return Bundle()
    }
    static func pathOfResourceInBundle(filename:String, filetype: String) -> String? {
        if let filePath = thisBundle().path(forResource: filename, ofType: filetype) {
            return filePath
        }
        return nil
    }
}
