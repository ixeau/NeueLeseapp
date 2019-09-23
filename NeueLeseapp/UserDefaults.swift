

import UIKit


extension UserDefaults {
    
    static func save(object: Any, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(object, forKey: key)
        defaults.synchronize()
    }
    
    static func load(key: String) -> Any? {
        let defaults = UserDefaults.standard
        if let storedData: Any = defaults.object(forKey: key) {
            return storedData
        } else {
            return nil
        }
    }
    
    static func removeObject(forKey key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
    
    @objc dynamic var darkMode: Bool {
        return bool(forKey: "dark_mode_preference")
    }
    
}


enum UserDefaultKeys: String {
    case recentReadingPosition = "recentReadingPosition"
    case bookmarks = "bookmarks"
}
