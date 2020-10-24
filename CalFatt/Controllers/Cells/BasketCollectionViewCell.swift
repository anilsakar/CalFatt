//
//  BasketCollectionViewCell.swift
//  CalFatt
//
//  Created by Anil on 10/24/20.
//

import UIKit

class BasketCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var foodDescriptionLabel: UILabel!
    
    
     override func layoutSubviews() {
         super.layoutSubviews()
         
         //MARK: Cell UI options.
         backgroundColor = .clear
         
         //MARK: Cells view UI options.
         cellView.backgroundColor = UIColor(red: 73/255, green: 99/255, blue: 135/255, alpha: 0.2)
         cellView.layer.masksToBounds = true;
         cellView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
         cellView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 20.0)
         
         //MARK: Cells label UI options.
         foodDescriptionLabel.textColor = UIColor(cgColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
         foodDescriptionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)!
     }
}
