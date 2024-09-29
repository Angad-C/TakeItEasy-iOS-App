//
//  CommonExtension.swift
//  Take It Easy
//
//  Created by Chhibber, Rishi on 1/27/23.
//
import UIKit

class Common {
    
    class func setButtonTextSizeDynamic(button: UIButton, textStyle: UIFont.TextStyle) {
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: textStyle)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.minimumScaleFactor = 0.5;
        button.titleLabel?.adjustsFontSizeToFitWidth = true;    }
    
}
