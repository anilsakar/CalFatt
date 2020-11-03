//
//  FoodCalculateViewController.swift
//  CalFatt
//
//  Created by Anil on 11/2/20.
//

import UIKit
import AnimatedGradientView

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
        
        drawGradientEffect()
        
        foodSegmentedControl.addTarget(self, action: #selector(FoodCalculateViewController.segmentedControlValueChanged(segment:)), for:.valueChanged)
        foodSegmentedControl.alpha = 0
        
        foodView.backgroundColor = UIColor(red: 73/255, green: 99/255, blue: 135/255, alpha: 0.2)
        foodView.layer.masksToBounds = true;
        foodView.layer.cornerRadius = 20;
        
        foodImageView.alpha = 0
        foodImageView.clipsToBounds = true
        foodImageView.layer.cornerRadius = 20
        
        foodTextView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        
        foodLabel.text = "Please enter your weight"
        foodLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        foodLabel.textColor = UIColor(cgColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    func drawGradientEffect(){
        let animatedGradient = AnimatedGradientView(frame: view.bounds)
        animatedGradient.direction = .up
        animatedGradient.animationValues = [(colors: ["#757F9A", "#D6A4A4"], .up, .axial),//Dark gray to gray
                                            (colors: ["#757F9A", "#D7DDE8"], .right, .axial),//Gray to light gray
                                            (colors: ["#73C8A9", "#373B44"], .down, .axial),
                                            (colors: ["757F9A", "#ACBB78"], .left, .axial)]
        //self.hideNavigationBar()
        view.addSubview(animatedGradient)
        view.sendSubviewToBack(animatedGradient)
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
        
        UIView.transition(with: (foodView)!, duration: 1.0, options: .transitionFlipFromRight, animations: {})
        
        if segment.selectedSegmentIndex == 0 {
            showCalculatedInformationsBy(imageName: "running", totalCalories: totalCalories, met: 8)
        }else  if segment.selectedSegmentIndex == 1 {
            showCalculatedInformationsBy(imageName: "cycling", totalCalories: totalCalories, met: 11)
        }else  if segment.selectedSegmentIndex == 2 {
            showCalculatedInformationsBy(imageName: "swimming", totalCalories: totalCalories, met: 6)
        }else  if segment.selectedSegmentIndex == 3 {
            showCalculatedInformationsBy(imageName: "walking", totalCalories: totalCalories, met: 7)
        }
        
    }
    
    
    func showCalculatedInformationsBy(imageName name :String, totalCalories calories:Double, met:Double){
        
        oneMinBurnedCalories = 1 * (met * 3.5 * (weight)!) / 200
        
        foodImageView.image = UIImage(named: name)
        foodLabel.text = "In your basket you have \(String(describing: fetchedFoods.count)) food. Their total\nProtein \(String(format: "%.02f", (totalProtein * 4)))\nFat \(String(format: "%.02f", (totalFat * 9)))\nCarbonhydrate \(String(format: "%.02f", (totalCarb * 4)))\nAlchol \(String(format: "%.02f", (totalAlchol * 7))).\nBy running you can burn these foods in \(String(format: "%.02f", (calories / oneMinBurnedCalories))) minutes"
        
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
                    self?.oneMinBurnedCalories = 1 * (8 * 3.5 * (self?.weight)!) / 200
                    
                    
                    
                    DispatchQueue.main.async {
                        
                        UIView.transition(with: (self?.foodView)!, duration: 1.0, options: .transitionFlipFromRight, animations: {
                            
                            self?.foodImageView.alpha = 1
                            print(self!.totalCalories)
                            print(self!.oneMinBurnedCalories)
                            self?.showCalculatedInformationsBy(imageName: "running", totalCalories: self!.totalCalories, met: 8)
                        })
                        
                        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
                            self?.foodSegmentedControl.alpha = 1
                        }, completion:nil)
                        
                        
                    }
                case .failure(let error):
                    print(error)
                }
                
            }
            
            
        }
        
        ids = ""
        dismissKeyboard()

        
    }
    
    
    
}
