//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 08/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import UIKit
import Foundation
import TVButton

class ViewController: UIViewController {

    @IBOutlet weak var tvButton: TVButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = TVButtonLayer(image: UIImage(named: "TVButtonBackground.png")!)
        let pattern = TVButtonLayer(image: UIImage(named: "TVButtonPattern.png")!)
        let top = TVButtonLayer(image: UIImage(named: "TVButtonTop.png")!)
        tvButton.layers = [background, pattern, top]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

