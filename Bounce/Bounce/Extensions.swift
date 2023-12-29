//
//  Extensions.swift
//  Bounce
//
//  Created by Stanislav Tereshchenko on 26.12.2023.
//

import Foundation
import UIKit

extension UIView {
    func setShadow(with opacity: Float = 1.0){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.masksToBounds = false
    }
}
