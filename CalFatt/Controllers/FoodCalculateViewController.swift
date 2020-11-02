//
//  FoodCalculateViewController.swift
//  CalFatt
//
//  Created by Anil on 11/2/20.
//

import UIKit

class FoodCalculateViewController: UIViewController {
    
    
    @IBOutlet weak var foodView: UIView!
    @IBOutlet weak var foodTextView: CustomUITextField!
    @IBOutlet weak var foodCalculateButton: UIButton!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var foodSegmentedControl: UISegmentedControl!
    
    var weight:Double?
    var ids:String = ""
    var fetchedFoods:[FoodDescription] = []
    var totalProtein:Double = 0
    var totalFat:Double = 0
    var totalCarb:Double = 0
    var totalAlchol:Double = 0
    var totalCalories:Double = 0
    var oneMinBurnedCalories:Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        foodSegmentedControl.addTarget(self, action: #selector(FoodCalculateViewController.segmentedControlValueChanged(segment:)), for:.valueChanged)
        
        foodView.backgroundColor = .clear
        //foodImageView.isHidden = true
        //foodSegmentedControl.isHidden = true
    }
    
    func getTotalResult(for food:FoodDescription){
            
        for myFood in food.foodNutrients{
                
                switch myFood.nutrient.name {
                case "Protein":
                    totalProtein += myFood.amount ?? 0
                case "Total lipid (fat)":
                    totalFat += myFood.amount ?? 0
                case "Carbohydrate, by difference":
                    totalCarb += myFood.amount ?? 0
                case "Alcohol, ethyl":
                    totalAlchol += myFood.amount ?? 0
                default:
                    break
                }
        }
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            print("0")
        }else  if segment.selectedSegmentIndex == 1 {
            print("1")
        }else  if segment.selectedSegmentIndex == 2 {
            print("2")
        }else  if segment.selectedSegmentIndex == 3 {
            print("3")
        }
       
    }
    
    
    
    
    @IBAction func calculateButtonAction(_ sender: Any) {
        
        if foodTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            weight = Double(foodTextView.text!)
            for basket in Basket.shared.getBasket(){
                ids = ids + "\(basket.fdcId),"
            }
            
            NetworkManager.shared.getFoodDescriptionsBy(foodIds: ids) { [weak self] result in
                
                switch result{
                case .success(let returnValue):
                    self?.fetchedFoods = returnValue
                    for fetchedFood in self!.fetchedFoods{
                        self?.getTotalResult(for: fetchedFood)
                    }
                    
                    self?.totalCalories = ((self?.totalProtein)! * 4) + ((self?.totalFat)! * 9) + ((self?.totalCarb)! * 4)  + ((self?.totalAlchol)! * 7)
                    self?.oneMinBurnedCalories = 1 * (11 * 3.5 * Double((self?.foodTextView.text)!)!) / 200
                    
                    
                    
                    DispatchQueue.main.async {
                        
                        self?.foodImageView.image = UIImage(named: "running")
                        self?.foodLabel.text = "In you basket you have \(self?.fetchedFoods.count) food. Their total protein \(self!.totalProtein * 4), fat \(self!.totalFat * 9), carbonhydrate \(self!.totalCarb * 4) and alchol \(self!.totalAlchol). By running you can burn these foods in \(self!.totalCalories / self!.oneMinBurnedCalories)"
                        
                        
                    }
                case .failure(let error):
                    print(error)
                }
                
            }

            
        }
        
        dismissKeyboard()
        
        
       
        
    }
    


}
