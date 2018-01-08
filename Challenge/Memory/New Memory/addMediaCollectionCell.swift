//
//  addMediaCollectionCell.swift
//  Challenge
//
//  Created by Alessandro Graziani on 14/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit

class addMediaCollectionCell: UICollectionViewCell {

    @IBOutlet var imageViewForPhotoPicked: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 20
    }

}
