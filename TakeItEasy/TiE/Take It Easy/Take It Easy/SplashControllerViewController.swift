//
//  SplashControllerViewController.swift
//  Take It Easy
//
//  Created by Chhibber, Rishi on 1/24/23.
//

import UIKit

class SplashControllerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Wait 2 seconds and go to the next screen.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            self.performSegue(withIdentifier: "MainPlaza", sender: nil)
        }
    }
    
}
