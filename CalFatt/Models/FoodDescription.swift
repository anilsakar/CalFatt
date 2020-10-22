//
//  FoodDescription.swift
//  CalFatt
//
//  Created by Anil on 10/22/20.
//

import Foundation

struct FoodDescription: Decodable {
    var description:String
    var foodNutrients: [FoodNutrients]
   // var foodPortions: [FoodPortions]
}

struct FoodNutrients: Decodable {
    var nutrient: Nutrient
   var amount: Double?
}

struct Nutrient: Decodable{
    
    var name: String
    var unitName:String
    
}

struct FoodPortions: Decodable {
    var gramWeight: Double
    var portionDescription: String
}
