//
//  IQToolbar.swift
// 
// Copyright (c) 2013-20 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

/** @abstract   IQToolbar for IQKeyboardManager.    */
@available(iOSApplicationExtension, unavailable)
@objc open class RabbitRiderToolbar: UIToolbar, UIInputViewAudioFeedback {

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    private func initialize() {

        sizeToFit()

        autoresizingMask = .flexibleWidth
        self.isTranslucent = true
        self.barTintColor = nil

        let positions: [UIBarPosition] = [.any, .bottom, .top, .topAttached]

        for position in positions {

            self.setBackgroundImage(nil, forToolbarPosition: position, barMetrics: .default)
            self.setShadowImage(nil, forToolbarPosition: .any)
        }

        //Background color
        self.backgroundColor = nil
    }

    /**
     Previous bar button of toolbar.
     */
    private var privatePreviousBarButton: RabbitRiderBarButtonItem?
    @objc open var previousBarButton: RabbitRiderBarButtonItem {
        get {
            if privatePreviousBarButton == nil {
                privatePreviousBarButton = RabbitRiderBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
            }
            return privatePreviousBarButton!
        }

        set (newValue) {
            privatePreviousBarButton = newValue
        }
    }

    /**
     Next bar button of toolbar.
     */
    private var privateNextBarButton: RabbitRiderBarButtonItem?
    @objc open var nextBarButton: RabbitRiderBarButtonItem {
        get {
            if privateNextBarButton == nil {
                privateNextBarButton = RabbitRiderBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
            }
            return privateNextBarButton!
        }

        set (newValue) {
            privateNextBarButton = newValue
        }
    }

    /**
     Title bar button of toolbar.
     */
    private var privateTitleBarButton: RabbitRiderTitleBarButtonItem?
    @objc open var titleBarButton: RabbitRiderTitleBarButtonItem {
        get {
            if privateTitleBarButton == nil {
                privateTitleBarButton = RabbitRiderTitleBarButtonItem(title: nil)
                privateTitleBarButton?.accessibilityLabel = "Title"
                privateTitleBarButton?.accessibilityIdentifier = privateTitleBarButton?.accessibilityLabel
            }
            return privateTitleBarButton!
        }

        set (newValue) {
            privateTitleBarButton = newValue
        }
    }

    /**
     Done bar button of toolbar.
     */
    private var privateDoneBarButton: RabbitRiderBarButtonItem?
    @objc open var doneBarButton: RabbitRiderBarButtonItem {
        get {
            if privateDoneBarButton == nil {
                privateDoneBarButton = RabbitRiderBarButtonItem(title: nil, style: .done, target: nil, action: nil)
            }
            return privateDoneBarButton!
        }

        set (newValue) {
            privateDoneBarButton = newValue
        }
    }

    /**
     Fixed space bar button of toolbar.
     */
    private var privateFixedSpaceBarButton: RabbitRiderBarButtonItem?
    @objc open var fixedSpaceBarButton: RabbitRiderBarButtonItem {
        get {
            if privateFixedSpaceBarButton == nil {
                privateFixedSpaceBarButton = RabbitRiderBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            }
            privateFixedSpaceBarButton!.isSystemItem = true

            if #available(iOS 10, *) {
                privateFixedSpaceBarButton!.width = 6
            } else {
                privateFixedSpaceBarButton!.width = 20
            }

            return privateFixedSpaceBarButton!
        }

        set (newValue) {
            privateFixedSpaceBarButton = newValue
        }
    }

    @objc override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFit = super.sizeThatFits(size)
        sizeThatFit.height = 44
        return sizeThatFit
    }

    @objc override open var tintColor: UIColor! {

        didSet {
            if let unwrappedItems = items {
                for item in unwrappedItems {
                    item.tintColor = tintColor
                }
            }
        }
    }

    @objc override open func layoutSubviews() {

        super.layoutSubviews()

        if #available(iOS 11, *) {
            return
        } else if let customTitleView = titleBarButton.customView {
            var leftRect = CGRect.null
            var rightRect = CGRect.null
            var isTitleBarButtonFound = false

            let sortedSubviews = self.subviews.sorted(by: { (view1: UIView, view2: UIView) -> Bool in
                if view1.frame.minX != view2.frame.minX {
                    return view1.frame.minX < view2.frame.minX
                } else {
                    return view1.frame.minY < view2.frame.minY
                }
            })

            for barButtonItemView in sortedSubviews {

                if isTitleBarButtonFound {
                    rightRect = barButtonItemView.frame
                    break
                } else if barButtonItemView === customTitleView {
                    isTitleBarButtonFound = true
                    //If it's UIToolbarButton or UIToolbarTextButton (which actually UIBarButtonItem)
                } else if barButtonItemView.isKind(of: UIControl.self) {
                    leftRect = barButtonItemView.frame
                }
            }

            let titleMargin: CGFloat = 16

            let maxWidth: CGFloat = self.frame.width - titleMargin*2 - (leftRect.isNull ? 0 : leftRect.maxX) - (rightRect.isNull ? 0 : self.frame.width - rightRect.minX)
            let maxHeight = self.frame.height

            let sizeThatFits = customTitleView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))

            var titleRect: CGRect

            if sizeThatFits.width > 0, sizeThatFits.height > 0 {
                let width = min(sizeThatFits.width, maxWidth)
                let height = min(sizeThatFits.height, maxHeight)

                var xPosition: CGFloat

                if !leftRect.isNull {
                    xPosition = titleMargin + leftRect.maxX + ((maxWidth - width)/2)
                } else {
                    xPosition = titleMargin
                }

                let yPosition = (maxHeight - height)/2

                titleRect = CGRect(x: xPosition, y: yPosition, width: width, height: height)
            } else {

                var xPosition: CGFloat

                if !leftRect.isNull {
                    xPosition = titleMargin + leftRect.maxX
                } else {
                    xPosition = titleMargin
                }

                let width: CGFloat = self.frame.width - titleMargin*2 - (leftRect.isNull ? 0 : leftRect.maxX) - (rightRect.isNull ? 0 : self.frame.width - rightRect.minX)

                titleRect = CGRect(x: xPosition, y: 0, width: width, height: maxHeight)
            }

            customTitleView.frame = titleRect
        }
    }

    @objc open var enableInputClicksWhenVisible: Bool {
        return true
    }
}
