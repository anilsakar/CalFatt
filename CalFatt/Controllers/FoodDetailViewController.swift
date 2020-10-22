//
//  FoodDescriptionViewController.swift
//  CalFatt
//
//  Created by Anil on 10/21/20.
//

import UIKit

class FoodDetailViewController: UIViewController {
    
    
    //MARK: Protein related fields
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var proteinPercentageLabel: UILabel!
    @IBOutlet weak var proteinProgressBar: CustomProgressBar!
    
    //MARK: Fat related fields
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var fatPercentageLabel: UILabel!
    @IBOutlet weak var fatProgressBar: CustomProgressBar!
    
    //MARK: Carbonhydrate related fields
    @IBOutlet weak var carbLabel: UILabel!
    @IBOutlet weak var carbPercentageLabel: UILabel!
    @IBOutlet weak var carbProgressBar: CustomProgressBar!
    
    //MARK: Alchol related fields
    @IBOutlet weak var alcholLabel: UILabel!
    @IBOutlet weak var alcholPercentageLabel: UILabel!
    @IBOutlet weak var alcholProgressBar: CustomProgressBar!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var foodDetailView: UIView!
    @IBOutlet weak var foodDetailTableView: UITableView!
    
    var food:Foods?
    var foodDescription: FoodDescription?
    
    
    var counter:Float = 0.0
    var timer: Timer?
    var protein: Double?
    var fat: Double?
    var carb: Double?
    var alchol: Double?
    var total: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //foodDetailTableView.delegate = self
        //foodDetailTableView.dataSource = self
        
        foodDetailView.isHidden = true
        foodDetailView.alpha = 0
        
        proteinLabel.isHidden = true
        proteinPercentageLabel.isHidden = true
        proteinProgressBar.isHidden = true
        
        fatLabel.isHidden = true
        fatPercentageLabel.isHidden = true
        fatProgressBar.isHidden = true
        
        carbLabel.isHidden = true
        carbPercentageLabel.isHidden = true
        carbProgressBar.isHidden = true
        
        
        alcholLabel.isHidden = true
        alcholPercentageLabel.isHidden = true
        alcholProgressBar.isHidden = true
        
        spinner.isHidden = false
        
        configureNavigationTitle(food?.description ?? "Something Went Wrong")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateDelay), userInfo: nil, repeats: true)
        
        
        spinner.startAnimating()
        
        
        NetworkManager.shared.getFoodDescriptionBy(foodId: food?.fdcId ?? 0) { [weak self] result in
            
            switch result{
            case .success(let returnValue):
                
                self?.foodDescription = returnValue
                self?.getProgressBarData()
                self?.calculateTotal()
                DispatchQueue.main.async {
                    
                    self?.spinner.stopAnimating()
                    self?.spinner.isHidden = true
                    
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
                        self?.updateUIAfterAnimationCompletion()
                    }, completion: { finished in
                        
                        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
                            self?.foodDetailView.isHidden = false
                            self?.foodDetailView.alpha = 1
                        }, completion:nil)
                        
                    })
                    
                    
                }
            case .failure(let error):
                print(error)
            }
            
        }
        
        
    }
    
    
    
    func updateUIAfterAnimationCompletion(){
        
        if let myProtein = protein, let myFat = fat, let myCarb = carb, let myTotal = total{
            
            if !myProtein.isZero{
                
                proteinLabel.text = "Protein: \(myProtein)"
                proteinPercentageLabel.text = "\((myProtein/myTotal)*100)%"
                proteinProgressBar.progress = CGFloat(myProtein/myTotal)
                
                proteinLabel.isHidden = false
                proteinPercentageLabel.isHidden = false
                proteinProgressBar.isHidden = false
                
            }
            
            if !myFat.isZero{
                
                fatLabel.text = "Fat: \(myFat)"
                fatPercentageLabel.text = "\((myFat/myTotal)*100)%"
                fatProgressBar.progress = CGFloat(myFat/myTotal)
                
                fatLabel.isHidden = false
                fatPercentageLabel.isHidden = false
                fatProgressBar.isHidden = false
            }
            
            if !myCarb.isZero{
                
                carbLabel.text = "Carbohydrate: \(myCarb)"
                carbPercentageLabel.text = "\((myCarb/myTotal)*100)%"
                carbProgressBar.progress = CGFloat(myCarb/myTotal)
                
                carbLabel.isHidden = false
                carbPercentageLabel.isHidden = false
                carbProgressBar.isHidden = false
            }
            
            if let myAlchol = alchol{
                
                if !myAlchol.isZero{
                    
                    alcholLabel.text = "Alchol: \(myAlchol)"
                    alcholPercentageLabel.text = "\((myAlchol/myTotal)*100)%"
                    alcholProgressBar.progress = CGFloat(myAlchol/myTotal)
                    
                    
                    alcholLabel.isHidden = false
                    alcholPercentageLabel.isHidden = false
                    alcholProgressBar.isHidden = false
                }
            }
            
        }
    }
    
    func calculateTotal(){
        
        if let myFat = fat, let myProtein = protein, let myCarb = carb{
            
            if let myAlchol = alchol{
                total = myProtein + myFat + myCarb + myAlchol
            }else{
                
                total = myProtein + myFat + myCarb
            }
            
        }
        
        
    }
    
    func getProgressBarData(){
        
        if let myFood = foodDescription{
            
            for food in myFood.foodNutrients{
                
                switch food.nutrient.name {
                case "Protein":
                    protein = food.amount
                case "Total lipid (fat)":
                    fat = food.amount
                case "Carbohydrate, by difference":
                    carb = food.amount
                case "Alcohol, ethyl":
                    alchol  = food.amount
                default:
                    break
                }
            }
        }
    }
    
    @objc func updateDelay() {
        if (counter == 0.4) {
            timer?.invalidate()
            timer = nil
            
            
        } else {
            counter = counter + 0.1
            //proteinProgressBar.progress = CGFloat(counter)
        }
    }
    
    private func configureNavigationTitle(_ title: String) {
        let tempLabel = UILabel()
        tempLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        tempLabel.text = title
        
        if tempLabel.intrinsicContentSize.width > UIScreen.main.bounds.width - 30 {
            var currentTextSize: CGFloat = 34
            for _ in 1 ... 34 {
                currentTextSize -= 1
                tempLabel.font = UIFont.systemFont(ofSize: currentTextSize, weight: .bold)
                if tempLabel.intrinsicContentSize.width < UIScreen.main.bounds.width - 30 {
                    break
                }
            }
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: currentTextSize, weight: .bold)]
        }
        self.title = title
    }
    
    
}


