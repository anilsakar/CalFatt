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
    
    @IBOutlet weak var foodSearchBar: UISearchBar!
    
    var searchParameter: String?
    var searchResults: Search?
    var selectedFood:Foods?
    
    var onlyOnce:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        foodSearchBar.delegate = self
        
        prepareViewDidLoad()
        

    }
    
    func prepareViewDidLoad(){
        
        //MARK: Search bar UI options.
        foodSearchBar.compatibleSearchTextField.textColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        foodSearchBar.layer.borderColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)).cgColor
        foodSearchBar.layer.borderWidth = 2
        foodSearchBar.layer.cornerRadius = 30.0
        foodSearchBar.clipsToBounds = true
        
        //MARK: Make resultsTableView hidden and start spinner because waiting data to fetch
        resultsTableView.isHidden = true
        resultsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        resultsTableView.backgroundColor = .clear
        
        drawGradientEffect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if onlyOnce{
        spinner.isHidden = false
        spinner.startAnimating()
            getSearchedDataWith(paramater: searchParameter ?? "")
            onlyOnce = false
        }
        
    }
    
    func drawGradientEffect(){
        let animatedGradient = AnimatedGradientView(frame: view.bounds)
        animatedGradient.direction = .up
        animatedGradient.animationValues = [(colors: ["#283048", "#283048"], .up, .axial),//Dark gray to gray
                                            (colors: ["#757F9A", "#D7DDE8"], .right, .axial),//Gray to light gray
                                            (colors: ["#73C8A9", "#373B44"], .down, .axial),
                                            (colors: ["#283048", "#283048"], .left, .axial)]
        //self.hideNavigationBar()
        view.addSubview(animatedGradient)
        view.sendSubviewToBack(animatedGradient)
    }
    
    func getSearchedDataWith(paramater p:String){
        if p != "", let p = p.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            
            
           NetworkManager.shared.getFoodResults(for: p) { [weak self] result in
                
                switch result{
                case .success(let returnValue):
                    self?.searchResults = returnValue
                    DispatchQueue.main.async {
                        
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
                foodDetailVC.food = selectedFood
            }
        }
        else if segue.identifier == "myBasket"{
            
            
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as! FoodResultsTableViewCell
        
        //MARK: Animate created cell
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
        
        //MARK: Assign cell label the returned API results.
        cell.foodDescriptionLabel.text = searchResults?.foods[indexPath.row].description
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedFood = searchResults?.foods[indexPath.row]
        performSegue(withIdentifier: "foodDetails", sender: nil)
        
    }
    
    
}

extension FoodResultsViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchedText = searchBar.text
        
        if  let myText = searchedText, myText.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            
            getSearchedDataWith(paramater: myText)

        }
 
        searchBar.text = ""
        dismissKeyboard()
    }
}


