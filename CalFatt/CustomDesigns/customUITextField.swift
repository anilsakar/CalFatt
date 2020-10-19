//
//  customUITextField.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import UIKit

@IBDesignable
open class customUITextField: UITextField {
    
    func setup() {
        
        borderStyle = .none
        layer.masksToBounds = true
        textColor = UIColor(cgColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        font = UIFont(name: "HelveticaNeue-Light", size: 40)!
        alpha = 1
        textAlignment = .center
        placeholder = "Enter"
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
