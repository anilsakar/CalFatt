//
//  Basket.swift
//  CalFatt
//
//  Created by Anil on 10/21/20.
//

import Foundation


class Basket {
    private init() { }
    static let shared = Basket()
    var basket: [Foods] = []
    
    
    func basketTotal() -> Int {
        
        if !basket.isEmpty{
            return basket.count
        }
        return 0
    }
    
    func addToBasket(food f: Foods){
        basket.append(f)
    }
    
    func deleteFromBasket(at index: Int){
        basket.remove(at: index)
    }
    
    func insertToBasket(_ food: Foods,at index: Int){
        basket.insert(food, at: index)
    }
    
    func indexForIdentifier(identifier: String)->Int?{
        return basket.firstIndex{$0.description.contains(identifier)}
    }
    
    func getFoodInsideOfBasket(at index: Int)-> Foods{
        return basket[index]
    }
    
    func getFoodDescrition(at index: Int)-> String{
        return basket[index].description
    }
    
}
