//
//  cellTravel.swift
//  Challenge
//
//  Created by Alessandro Graziani on 12/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit

class cellTravel: UICollectionViewCell {
    
    @IBOutlet var imageViewCell: UIImageView!
    
    var travel: TravelModel!
    var indexOfTravel: Int!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = UPCarouselFlowLayout().itemSize.width / 2
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        longPress.minimumPressDuration = 0.7
        self.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
        let alert = UIAlertController(title: "Remove Travel", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            
            DataManager.shared.removeTravel(place: self.travel.place)
            
            DataManager.shared.collectionViewContr.updatePage()
            DataManager.shared.collectionViewContr.collectionView.reloadData()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
       DataManager.shared.collectionViewContr.present(alert, animated: true, completion: nil)
    }
    
    
}
