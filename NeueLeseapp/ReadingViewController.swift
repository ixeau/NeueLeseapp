

import UIKit
import WebKit
import CoreMotion


class ReadingViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    
    private let readingView = WKWebView()
    private let quotePopUpView = QuotePopUpView()
    private let activityManager = CMMotionActivityManager()
    
    private var bookmarkScroller = BookmarkScroller()
    private var config = Configuration()
    
    private var recentFontSize: CGFloat = Configuration().preferredFontSize
    private var recentDarkMode: Bool = Configuration().darkMode
    private var recentContrast: Bool = Configuration().increasedContrast
    
    override var prefersStatusBarHidden: Bool { return true }
    
    
    var contentHeight: CGFloat? = nil {
        didSet {
            bookmarkScroller.displayBookmarks(contentHeight ?? UIScreen.main.bounds.height)
        }
    }

    
    
    // MARK: - Scroller Position
    
    var scrollerPosition: ScrollerPositions = .right {
        didSet {
            if oldValue == scrollerPosition {
                return
            } else {

                let origin = bookmarkScroller.frame.origin
                let size = bookmarkScroller.frame.size
                
                switch scrollerPosition {
                case .left:
                    let origin = CGPoint(x: self.readingView.frame.width - size.width, y: origin.y)
                    self.bookmarkScroller.frame = CGRect(origin: origin, size: size)
                    UIView.animate(withDuration: 0.5) {
                        self.bookmarkScroller.alpha = 0.0
                        self.bookmarkScroller.alpha = 1.0
                    }
                case .right:
                    let origin = CGPoint(x: 0.0, y: origin.y)
                    self.bookmarkScroller.frame = CGRect(origin: origin, size: size)
                    UIView.animate(withDuration: 0.5) {
                        self.bookmarkScroller.alpha = 0.0
                        self.bookmarkScroller.alpha = 1.0
                    }
                }
                
            }
        }
    }
    
    enum ScrollerPositions: Int {
        case left = 0
        case right = 1
    }
    
    var leftHandedTouchLocations = [Bool]() {
        didSet {
            
            if leftHandedTouchLocations.count > 50 {
                leftHandedTouchLocations = Array(leftHandedTouchLocations.dropFirst())
            }
            
            let trues = leftHandedTouchLocations.filter{$0}.count
            let falses = leftHandedTouchLocations.count - trues
            
            if trues > falses {
                self.scrollerPosition = .left // righthanded
            } else {
                self.scrollerPosition = .right // lefthanded
            }
        }
    }
    
    
    
    // MARK: - Activity
    
    var highMovement = [Bool]() {
        didSet {
            
            if highMovement.count > 4 {
                highMovement = Array(highMovement.dropFirst())
            }
            
            let trues = highMovement.filter{$0}.count
            let falses = highMovement.count - trues
            
            if trues > falses {
                // High Activity
                // print("🐆")
                let fontSize = config.determineFontSize(forHighMovement: true)
                if fontSize != self.recentFontSize {
                    self.injectNew(fontSize: fontSize)
                    self.recentFontSize = fontSize
                }
                
            } else {
                // No Activity
                // print("🐢")
                let fontSize = config.determineFontSize(forHighMovement: false)
                if fontSize != self.recentFontSize {
                    self.injectNew(fontSize: fontSize)
                    self.recentFontSize = fontSize
                }
            }
            
        }
    }
    
    
    
    // MARK: - Class
    
    override func viewDidLoad() {
        
        // Track Screen Brightness
        let noteCenter = NotificationCenter.default
        noteCenter.addObserver(self,
                               selector: #selector(updateUI(notification:)),
                               name: UIScreen.brightnessDidChangeNotification,
                               object: nil)
        
        // Track Settings
        noteCenter.addObserver(self,
                               selector: #selector(updateUI(notification:)),
                               name: UserDefaults.didChangeNotification,
                               object: nil)
        
        // Track Activity
        activityManager.startActivityUpdates(to: .main) { (activity) in
            guard let activity = activity else { return }
            
            if activity.walking || activity.running || activity.cycling || activity.automotive {
                self.highMovement.append(true)
            }
            
            if activity.stationary || activity.unknown {
                self.highMovement.append(false)
            }
        }
        
    }
    
    
    
    override func loadView() {
        
        super.loadView()
        
        self.configureView()
        self.configureGestures()
        
        guard let url = Bundle.main.url(forResource: "content", withExtension: "html") else { return }
        self.readingView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        
        quotePopUpView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: 142.0)
        hideBookmarkPopUp()
        self.view.addSubview(self.quotePopUpView)

    }

    
    
    @objc func updateUI(notification: NSNotification) {

        if let userDefaults = notification.object as? UserDefaults {
            let newDarkModeValue = userDefaults.bool(forKey: "dark_mode_preference")
            if newDarkModeValue != self.recentDarkMode {
                
                print("dark mode changed to: \(newDarkModeValue)")
                self.readingView.reload()
                self.recentDarkMode = newDarkModeValue
            } else {
                return
            }
        } else {
            if notification.name == UIScreen.brightnessDidChangeNotification {
                if config.increasedContrast != self.recentContrast {
                    
                    print("increased contrast changed to: \(config.increasedContrast)")
                    self.readingView.reload()
                    self.recentContrast = config.increasedContrast
                }
            }
        }
        
    }
    
    
    
    func configureView() {
        
        // Reading View
        readingView.alpha = 0.0
        
        readingView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: self.view.bounds.width,
                                   height: self.view.bounds.height)
        
        readingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        readingView.uiDelegate = self
        readingView.navigationDelegate = self
        readingView.backgroundColor = UIColor.black
        readingView.isOpaque = false
        
        readingView.scrollView.delegate = self
        readingView.scrollView.showsHorizontalScrollIndicator = false
        readingView.scrollView.showsVerticalScrollIndicator = false
        readingView.scrollView.panGestureRecognizer.isEnabled = false
        readingView.scrollView.pinchGestureRecognizer?.isEnabled = false
        readingView.scrollView.maximumZoomScale = 1.0
        readingView.scrollView.minimumZoomScale = 1.0
        readingView.scrollView.zoomScale = 1.0
        readingView.scrollView.bouncesZoom = false
        
        self.view.addSubview(readingView)
        
        
        // Scroller
        bookmarkScroller.alpha = 0.0
        let scrollerMargin: CGFloat = 4.0
        let scrollerFrame = CGRect(x: 0.0,
                                   y: scrollerMargin,
                                   width: 20.0,
                                   height: UIScreen.main.bounds.height - (scrollerMargin * 2))
        bookmarkScroller = BookmarkScroller(frame: scrollerFrame)
        self.view.addSubview(bookmarkScroller)
        
    }
    
    
    

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            
            if let quotes = navigationAction.request.url?.lastPathComponent {
                let components = quotes.components(separatedBy: "-")
                if components.count >= 2 {
                    
                    let chapter = components[0]
                    let quote = components[1]
                    
                    #if DEBUG
                    print("chapter \(chapter) / quote \(quote)")
                    #endif
                    
                }
            }
            
            showBookmarkPopUp()

            decisionHandler(WKNavigationActionPolicy.cancel)
            
            return
        }

        decisionHandler(WKNavigationActionPolicy.allow)
        
    }
    
    
    func showBookmarkPopUp() {
        UIView.animate(withDuration: 0.1) {
            let newFrame = CGRect(x: self.quotePopUpView.frame.minX,
                                  y: 0.0,
                                  width: self.quotePopUpView.frame.width,
                                  height: self.quotePopUpView.frame.height)
            self.quotePopUpView.frame = newFrame
            self.quotePopUpView.alpha = 1.0
            
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            
        }
    }
    
    
    func hideBookmarkPopUp() {
        if self.quotePopUpView.frame.minY == 0.0 {
            UIView.animate(withDuration: 0.3) {
                let newFrame = CGRect(x: self.quotePopUpView.frame.minX,
                                      y: -self.quotePopUpView.frame.height,
                                      width: self.quotePopUpView.frame.width,
                                      height: self.quotePopUpView.frame.height)
                self.quotePopUpView.frame = newFrame
                self.quotePopUpView.alpha = 0.0
    
                let feedback = UISelectionFeedbackGenerator()
                feedback.selectionChanged()
            }
        }
    }
    
    
    
    
    
    // MARK: - Scrolling

    func saveRecentReadingPosition() {
        let y = readingView.scrollView.contentOffset.y
        self.config.recentReadingPosition = y
    }
    
    func restoreRecentReadingPosition() {
        let recentOffset = CGPoint(x: 0.0, y: self.config.recentReadingPosition ?? 0.0)
        readingView.scrollView.setContentOffset(recentOffset, animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideBookmarkPopUp()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        saveRecentReadingPosition()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        saveRecentReadingPosition()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        bookmarkScroller.updateLocationKnob(position: scrollView.contentOffset.y,
                                            contentHeight: self.contentHeight ?? 0.0,
                                            verticalOffset: readingView.scrollView.contentOffset.y)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    
    
    // MARK: - WKWebView
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(0.5)) {

            // Dynamic CSS injection
            let css = self.config.dynamicCSS
            let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            
            self.readingView.evaluateJavaScript(js, completionHandler: { (_, _) in
                
                // Recent Reading Position
                self.restoreRecentReadingPosition()
                
                // Content Height
                self.getContentHeight(completion: { (height) in
                    
                    self.contentHeight = height
                    
                    // Fade-In
                    UIView.animate(withDuration: 0.3, animations: {
                        self.readingView.alpha = 1.0
                        self.bookmarkScroller.alpha = 1.0
                    })
                    
                })
                
            })
            
        }
    }

    private func getContentHeight(completion: @escaping (CGFloat) -> Void) {
        self.readingView.evaluateJavaScript("document.readyState", completionHandler: { (complete, _) in
            if complete != nil {
                self.readingView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
                    if let h = height as? CGFloat {
                        completion(h)
                    } else {
                        completion(0.0)
                    }
                })
            }
        })
    }
    
    
    func injectNew(fontSize: CGFloat) {
        let css = "html {font-size: \(fontSize)pt;}"
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        self.readingView.evaluateJavaScript(js, completionHandler: { (_, _) in
            })
    }
    
    
    
    // MARK: - Gestures
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    private func configureGestures() {
        
        // Swipe Left
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(gestureAction(gesture:)))
        swipeLeftRecognizer.delegate = self
        swipeLeftRecognizer.direction = .left
        readingView.addGestureRecognizer(swipeLeftRecognizer)

        // Swipe Right
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(gestureAction(gesture:)))
        swipeRightRecognizer.delegate = self
        swipeRightRecognizer.direction = .right
        readingView.addGestureRecognizer(swipeRightRecognizer)
    
        // Tap
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureAction(gesture:)))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        readingView.addGestureRecognizer(tapRecognizer)

        // Long Press
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(gestureAction(gesture:)))
        longPressRecognizer.delegate = self
        longPressRecognizer.minimumPressDuration = 0.3
        readingView.scrollView.addGestureRecognizer(longPressRecognizer)

        // Pan
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureAction(gesture:)))
        panRecognizer.delegate = self
        readingView.scrollView.addGestureRecognizer(panRecognizer)
        
    }
    
    
    @objc func gestureAction(gesture: UIGestureRecognizer) {
        
        // Swipes
        if let swipe = gesture as? UISwipeGestureRecognizer {
            
            let uiDirection = self.config.textDirection
            
            if swipe.direction == .left && uiDirection == .leftToRight {
                print("display bookmarks from the right")
            } else if swipe.direction == .right && uiDirection == .rightToLeft {
                print("display bookmarks from the left")
            }
            
        }
        
        // Tab
        if let tab = gesture as? UITapGestureRecognizer {
            let y = tab.location(in: readingView).y
            
            #if DEBUG
            print("tab: \(y)")
            #endif
            
            // High Movement Fake:
            highMovement = [true, true, true, true, true, true, true, true, true, true]
            
        }
        
        // Long Press
        if let longPress = gesture as? UILongPressGestureRecognizer {
            
            if longPress.state == .began {
                
                let hapticFeedback = UIImpactFeedbackGenerator()
                hapticFeedback.impactOccurred()
                
                let bookmarkFrame = CGRect(x: 0.0,
                                           y: longPress.location(in: readingView).y - 40.0,
                                           width: readingView.bounds.width,
                                           height: 4.0)
                let bookmark = BookmarkView(frame: bookmarkFrame)
                bookmark.accessibilityIdentifier = "newBookmark"
                self.view.addSubview(bookmark)
                
                bookmark.startAnimation()
                
            } else if longPress.state == .ended {
                
                if let i = self.view.subviews.firstIndex(where: { $0.accessibilityIdentifier == "newBookmark" }) {
                    
                    if let newBookmark = self.view.subviews[i] as? BookmarkView {
                        if newBookmark.isSet == false {
                            
                            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                                newBookmark.alpha = 0.0
                            }) { (_) in
                                newBookmark.removeFromSuperview()
                            }

                        } else {
                            newBookmark.accessibilityIdentifier = "bookmark"
                        }
                    }

                    
                }
                
                
            }
          
        }
        
        // Pan
        if let pan = gesture as? UIPanGestureRecognizer {
            let location = pan.location(in: readingView.scrollView)
            if location.x >= UIScreen.main.bounds.width * 0.5 {
                leftHandedTouchLocations.append(false)
            } else {
                leftHandedTouchLocations.append(true)
            }
        }
        
    }
    

}
