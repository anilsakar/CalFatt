//
//  Search.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import Foundation

struct Search: Decodable {
    let foods: [Foods]
}

struct Foods: Decodable {
    let fdcId: Int
    let description: String
    let foodNutrients: [FoodNutrients]
}

struct FoodNutrients: Decodable {
    let nutrientName:String
    let unitName:String
    let value:Double
}
