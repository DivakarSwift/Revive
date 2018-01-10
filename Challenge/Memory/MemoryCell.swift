//
//  MemoryCell.swift
//  Challenge
//
//  Created by Alessandro Graziani on 17/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import AVFoundation

class MemoryCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var labelCell: UILabel!
    @IBOutlet var blur: UIVisualEffectView!
    @IBOutlet var videoView: UIView!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        longPress.minimumPressDuration = 0.7
        self.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
        let alert = UIAlertController(title: "Remove Memory", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            DataManager.shared.removeMemory(indexOfTravel: DataManager.shared.MemoryViewContr.indexOfTravel, memoryName: self.labelCell.text!)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DataManager.shared.MemoryViewContr.present(alert, animated: true, completion: nil)
    }
    
}
