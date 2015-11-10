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
 
- image: UIImage to display. It is essential that all images have the same dimensions.
*/
public struct TVButtonLayer {
    var internalImage: UIImage?
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
 - parallaxIntensity: A value between 0 and 2 (the subtle default is 1.0). Change for a more pronounced parallax effect.
 */
public class TVButton: UIButton, UIGestureRecognizerDelegate {
    
    // MARK: Internal variables
    var containerView = UIView()
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var motionManager: CMMotionManager?
    var panGestureRecognizer: UIPanGestureRecognizer?
    var specularView = UIImageView()
    var tapGestureRecognizer: UITapGestureRecognizer?
    var tvButtonAnimation: TVButtonAnimation?
    
    // MARK: Public variables
    
    // Build the stack of TVButton layers inside the button
    public var layers: [TVButtonLayer]? {
        didSet {
            // Remove existing parallax layer views
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
            // Instantiate an imageview with corners for every layer
            for layer in layers! {
                let imageView = UIImageView(image: layer.internalImage)
                imageView.layer.cornerRadius = cornerRadius
                imageView.clipsToBounds = true
                containerView.addSubview(imageView)
            }
            // Add specular shine effect
            let frameworkBundle = NSBundle(forClass: TVButton.self)
            let specularViewPath = frameworkBundle.pathForResource("Specular", ofType: "png")
            specularView.image = UIImage(contentsOfFile:specularViewPath!)
            self.containerView.addSubview(specularView)
        }
    }

    // This value determines the intensity of the parallax depth effect.
    public var parallaxIntensity: CGFloat = defaultParallaxIntensity

    // For closer approximation of the Apple TV icons, set this to a darker version of the dominant colour in the button
    public var shadowColor: UIColor = UIColor.blackColor() {
        didSet {
            self.layer.shadowColor = shadowColor.CGColor
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
    
    // MARK: UIGestureRecognizer actions and delegate
    
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