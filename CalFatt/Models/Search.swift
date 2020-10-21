//
//  Search.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import Foundation

struct Search: Decodable {
    var foods: [Foods]
}

struct Foods: Decodable {
    let fdcId: Int
    let description: String
}

/*struct FoodNutrients: Decodable {
    let nutrientName:String
    let unitName:String
    let value:Double
}*/
