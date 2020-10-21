//
//  FoodDescriptionViewController.swift
//  CalFatt
//
//  Created by Anil on 10/21/20.
//

import UIKit

class FoodDetailViewController: UIViewController {
    
    
    
    @IBOutlet weak var proteinProgressBar: CustomProgressBar!
    
    var foodId:Int?
    
    var counter:Float = 0.0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print(foodId ?? 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateDelay), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func updateDelay() {
        if (counter == 0.4) {
            timer?.invalidate()
            timer = nil

           
        } else {
            counter = counter + 0.1
            proteinProgressBar.progress = CGFloat(counter)
        }
    }
    
    
}
