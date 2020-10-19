//
//  Foods.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import Foundation

struct Foods: Decodable {
    let fdcId: Int
    let description: String
    let foodNutrients: [FoodNutrients]
}
