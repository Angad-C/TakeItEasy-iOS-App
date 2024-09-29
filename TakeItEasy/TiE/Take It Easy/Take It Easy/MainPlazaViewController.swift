//
//  MainPlazaViewController.swift
//  Take It Easy
//
//  Created by Chhibber, Rishi on 1/25/23.
//

import UIKit

class MainPlazaViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapButton() {
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "playgroundScreen") as! ViewController
        vc.settargetText(poemId: sender.tag)
        present(vc, animated: true)
    }
    
}
