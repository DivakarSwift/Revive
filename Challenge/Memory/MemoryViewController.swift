//
//  MemoryViewController.swift
//  Challenge
//
//  Created by Michele Finizio on 12/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

public var musicPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
public var playlist : MPMediaItemCollection? = nil
public var playing: Bool = false

class MemoryViewController: UIViewController {
    
    var indexOfTravel: Int!
    @IBOutlet var dateLabel: UILabel!
    var date: String!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var heightCollection: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.main.bounds.width == 834 {
            heightCollection.constant = 750
        }
        
        DataManager.shared.MemoryViewContr = self
        DataManager.shared.travelStorage[indexOfTravel].cells.shuffle()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        self.dateLabel.text = date
        
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        self.title = DataManager.shared.travelStorage[indexOfTravel].place
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.title, style: .plain, target: nil, action: nil)
    
        playButton.isEnabled = false
        nextButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        NotificationCenter.default.addObserver(self, selector: #selector(playAndPause(_:)), name: .UIApplicationWillEnterForeground, object: nil)

        playlist = PlaylistManager.shared.playlist
        if playlist != nil {
            musicPlayer.setQueue(with: playlist!)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        PlaylistManager.shared.playlist = playlist
        
        musicPlayer.stop()
        playing = false
        if playlist != nil {
            musicPlayer.setQueue(with: playlist!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        DataManager.shared.haveToReloadLayout = true
    }
    
    //   Add the music player
    
    @IBAction func playAndPause(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                sender.transform = .identity
            }, completion: { (_) in
                if playing == false {
                    musicPlayer.play()
                    sender.setImage(UIImage(named: "Pause"), for: .normal)
                    playing = true
                } else {
                    sender.setImage(UIImage(named: "Play"), for: .normal)
                    musicPlayer.pause()
                    playing = false
                }
            })
        }
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        musicPlayer.skipToNextItem()
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                sender.transform = .identity
            }, completion: { (_) in
                musicPlayer.skipToNextItem()
            })
        }
    }
    
    
    // Add the media picker to select specific music
    
    @IBAction func selectMusic(_ sender: UIButton) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func segueAddMedia(_ sender: UIBarButtonItem) {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromTop
        self.view.window!.layer.add(transition, forKey: nil)
        performSegue(withIdentifier: "segueNewMemory", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueNewMemory" {
            let addMediaVC = segue.destination as! NewMemoryViewController
            addMediaVC.indexOfTravel = self.indexOfTravel
        }
        
        if segue.identifier == "segueDetail" {
            if let myIndexPath = collectionView.indexPath(for: sender as! MemoryCell) {
                let memoryDetail = segue.destination as! MemoryDetail
                memoryDetail.indexOfTravel = self.indexOfTravel
                memoryDetail.memoryName = DataManager.shared.travelStorage[indexOfTravel].cells[myIndexPath.row].title
            }
        }
    }
 

}

// MARK - MediaPicker

extension MemoryViewController: MPMediaPickerControllerDelegate {

    
    // MARK: MediaPickerControllerDelegate
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        musicPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true)
        playlist = mediaItemCollection
        musicPlayer.repeatMode = .all
        
        self.playButton.isEnabled = true
        self.nextButton.isEnabled = true
        
        self.playAndPause(self.playButton)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }


    
}

extension MemoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return DataManager.shared.travelStorage[indexOfTravel].cells.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMemories", for: indexPath) as! MemoryCell
        
        
        let memoryForCell = DataManager.shared.travelStorage[indexOfTravel].cells[indexPath.row]
        
        cell.blur.isHidden = true
        
        switch memoryForCell.title {
        case "Funny":
            cell.imageView.image = #imageLiteral(resourceName: "squareFunny")
        case "Love":
            cell.imageView.image = #imageLiteral(resourceName: "squareLove")
        case "Great":
            cell.imageView.image = #imageLiteral(resourceName: "squareGreat")
        case "Sad":
            cell.imageView.image = #imageLiteral(resourceName: "squareSad")
        case "Secret":
            cell.imageView.image = #imageLiteral(resourceName: "squareSecret")
        case "Angry":
            cell.imageView.image = #imageLiteral(resourceName: "squareAngry")
        default:
            cell.blur.isHidden = false
            cell.labelCell.text = memoryForCell.title
            if memoryForCell.videos.count > 0 {
                cell.player = AVPlayer(url: memoryForCell.videos[0])
                cell.player.seek(to: kCMTimeZero)
                cell.playerLayer = AVPlayerLayer(player: cell.player)
                cell.playerLayer.frame = CGRect(x: 0, y: 0, width: 250, height: 114)
                cell.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                cell.videoView.layer.addSublayer(cell.playerLayer)
                cell.player.isMuted = true
                cell.player.play()
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                       object: nil,
                                                       queue: nil) {Notification in
                                                        cell.player.seek(to: kCMTimeZero)
                                                        cell.player.play()}
            } else {
             cell.imageView.image = DataManager.shared.loadFromPath(fileName: memoryForCell.photos[0])
            }
            
        }
        
        return cell
    }
    
    
}


//MARK: - PINTEREST LAYOUT DELEGATE
extension MemoryViewController: PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
    
        if indexPath.row == (DataManager.shared.travelStorage[indexOfTravel].cells.count - 1) {
            DataManager.shared.haveToReloadLayout = false
        }
        
        var widthEmotion = CGFloat(114)
        if UIScreen.main.bounds.width == 834 {
            widthEmotion = CGFloat(237)
        }
        switch DataManager.shared.travelStorage[indexOfTravel].cells[indexPath.row].title {
        case "Funny":
            return widthEmotion
        case "Love":
            return widthEmotion
        case "Great":
            return widthEmotion
        case "Sad":
            return widthEmotion
        case "Secret":
            return widthEmotion
        case "Angry":
            return widthEmotion
        default:
            var randomWidth: CGFloat = CGFloat(arc4random_uniform(120) + 130)
            if UIScreen.main.bounds.width == 834 {
                randomWidth = CGFloat(arc4random_uniform(180) + 250)
            }
//            let cell = collectionView.cellForItem(at: indexPath) as! MemoryCell
//            cell.playerLayer.frame = CGRect(x: 0, y: 0, width: randomWidth, height: 114)
            return randomWidth
        }
    }
}


extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
