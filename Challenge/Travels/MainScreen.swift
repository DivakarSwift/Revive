//
//  MainScreen.swift
//  Challenge
//
//  Created by Alessandro Graziani on 12/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var stackView: UIStackView!
    

    var array: [UIImage] = []
    
    var currentPage: Int = 0 {
        didSet {
            if(self.currentPage < DataManager.shared.travelStorage.count) && (self.currentPage >= 0) {
                updatePage()
            }
            
        }
    }
    
    func updatePage() {
        let travel = DataManager.shared.travelStorage[self.currentPage]
        self.placeLabel.text = travel.place
        self.dateLabel.text = travel.date
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    fileprivate func setupLayout() {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 30)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Travels", style: .plain, target: nil, action: nil)
        self.collectionView.backgroundColor = .clear
        
        self.setupLayout()
        
        self.currentPage = 0
        
        DataManager.shared.collectionViewContr = self
        
        self.collectionView.isHidden = true
        self.stackView.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.transition(with: collectionView, duration: 1, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
            self.collectionView.isHidden = false
        }, completion: nil)
        UIView.transition(with: stackView, duration: 1, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
            self.stackView.isHidden = false
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return DataManager.shared.travelStorage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! cellTravel
        
        let travel = DataManager.shared.travelStorage[indexPath.row]
        
        cell.travel = DataManager.shared.travelStorage[indexPath.row]
        cell.indexOfTravel = DataManager.shared.indexOfTravel(travel: travel)
        
        
        cell.imageViewCell.image = DataManager.shared.loadFromPath(fileName: travel.travelBackground)
        
    
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    
    
    // MARK: - Navigation
    
    @IBAction func segueAddController(_ sender: UIButton) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromTop
        self.view.window!.layer.add(transition, forKey: nil)
        performSegue(withIdentifier: "segueAdd", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "memory" {
            let memoryVC = segue.destination as! MemoryViewController
            let cell = sender as! cellTravel
            memoryVC.indexOfTravel = cell.indexOfTravel
            memoryVC.date = cell.travel.date
        }
    }
    

}

