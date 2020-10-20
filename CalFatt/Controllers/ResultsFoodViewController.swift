//
//  SearchFoodViewController.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import UIKit

class ResultFoodViewController: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    var searchParameter: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self

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

extension ResultFoodViewController: UITableViewDelegate{
    
}

extension ResultFoodViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)
        
        
        return cell
         
    }
    
    
}
