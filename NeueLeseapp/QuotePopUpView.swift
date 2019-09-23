


import UIKit


class QuotePopUpView: UIView {

    override func draw(_ rect: CGRect) {
        
        let margin: CGFloat = 16.0
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: margin,
                                       y: margin,
                                       width: bounds.width - (margin * 2),
                                       height: bounds.height - (margin * 2))
        backgroundLayer.cornerRadius = 6.0
        
        let config = Configuration()
        
        if config.darkMode {
            backgroundLayer.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.28, alpha: 1.0).cgColor
            backgroundLayer.shadowOpacity = 0.6
        } else {
            backgroundLayer.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.86, alpha: 1.0).cgColor
            backgroundLayer.shadowOpacity = 0.3
            
        }
        
        backgroundLayer.shadowColor = UIColor.black.cgColor
        backgroundLayer.shadowRadius = 6.0
        backgroundLayer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        
        self.layer.addSublayer(backgroundLayer)
        
    }

}
