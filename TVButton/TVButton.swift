//
//  TVButton.swift
//  TVButton
//
//  Created by Roy Marmelstein on 08/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parallax Layer Object
 
- Image: UIImage to display. It is essential that all images have the same dimensions.
*/
public struct TVButtonLayer {
    public var internalImage: UIImage?
}

public extension TVButtonLayer {
    public init(image: UIImage) {
        self.init(internalImage: image)
    }
}

/**
 TVButton Object
 
 - layers: Provide the layers for the parallax button.
 - shadowColor: Provide the dominant colour of your background for an even better shadow.
 - parallaxIntensity: A value between 0 and 2 (the subtle default is 0.6). Change for a more pronounced parallax effect.
 */
public class TVButton: UIButton, UIGestureRecognizerDelegate {
    
    var specularView = UIImageView()
    var containerView = UIView()
    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    var tvButtonAnimation: TVButtonAnimation?
    
    public var shadowColor : UIColor? {
        didSet {
            self.layer.shadowColor = shadowColor!.CGColor
        }
    }
    
    public var parallaxIntensity : CGFloat = 0.7
    
    public var layers : [TVButtonLayer]? {
        didSet {
            // Remove existing parallax layer views
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
            for layer in layers! {
                let imageView = UIImageView(image: layer.internalImage)
                imageView.layer.cornerRadius = cornerRadius
                imageView.clipsToBounds = true
                containerView.addSubview(imageView)
            }
            let frameworkBundle = NSBundle(forClass: TVButton.self)
            let specularViewPath = frameworkBundle.pathForResource("Specular", ofType: "png")
            specularView.image = UIImage(contentsOfFile:specularViewPath!)
            self.containerView.addSubview(specularView)
        }
    }
    
    // MARK: Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = self.bounds
        // Adjust size for every subview
        for subview in containerView.subviews {
            if subview == specularView {
                subview.frame = CGRect(origin: subview.frame.origin, size: CGSizeMake(specularScale * containerView.frame.size.width, specularScale * containerView.frame.size.height))
            }
            else {
                subview.frame = CGRect(origin: subview.frame.origin, size: containerView.frame.size)
            }
        }
        self.layer.masksToBounds = false;
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        self.layer.shadowPath = shadowPath.CGPath
    }
    
    
    func setup() {
        containerView.userInteractionEnabled = false
        self.addSubview(containerView)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        specularView.alpha = 0.0
        specularView.contentMode = UIViewContentMode.ScaleAspectFill
        self.shadowColor = UIColor.blackColor()
        self.layer.shadowRadius = self.bounds.size.height/(2*shadowFactor)
        self.layer.shadowOffset = CGSizeMake(0.0, shadowFactor/3)
        self.layer.shadowOpacity = 0.5;
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer?.delegate = self
        self.addGestureRecognizer(panGestureRecognizer!)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.addGestureRecognizer(tapGestureRecognizer!)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(longPressGestureRecognizer!)
        tvButtonAnimation = TVButtonAnimation(button: self)
    }
    
    // MARK: UIGestureRecognizer Actions
    
    func handlePan(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizerDidUpdate(gestureRecognizer)
    }
    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizerDidUpdate(gestureRecognizer)
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        super.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    func gestureRecognizerDidUpdate(gestureRecognizer: UIGestureRecognizer){
        if layers == nil {
            return
        }
        let point = gestureRecognizer.locationInView(self)
        if let animation = tvButtonAnimation {
            if gestureRecognizer.state == .Began {
                animation.enterMovement()
                animation.processMovement(point)
            }
            else if gestureRecognizer.state == .Changed {
                animation.processMovement(point)
            }
            else {
                if longPressGestureRecognizer?.state == .Began || longPressGestureRecognizer?.state == .Changed || panGestureRecognizer?.state == .Began || panGestureRecognizer?.state == .Changed {
                    return
                }
                animation.exitMovement()
            }
        }
    }
    
    
    // MARK: Animations
    
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}