//
//  FoodDescriptionViewController.swift
//  CalFatt
//
//  Created by Anil on 10/21/20.
//

import UIKit
import AnimatedGradientView

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
    
    var timer: Timer?
    var protein: Double?
    var fat: Double?
    var carb: Double?
    var alchol: Double?
    var total: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodDetailTableView.delegate = self
        foodDetailTableView.dataSource = self
        
        prepareViewDidLoad()
        
    }
    
    func prepareViewDidLoad(){
        
        
        foodDetailTableView.backgroundColor = .clear
        foodDetailView.backgroundColor = .clear
        
        foodDetailView.isHidden = true
        foodDetailView.alpha = 0

        spinner.isHidden = false
    
        
        proteinProgressBar.changeColorFor(red: 169, green: 255, blue: 23)
        fatProgressBar.changeColorFor(red: 255, green: 192, blue: 55)
        carbProgressBar.changeColorFor(red: 109, green: 100, blue: 250)
        alcholProgressBar.changeColorFor(red: 188, green: 0, blue: 255)
        
        changeProgressBarUIHiddenFor(label: proteinLabel, percentageLabel: proteinPercentageLabel, customProgressBar: proteinProgressBar)
        changeProgressBarUIHiddenFor(label: fatLabel, percentageLabel: fatPercentageLabel, customProgressBar: fatProgressBar)
        changeProgressBarUIHiddenFor(label: carbLabel, percentageLabel: carbPercentageLabel, customProgressBar: carbProgressBar)
        changeProgressBarUIHiddenFor(label: alcholLabel, percentageLabel: alcholPercentageLabel, customProgressBar: alcholProgressBar)

        
        configureNavigationTitle(food?.description ?? "Something Went Wrong")
        
        drawGradientEffect()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            spinner.startAnimating()
            fetchFoodDetail()

    }
    
    func fetchFoodDetail(){
        
        NetworkManager.shared.getFoodDescriptionBy(foodId: food?.fdcId ?? 0) { [weak self] result in
            
            switch result{
            case .success(let returnValue):
                
                self?.foodDescription = returnValue
                self?.getProgressBarData()
                self?.calculateTotalAndMax()
                DispatchQueue.main.async {
                    
                    self?.spinner.stopAnimating()
                    self?.spinner.isHidden = true
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        self?.updateUI()
                        self?.foodDetailTableView.reloadData()
                    }, completion: { finished in
                        
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                            self?.foodDetailView.isHidden = false
                            self?.foodDetailView.alpha = 1
                        }, completion:{finished in
                            self?.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self!, selector: #selector(self?.updateDelay), userInfo: nil, repeats: true)
                        })
                        
                    })
                    
                    
                }
            case .failure(let error):
                print(error)
            }
            
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
    
    func changeProgressBarUIFor(label myLabel: UILabel, percentageLabel myPercentageLabel: UILabel, customProgressBar myCustomProgressBar: CustomProgressBar, text myText:String, percentage myPercantage:String, progressBar myProgressBar:CGFloat ){
        
        myLabel.textColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        myLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17)!
        myLabel.text = myText
        
        myPercentageLabel.text = myPercantage
        myPercentageLabel.textColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        myPercentageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17)!
        
        myCustomProgressBar.progress = myProgressBar
        
        
    }
    
    func changeProgressBarUIHiddenFor(label myLabel: UILabel, percentageLabel myPercentageLabel: UILabel, customProgressBar myCustomProgressBar: CustomProgressBar){
        
        myLabel.isHidden = !myLabel.isHidden
        myPercentageLabel.isHidden = !myPercentageLabel.isHidden
        myCustomProgressBar.isHidden = !myCustomProgressBar.isHidden
        
    }
    
    
    func updateUI(){
        
        if let myProtein = protein, let myFat = fat, let myCarb = carb, let myTotal = total{
            
            if !myProtein.isZero{
                
                changeProgressBarUIFor(label: proteinLabel, percentageLabel: proteinPercentageLabel, customProgressBar: proteinProgressBar, text: "Protein: \(myProtein)", percentage: "\(String(format: "%.02f", (myProtein/myTotal)*100))%", progressBar: CGFloat(0))

                changeProgressBarUIHiddenFor(label: proteinLabel, percentageLabel: proteinPercentageLabel, customProgressBar: proteinProgressBar)
            }
            
            if !myFat.isZero{
                
                changeProgressBarUIFor(label: fatLabel, percentageLabel: fatPercentageLabel, customProgressBar: fatProgressBar, text: "Fat: \(myFat)", percentage: "\(String(format: "%.02f", (myFat/myTotal)*100))%", progressBar: CGFloat(0))

                changeProgressBarUIHiddenFor(label: fatLabel, percentageLabel: fatPercentageLabel, customProgressBar: fatProgressBar)
            }
            
            if !myCarb.isZero{
                
                changeProgressBarUIFor(label: carbLabel, percentageLabel: carbPercentageLabel, customProgressBar: carbProgressBar, text: "Carbohydrate: \(myCarb)", percentage: "\(String(format: "%.02f", (myCarb/myTotal)*100))%", progressBar: CGFloat(0))

                
                changeProgressBarUIHiddenFor(label: carbLabel, percentageLabel: carbPercentageLabel, customProgressBar: carbProgressBar)
                
            }
            
            if let myAlchol = alchol{
                
                if !myAlchol.isZero{
                    
                    changeProgressBarUIFor(label: alcholLabel, percentageLabel: alcholPercentageLabel, customProgressBar: alcholProgressBar, text: "Alchol: \(myAlchol)", percentage: "\(String(format: "%.02f", (myAlchol/myTotal)*100))%", progressBar: CGFloat(0))
            
                    changeProgressBarUIHiddenFor(label: alcholLabel, percentageLabel: alcholPercentageLabel, customProgressBar: alcholProgressBar)

                }
            }
            
        }
    }
    
    func calculateTotalAndMax(){
        
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
                    protein = food.amount! * 4
                case "Total lipid (fat)":
                    fat = food.amount! * 9
                case "Carbohydrate, by difference":
                    carb = food.amount! * 4
                case "Alcohol, ethyl":
                    alchol  = food.amount! * 7
                default:
                    break
                }
            }
        }
    }
    
    @objc func updateDelay() {
        
        if let myFat = fat, let myProtein = protein, let myCarb = carb, let myTotal = total{
            
            if !myProtein.isZero{
                proteinProgressBar.progress = CGFloat(myProtein/myTotal)
            }
            if !myFat.isZero{
                fatProgressBar.progress = CGFloat(myFat/myTotal)
            }
            if !myCarb.isZero{
                carbProgressBar.progress = CGFloat(myCarb/myTotal)
            }
            if let myAlchol = alchol, !myAlchol.isZero{
                
                    alcholProgressBar.progress = CGFloat(myAlchol/myTotal)
            }

            timer?.invalidate()
            
        }

        
    }
    
    private func configureNavigationTitle(_ title: String) {
        let tempLabel = UILabel()
        tempLabel.textColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 64)!
        tempLabel.text = title
        
        if tempLabel.intrinsicContentSize.width > UIScreen.main.bounds.width - 30 {
            var currentTextSize: CGFloat = 34
            for _ in 1 ... 34 {
                currentTextSize -= 1
                tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: currentTextSize)!
                if tempLabel.intrinsicContentSize.width < UIScreen.main.bounds.width - 30 {
                    break
                }
            }
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: currentTextSize)!, NSAttributedString.Key.foregroundColor: UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))]
        }
        self.title = title
    }
    
    
}

extension FoodDetailViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension FoodDetailViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodDescription?.foodNutrients.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodDetailsCell", for: indexPath) as! FoodDetailTableViewCell
        
        //MARK: Animate created cell
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
        
        //MARK: Assign cell label the returned API results.
        cell.foodNutrientName.text = foodDescription?.foodNutrients[indexPath.row].nutrient.name
        cell.foodNutrientWeight.text = "\(foodDescription?.foodNutrients[indexPath.row].amount ?? 0)\(foodDescription?.foodNutrients[indexPath.row].nutrient.nutrientUnit.name ?? " ")"
        
        return cell
        
    }
    
    
    
}


