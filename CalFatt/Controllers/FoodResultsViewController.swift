//
//  SearchFoodViewController.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import UIKit
import AnimatedGradientView

class FoodResultsViewController: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var searchParameter: String?
    var searchResults: Search?
    var selectedFoodId:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        //MARK: Make resultsTableView hidden and start spinner because waiting data to fetch
        resultsTableView.isHidden = true
        
        
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        spinner.isHidden = false
        spinner.startAnimating()
        getSearchedData()
        drawGradientEffect()
        
    }
    
    func drawGradientEffect(){
        let animatedGradient = AnimatedGradientView(frame: view.bounds)
        animatedGradient.direction = .up
        animatedGradient.animationValues = [(colors: ["#283048", "#283048"], .up, .axial),//Dark gray to gray
                                            (colors: ["#757F9A", "#D7DDE8"], .right, .axial),//Gray to light gray
                                            (colors: ["#73C8A9", "#373B44"], .down, .axial),
                                            (colors: ["#485563", "#29323c"], .left, .axial)]
        //self.hideNavigationBar()
        view.addSubview(animatedGradient)
        view.sendSubviewToBack(animatedGradient)
    }
    
    func getSearchedData(){
        if let search = searchParameter, let str = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            
            
           NetworkManager.shared.getFoodResults(for: str) { [weak self] result in
                
                switch result{
                case .success(let returnValue):
                    self?.searchResults = returnValue
                    DispatchQueue.main.async {
                        
                        self?.resultsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
                        self?.resultsTableView.backgroundColor = .clear
                        self?.resultsTableView.reloadData()
                        self?.resultsTableView.isHidden = false
                        
                        self?.spinner.stopAnimating()
                        self?.spinner.isHidden = true
                    }
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }
    
    //MARK: addToBasketAction function
    func addToBasketAction(at indexpath:IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .normal, title: "Add To Basket") { (action, view, completion) in
            
            if let food = self.searchResults?.foods[indexpath.row]{
                Basket.shared.basket.append(food)
                self.searchResults?.foods.remove(at: indexpath.row)
                self.resultsTableView.deleteRows(at: [indexpath], with: .fade)
                completion(true)
            }
            
        }
        action.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
            UIImage(named: "basket")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
        }
        action.backgroundColor = UIColor(red: 73/255, green: 99/255, blue: 135/255, alpha: 0.2)
        
        return action
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "foodDetails" {
            if let foodDetailVC = segue.destination as? FoodDetailViewController{
                foodDetailVC.foodId = selectedFoodId
            }
        }
    }
    

    
}

extension FoodResultsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}



extension FoodResultsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults?.foods.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let addToBasket = addToBasketAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [addToBasket])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as! ResultsTableViewCell
        
        //MARK: Animate created cell
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
        
        //MARK: Assign cell label the returned API results.
        cell.foodDescriptionLabel.text = searchResults?.foods[indexPath.row].description
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedFoodId = searchResults?.foods[indexPath.row].fdcId
        performSegue(withIdentifier: "foodDetails", sender: nil)
        
    }
    
    
}


