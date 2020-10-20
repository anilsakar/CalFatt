//
//  SearchFoodViewController.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import UIKit
import AnimatedGradientView

class ResultFoodViewController: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var searchParameter: String?
    var searchResults: Search?
    var basket: [Foods] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        //MARK: Make resultsTableView hidden and start spinner because waiting data to fetch
        resultsTableView.isHidden = true
        spinner.startAnimating()
        
        getSearchedData()
        drawGradientEffect()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            
            NetworkService.shared.getFoodResults(for: str) { [weak self] result in
                
                switch result{
                case .success(let returnValue):
                    self?.searchResults = returnValue
                    DispatchQueue.main.async {
                        
                        self?.resultsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
                        self?.resultsTableView.backgroundColor = .clear
                        self?.resultsTableView.reloadData()
                        self?.resultsTableView.isHidden = false
                        
                        self?.spinner.removeFromSuperview()
                    }
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }
    
    func addToBasketAction(at indexpath:IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .normal, title: "Add To Basket") { (action, view, completion) in
            
            if let food = self.searchResults?.foods[indexpath.row]{
                self.basket.append(food)
                self.searchResults?.foods.remove(at: indexpath.row)
                self.resultsTableView.deleteRows(at: [indexpath], with: .fade)
                print(self.basket.count)
                completion(true)
            }
            
        }
        action.image = UIImage(systemName: "square.and.arrow.down")
        action.backgroundColor = .darkGray
        
        return action
        
    }
    

    
}

extension ResultFoodViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension ResultFoodViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults?.foods.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let addToBasket = addToBasketAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [addToBasket])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as! ResultsTableViewCell
        
        //MARK: Cell UI options.
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        //MARK: Cells view UI options.
        cell.cellView.backgroundColor = UIColor(red: 73/255, green: 99/255, blue: 135/255, alpha: 0.2)
        cell.cellView.layer.masksToBounds = true;
        cell.cellView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        cell.cellView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 40.0)
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
        
        //MARK: Cells label UI options.
        cell.foodDescriptionLabel.textColor = UIColor(cgColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        cell.foodDescriptionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)!
       
        //MARK: Assign cell label the returned API results.
        cell.foodDescriptionLabel.text = searchResults?.foods[indexPath.row].description
        
        return cell
        
    }
    
    
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

