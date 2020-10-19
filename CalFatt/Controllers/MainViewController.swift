//
//  MainViewController.swift
//  CalFatt
//
//  Created by Anil on 10/17/20.
//

import UIKit
import Firebase
import AnimatedGradientView

class MainViewController: UIViewController {
    
    var onlyOnce:Bool = true
    var value:String?
    
    @IBOutlet weak var searchFoodLabel: UILabel!
    @IBOutlet weak var searchTextField: customUITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NetworkService.shared.getApiKeyFromFirebase()
        
        
        
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if onlyOnce{
            updateUI()
        }
    }
    
    
    
    
    func updateUI(){
        searchFoodLabel.alpha = 0
        searchTextField.alpha = 0
        searchButton.alpha = 0
        searchFoodLabel.textColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        searchFoodLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 60)!
        
        let animatedGradient = AnimatedGradientView(frame: view.bounds)
        animatedGradient.direction = .up
        animatedGradient.animationValues = [(colors: ["#2BC0E4", "#EAECC6"], .up, .axial),
                                            (colors: ["#ffffcc", "#a4f9dd"], .right, .axial),
                                            (colors: ["#003973", "#E5E5BE"], .down, .axial),
                                            (colors: ["#99ff99", "#ccccff"], .left, .axial)]
        self.hideNavigationBar()
        view.addSubview(animatedGradient)
        view.sendSubviewToBack(animatedGradient)
        
        
        UIView.animate(withDuration: 3, delay: 0.5, options: .curveEaseInOut, animations: {
            self.searchFoodLabel.alpha = 1.0
            self.searchTextField.alpha = 1.0
            self.searchButton.alpha = 1.0
            
            self.searchFoodLabel.frame = CGRect(x:  self.searchFoodLabel.frame.origin.x, y: self.searchFoodLabel.frame.origin.y + 100, width: self.searchFoodLabel.frame.size.width, height: self.searchFoodLabel.frame.size.height)
            self.searchTextField.frame = CGRect(x:  self.searchTextField.frame.origin.x, y: self.searchTextField.frame.origin.y - 100, width: self.searchTextField.frame.size.width, height: self.searchTextField.frame.size.height)
            self.searchButton.frame = CGRect(x:  self.searchButton.frame.origin.x, y: self.searchButton.frame.origin.y - 100, width: self.searchButton.frame.size.width, height: self.searchButton.frame.size.height)
            
        }, completion: nil)
        
        onlyOnce = false
    }
    
    
    @IBAction func searchTextChange(_ sender: Any) {
        searchButton.shake(count: 2, for: 0.2, withTranslation: 5)
    }
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        
        if searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            searchTextField.shake()
            searchTextField.text = ""
           
        }else{
            dismissKeyboard()
            performSegue(withIdentifier: "searchFoodResults", sender: nil)
        }
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchFoodResults" {
            if let searchFoodVC = segue.destination as? SearchFoodViewController {
                searchFoodVC.searchParameter = searchTextField.text
            }
        }
    }
    
    
}

extension UIViewController{
    
    func hideNavigationBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.view.backgroundColor = UIColor.clear
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 5.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func shake(count : Float = 3,for duration : TimeInterval = 0.5,withTranslation translation : Float = 5) {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
    
}

