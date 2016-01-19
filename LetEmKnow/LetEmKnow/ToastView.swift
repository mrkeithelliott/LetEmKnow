//
//  ToastView.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/11/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation

public class ToastView: UIView {
    var view: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXIB()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadXIB()
    }
    
    func loadXIB(){
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ToastView", bundle: bundle)
        self.view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        self.view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 60)
        self.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.addGestureRecognizer(self.tapGesture)
        
        self.view.layer.cornerRadius = 5
        self.view.layer.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8).CGColor
        self.view.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.view.layer.shadowOpacity = 0.7
        self.view.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.view.layer.shadowRadius = 2
        
        
        addSubview(self.view)
    }
    
    public func configure(title: String? = nil, message: String, icon: UIImage? = nil){
        self.titleLabel.text = title
        self.messageLabel.text = message
        self.iconView.image = self.iconView.image?.imageWithRenderingMode(.AlwaysTemplate)
        self.iconView.tintColor = UIColor.whiteColor()
        let screen = UIScreen.mainScreen().bounds
        let height = self.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = self.frame
        frame.size.height = height
        frame.origin.y = screen.height - height - 10
        self.frame = frame
        setNeedsDisplay()
    }
    
    public func configure(title: String? = nil, message: String, delayInSeconds: Int? = nil,
        backgroundColor: UIColor, titleColor: UIColor, textColor: UIColor, icon: UIImage? = nil){
        self.view.layer.backgroundColor = backgroundColor.colorWithAlphaComponent(0.8).CGColor
        self.titleLabel.text = title
        self.titleLabel.textColor = titleColor
        self.messageLabel.text = message
        self.messageLabel.textColor = textColor
        self.iconView.image = self.iconView.image?.imageWithRenderingMode(.AlwaysTemplate)
        self.iconView.tintColor = textColor
        let screen = UIScreen.mainScreen().bounds
        let lblHeight = self.messageLabel.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        let titleHeight = self.titleLabel.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = self.frame
        let height = lblHeight + titleHeight
        frame.size.height = height + 28
        frame.origin.y = screen.height - height - 10
        self.frame = frame
        setNeedsDisplay()
    }
    
    
    @IBAction func notificationTapped(gesture: UITapGestureRecognizer){
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0, options: [.LayoutSubviews, .TransitionNone], animations: { () -> Void in
            var frame = self.frame
            frame.origin.y = frame.origin.y + self.frame.size.height + 30
            self.frame = frame
        }) { (complete) -> Void in
            self.view.removeFromSuperview()
        }
    }
}