

import UIKit


struct Bookmark {
    var position: Double
    var snippet: String
}



class BookmarkView: UIView {
    
    
    var isSet: Bool = false

    
    func startAnimation() {
        
        let mark = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: self.bounds.height))
        
        
        let config = Configuration()
        if config.darkMode {
            mark.backgroundColor = UIColor.white
        } else {
            mark.backgroundColor = UIColor.black
        }
        
        
        self.addSubview(mark)


        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseIn, animations: {
            
            mark.frame = self.bounds
            
        }) { (_) in
            
            let hapticFeedback = UISelectionFeedbackGenerator()
            hapticFeedback.selectionChanged()
            
            UIView.animate(withDuration: 0.1, delay: 0.3, options: .curveEaseOut, animations: {
                let finalWidth: CGFloat = 6.0
                mark.frame = CGRect(x: mark.frame.maxX - finalWidth,
                                    y: mark.frame.minY,
                                    width: finalWidth,
                                    height: mark.frame.height)
                
            }, completion: { (_) in

                self.isSet = true
                
            })

        }
        
        
    }
    
    
}
