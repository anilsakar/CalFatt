//
//  FoodBasketViewController.swift
//  CalFatt
//
//  Created by Anil on 10/24/20.
//

import UIKit
import AnimatedGradientView

class FoodBasketViewController: UIViewController {
    
    
    @IBOutlet weak var basketCollectionView: UICollectionView!
    @IBOutlet weak var trashImageView: UIImageView!
    @IBOutlet weak var deleteCollectionView: UICollectionView!
    
    var selectedFood:Foods?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        basketCollectionView.dragInteractionEnabled = true
        basketCollectionView.delegate = self
        basketCollectionView.dataSource = self
        basketCollectionView.dragDelegate = self
        basketCollectionView.dropDelegate = self
        deleteCollectionView.dropDelegate = self
        
        basketCollectionView.backgroundColor = .clear
        deleteCollectionView.backgroundColor = .clear
        
        basketCollectionView.alpha = 0
        trashImageView.alpha = 0
        
        drawGradientEffect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.basketCollectionView.reloadData()
            self.basketCollectionView.alpha = 1
        }, completion: nil)
        
        
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
    
    //MARK: Private Methods
    
    /// This method moves a cell from source indexPath to destination indexPath within the same collection view. It works for only 1 item. If multiple items selected, no reordering happens.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0)
            {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            collectionView.performBatchUpdates({
                
                
                let tempFood = Basket.shared.getFoodInsideOfBasket(at: sourceIndexPath.row)
                
                Basket.shared.deleteFromBasket(at: sourceIndexPath.row)
                Basket.shared.insertToBasket(tempFood, at: dIndexPath.row)
                
                //self.items1.remove(at: sourceIndexPath.row)
                //self.items1.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }
    
    /// This method copies a cell from source indexPath in 1st collection view to destination indexPath in 2nd collection view. It works for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func removeItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        collectionView.performBatchUpdates({
            
            for item in coordinator.items
            {
                guard let identifier = item.dragItem.localObject as? String else {
                    return
                }
                
                if let index = Basket.shared.indexForIdentifier(identifier: identifier){
                    let indexPath = IndexPath(row: index, section: 0)
                    //items1.remove(at: index)
                    Basket.shared.deleteFromBasket(at: index)
                    basketCollectionView.deleteItems(at: [indexPath])
                    
                    
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "basketToFoodDetail" {
            if let foodDetailVC = segue.destination as? FoodDetailViewController{
                foodDetailVC.food = selectedFood
            }
        }
    }


}

extension FoodBasketViewController: UICollectionViewDelegate{
    
    
    
}

extension FoodBasketViewController:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return collectionView == self.basketCollectionView ? Basket.shared.basketTotal() : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BasketCollectionViewCell
        
        cell.foodDescriptionLabel.text = Basket.shared.getFoodDescrition(at: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedFood = Basket.shared.getFoodInsideOfBasket(at: indexPath.row)
        performSegue(withIdentifier: "basketToFoodDetail", sender: nil)
        
    }
    
    
}

extension FoodBasketViewController:UICollectionViewDragDelegate{
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        //let item = self.items1[indexPath.row]
        let item = Basket.shared.getFoodDescrition(at: indexPath.row)
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
    {
        //let item = self.items1[indexPath.row]
        let item = Basket.shared.getFoodDescrition(at: indexPath.row)
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
}

extension FoodBasketViewController:UICollectionViewDropDelegate{
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
    {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if collectionView === self.basketCollectionView
        {
            return collectionView.hasActiveDrag ?
                UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath) :
                UICollectionViewDropProposal(operation: .forbidden)
        }
        else
        {
            if collectionView.hasActiveDrag{
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            
            
            for item in session.items
            {
                guard let _ = item.localObject as? String else {
                    return UICollectionViewDropProposal(operation: .forbidden)
                }
                
            }
        
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.trashImageView.alpha = 1
                self.trashImageView.shake(count: 3, for: 1, withTranslation: 5)
            }, completion:nil)
            
            
            return  UICollectionViewDropProposal(operation: .move, intent: .unspecified)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath
        {
            destinationIndexPath = indexPath
        }
        else
        {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        if coordinator.proposal.operation == .move{
            if coordinator.proposal.intent == .insertAtDestinationIndexPath{
                self.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
            }
            else{
                
                self.removeItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            }
        }
        print(Basket.shared.basket)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.trashImageView.alpha = 0
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.trashImageView.alpha = 0
        }, completion: nil)
    }
    
}

extension FoodBasketViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let collectionViewWidth = collectionView.bounds.width
            return CGSize(width: collectionViewWidth/2, height: collectionViewWidth/2)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 20
        }
}
