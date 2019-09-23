


import UIKit


class BookmarkScroller: UIView {

    
    var locationKnob = UIView()
    
    
    override func draw(_ rect: CGRect) {
        configureView()
    }
    
    
    
    func configureView() {
        
        let screen = UIScreen.main.bounds
        let height = screen.height / screen.width * self.bounds.width

        let locationKnobMargin: CGFloat = 6.0
        let locationKnobFrame = CGRect(x: locationKnobMargin * 0.5,
                                       y: locationKnob.frame.origin.y,
                                       width: self.bounds.width - locationKnobMargin,
                                       height: height.rounded(.up))
        
        locationKnob.frame = locationKnobFrame
        locationKnob.layer.cornerRadius = 4.0
        
        if Configuration().darkMode {
            // Dark Mode
            locationKnob.layer.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.5, alpha: 1.0).cgColor
            locationKnob.layer.shadowColor = UIColor.black.cgColor
            locationKnob.layer.shadowRadius = 2.0
            locationKnob.layer.shadowOffset = CGSize(width: -1.0, height: 2.0)
            locationKnob.layer.shadowOpacity = 0.2
        } else {
            // Light Mode
            locationKnob.layer.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.65, alpha: 1.0).cgColor
            locationKnob.layer.shadowColor = UIColor.black.cgColor
            locationKnob.layer.shadowRadius = 2.0
            locationKnob.layer.shadowOffset = CGSize(width: -1.0, height: 2.0)
            locationKnob.layer.shadowOpacity = 0.1
        }

        
        if !self.contains(locationKnob) {
            self.addSubview(locationKnob)
        }
        
    }
    
    
    
    func updateLocationKnob(position y: CGFloat, contentHeight: CGFloat, verticalOffset: CGFloat) {

        let verticalPosition = y / (contentHeight - self.frame.height) * (self.frame.height - locationKnob.frame.height)
        let verticalOffset = min(0, verticalOffset)
        
        locationKnob.frame = CGRect(x: locationKnob.frame.minX,
                                    y: verticalPosition + verticalOffset,
                                    width: locationKnob.frame.width,
                                    height: locationKnob.frame.height)

    }
    
 
    
    func displayBookmarks(_ contentHeight: CGFloat) {
        
        guard let bookmarks = Configuration.bookmarks else { return }
        
        for bookmark in bookmarks {
            
            let position = CGFloat(bookmark.position)
            let height = self.bounds.height
            let y = (position / contentHeight) * height
            
            let mark = UIView(frame: CGRect(x: 6.0, y: y, width: 8.0, height: 2.0))
            
            let config = Configuration()
            if config.darkMode {
                mark.layer.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.8, alpha: 1.0).cgColor
            } else {
                mark.layer.backgroundColor = UIColor.lightGray.cgColor
            }
            
            self.addSubview(mark)
            
        }
        
    }
    
    
}
