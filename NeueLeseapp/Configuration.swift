

import UIKit



struct Configuration {
    
    var textDirection: UIUserInterfaceLayoutDirection { return UIApplication.shared.userInterfaceLayoutDirection }
    var preferredFontSize: CGFloat { return  (UIFont.preferredFont(forTextStyle: .body).pointSize * 0.9).rounded()}
    var boldText: Bool { return UIAccessibility.isBoldTextEnabled }
    var darkMode: Bool { return UserDefaults.standard.bool(forKey: "dark_mode_preference") }
    var screenBrightness: CGFloat { return UIScreen.main.brightness }
    var increasedContrast: Bool {
        if UIAccessibility.isDarkerSystemColorsEnabled || screenBrightness > 0.95 {
            return true
        }
        return false
    }
    
    
    var dynamicCSS: String {
        
        // Text Direction
        var textAlign = "text-align: left;";
        if textDirection == .rightToLeft {
            textAlign = "text-align: right;"
        }
        
        // Font Size
        let fontSize = "font-size: \(preferredFontSize)pt;"
        
        // Font Weight
        var fontWeight = "font-weight: 400;"
        if boldText {
            fontWeight = "font-weight: 600;"
        }
        
        // Font Color
        var fontColorPrimary = ""
        var fontColorSecondary = ""
        if increasedContrast {
            if darkMode {
                fontColorPrimary = "color: white;"
                fontColorSecondary = "color: white;"
            } else {
                fontColorPrimary = "color: black;"
                fontColorSecondary = "color: black;"
            }
        } else {
            if darkMode {
                let textShadow = "text-shadow: 0px 1px 2px hsla(0, 0%, 10%, 1.0);"
                fontColorPrimary = "color: hsla(0, 0%, 60%, 1.0); \(textShadow)"
                fontColorSecondary = "color: hsla(0, 0%, 40%, 1.0); \(textShadow)"
            } else {
                let textShadow = "text-shadow: 0px 1px 2px hsla(0, 0%, 75%, 1.0);"
                fontColorPrimary = "color: hsla(0, 0%, 24%, 1.0); \(textShadow)"
                fontColorSecondary = "color: hsla(0, 0%, 60%, 1.0); \(textShadow)"
            }
        }
        
        // Background
        var background = ""
        if increasedContrast {
            if darkMode {
                background = "background: black;"
            } else {
                background = "background: white;"
            }
        } else {
            if darkMode {
                background = "background: url(\"background-dark.jpg\"); background-size: contain;"
            } else {
                background = "background: url(\"background-light.jpg\"); background-size: contain;"
            }
        }
        
        // Quotes
        var aQuote = ""
        if increasedContrast {
            if darkMode {
                aQuote = "background: hsla(0, 0%, 0%, 1.0); text-shadow: none;"
            } else {
                aQuote = "background: hsla(0, 0%, 100%, 1.0); text-shadow: none;"
            }
        } else {
            if darkMode {
                aQuote = "background: hsla(0, 0%, 28%, 1.0); text-shadow: none; box-shadow: 0px 1px 2px hsla(0, 0%, 5%, 1.0);"
            } else {
                aQuote = "background: hsla(0, 0%, 86%, 1.0); text-shadow: none; box-shadow: 0px 1px 2px hsla(0, 0%, 50%, 1.0);"
            }
        }
        
        // must be written in a single line
        let css = "html {\(fontSize)} main {\(background) \(fontColorPrimary) \(fontWeight) \(textAlign)} .author {\(fontColorSecondary)} h1,h2,h3,h4 {\(fontColorPrimary)} h2,h4 {\(fontWeight)} a.quote{\(aQuote)}"
        return css
        
    }
    
    
    func determineFontSize(forHighMovement highMovement: Bool) -> CGFloat {
        if highMovement {
            return (self.preferredFontSize * 1.4).rounded()
        } else {
            return self.preferredFontSize
        }
    }
    
    
    var recentReadingPosition: CGFloat? {
        get {
            let key = UserDefaultKeys.recentReadingPosition.rawValue
            if let recentPosition = UserDefaults.load(key: key) as? Float {
                return CGFloat(recentPosition)
            } else {
                return nil
            }
        }
        set {
            let key = UserDefaultKeys.recentReadingPosition.rawValue
            guard let recentPosition = newValue else {
                UserDefaults.removeObject(forKey: key)
                return
            }
            UserDefaults.save(object: recentPosition, key: key)
        }
    }
    
    
    
    static var bookmarks: [Bookmark]? {
        
        get {
            let key = UserDefaultKeys.bookmarks.rawValue
            
            if let stored = UserDefaults.load(key: key) as? String {
                
                let bookmarks = stored.split(separator: ";")
                var bookmarkArray = [Bookmark]()
                
                for bookmark in bookmarks {
                    let b = bookmark.split(separator: ",")
                    guard b.count >= 2 else { continue }
                    bookmarkArray.append(Bookmark(position: Double(String(b[0])) ?? 0.0, snippet: String(b[1])))
                }
                
                return bookmarkArray
                
            } else {
                return nil
            }
            
        }
        
        set {
            
            let key = UserDefaultKeys.bookmarks.rawValue
            
            if let newBookmarks = newValue {
                
                var newBookmarkString = ""
                for b in newBookmarks {
                    var s = b.snippet.replacingOccurrences(of: ",", with: " ")
                    s = b.snippet.replacingOccurrences(of: ";", with: " ")
                    newBookmarkString += "\(b.position),\(s);"
                }
                
                UserDefaults.save(object: newBookmarkString, key: key)
                
            } else {
                UserDefaults.removeObject(forKey: key)
            }
            
        }
        
    }

    
}
