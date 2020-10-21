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
}
