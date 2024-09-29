//
//  CommonExtension.swift
//  Take It Easy
//
//  Created by Chhibber, Rishi on 1/27/23.
//

import UIKit

extension UIButton {
    
    func setDynamicFontSize(textStyle: UIFont.TextStyle = .body) {
        Common.setButtonTextSizeDynamic(button: self, textStyle: textStyle)
    }
    
}
