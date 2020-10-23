//
//  FoodDetailTableViewCell.swift
//  CalFatt
//
//  Created by Anil on 10/23/20.
//

import UIKit


class FoodDetailTableViewCell: UITableViewCell {


    
    @IBOutlet weak var foodDescriptionCellView: UIView!
    @IBOutlet weak var foodNutrientName: UILabel!
    @IBOutlet weak var foodNutrientWeight: UILabel!
    
    
    override func layoutSubviews() {
        
        //MARK: Cell UI options.
        backgroundColor = .clear
        selectionStyle = .none
        
        //MARK: Cells view UI options.
        foodDescriptionCellView.backgroundColor = UIColor(red: 149/255, green: 253/255, blue: 222/255, alpha: 0.2)
        foodDescriptionCellView.layer.masksToBounds = true;
        foodDescriptionCellView.roundCorners(corners: [.topLeft, .topRight], radius: 30.0)
        foodDescriptionCellView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 40.0)
        
        
        //MARK: Cells label UI options.
        foodNutrientName.textColor = UIColor(cgColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        foodNutrientName.font = UIFont(name: "HelveticaNeue-Bold", size: 18)!
        
        foodNutrientWeight.textColor = UIColor(cgColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        foodNutrientWeight.font = UIFont(name: "HelveticaNeue-Bold", size: 18)!
        
        
    }
    
    
}
