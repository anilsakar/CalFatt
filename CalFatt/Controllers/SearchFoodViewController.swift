//
//  SearchFoodViewController.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import UIKit

class SearchFoodViewController: UIViewController {
    
    var searchParameter: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let search = searchParameter, let str = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            
            NetworkService.shared.getFoodResults(for: str) { [weak self] result in
                
                switch result{
                case .success(let returnValue):
                    for i in 0...returnValue.foods.count-1{
                    print(returnValue.foods[i].fdcId)
                    }
                    print("succ")
                case .failure(let error):
                    print(error)
                }
              
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
