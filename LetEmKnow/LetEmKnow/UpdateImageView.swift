//
//  UpdateImageView.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/21/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation

public class UpdateImageView: UIView {
    var view: UIView!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var imageView: UIImageView!
    
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
        let nib = UINib(nibName: "UpdateImageView", bundle: bundle)
        self.view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        self.view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
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
    
    public func configure(image: UIImage? = nil){
        if image != nil{
            self.imageView.image = image!
        }
        else{
            let bundle = NSBundle(forClass: self.dynamicType)
            let img = UIImage(named: "sample", inBundle: bundle, compatibleWithTraitCollection: nil)
            self.imageView.image = img
        }
    }
}