//
//  NewMemoryViewController.swift
//  Challenge
//
//  Created by Alessandro Graziani on 14/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class NewMemoryViewController: UIViewController, UITextFieldDelegate {
    
    // Which travel? i have the travel's index for the array of travels in DataManager
    var indexOfTravel: Int!
    var thisTravel: TravelModel!
    
    // Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var addMediaButtonOutlet: UIButton!
    @IBOutlet var emotionsButtons: [UIButton]!
    
    
    @IBOutlet var heighVideoView: NSLayoutConstraint!
    @IBOutlet var heightCollectionView: NSLayoutConstraint!
    

    var photoPickedFromGallery: [UIImage] = []
    var videoPickedFromGallery: URL!
    @IBOutlet var videoView: UIView!
    
    var rotellina: UIActivityIndicatorView!
    
    var player : AVPlayer!
    var playerLayer : AVPlayerLayer!
    var repeatVideo: Bool = true
    
    
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        thisTravel = DataManager.shared.travelStorage[indexOfTravel]
        
        // collection view delegate e data source
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? HorizontalAdaptingLayout {
            layout.delegate = self
        }
        
        // Galery view
        gallery = GalleryController()
        gallery.delegate = self

        // for each emoji button, add an action
        for emoji in emotionsButtons {
            emoji.addTarget(self, action: #selector(tapEmoji(sender:)), for: .touchUpInside)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIScreen.main.bounds.width == 834 || UIScreen.main.bounds.width == 1024 {
            self.heighVideoView.constant = 680
            self.heightCollectionView.constant = 680
        }
        
        // collection view e video view hiddet al load
        self.collectionView.isHidden = true
        self.videoView.isHidden = true
        self.videoView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if player != nil {
            repeatVideo = false
            player.pause()
            playerLayer.removeFromSuperlayer()
            player = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.returnKeyType = .done
        return textField.resignFirstResponder()
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        for button in emotionsButtons {
            button.setImage(nil, for: .normal)
            button.addTarget(self, action: #selector(tapEmoji(sender:)), for: .touchUpInside)
        }
    }
    
    
    @objc func tapEmoji(sender: UIButton) {
            for emoji in emotionsButtons {
                emoji.setImage(nil, for: .normal)
            }
            switch sender.tag {
            case 1:
                sender.setImage(UIImage(named: "😂"), for: .normal)
            case 2:
                sender.setImage(UIImage(named: "😍"), for: .normal)
            case 3:
                sender.setImage(UIImage(named: "😎"), for: .normal)
            case 4:
                sender.setImage(UIImage(named: "😢"), for: .normal)
            case 5:
                sender.setImage(UIImage(named: "🤫"), for: .normal)
            case 6:
                sender.setImage(UIImage(named: "🤬"), for: .normal)
            default:
                return
            }
    }
    
    @IBAction func addMediaButton(_ sender: UIButton) {
        textField.resignFirstResponder()
        self.present(gallery, animated: true, completion: nil)
    }
    
    
    // MARK - Get memory, emojy and media selected by user
    
    // observe memory title
    func getMemoryTitle() -> String {
        if textField.text != "" {
            return textField.text!
        } else {
            return "Failed"
        }
    }
    
    
    // Observer emoji tag
    func checkEmoji() -> String {
        var tagMedia = 0
        for emoji in emotionsButtons {
            if emoji.image(for: .normal) != nil {
                tagMedia = emoji.tag
            }
        }
        switch tagMedia {
        case 1:
            return "😂"
        case 2:
            return "😍"
        case 3:
            return "😎"
        case 4:
            return "😢"
        case 5:
            return "🤫"
        case 6:
            return "🤬"
        default:
            return ""
        }
    }
    
    // get an array with path of photos
    func pathPhotosPicked() -> [String] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var i = 0
        let filename = formatter.string(from: date)
        
        var paths : [String] = []
        for photos in self.photoPickedFromGallery {
            paths.append(DataManager.shared.getPath(image: photos, fileName: filename + String(i))!)
            i += 1
        }
        return paths
    }
    
    // Check Missing Tag, Media or Title
    func missingValue() -> Bool {
        var checkTag = 0
        for emoji in emotionsButtons {
            if emoji.image(for: .normal) == nil {
                checkTag += 1
            }
        }
        if checkTag == 6 {
            showAlert(withMessage: "If you are creating a new memory, you must choose an emotion for it")
            return true
        }
        
        if collectionView.isHidden && videoView.isHidden {
            showAlert(withMessage: "Insert photos or video to save")
            return true
        }
        
        if getMemoryTitle() == "Failed" {
            showAlert(withMessage: "Insert a new memory or choose an existing one")
            return true
        }
        
        return false
    }
    
    func showAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK - Save media into TravelStorage
    @IBAction func saveMedia(_ sender: UIBarButtonItem) {
        
        if !missingValue() {
            switch photoPickedFromGallery.count {
            case 0:
                print("DEBUG: stai per salvare video")
                DataManager.shared.addVideoToMemory(travel: thisTravel, memoryTitle: getMemoryTitle(), emoji: checkEmoji(), videoURL: videoPickedFromGallery)
            default:
                print("DEBUG: stai per salvare foto")
                print("DEBUG: quante foto? " + String(pathPhotosPicked().count))
                print("DEBUG: quale nome? " + getMemoryTitle())
                print("DEBUG: quale emoji? " + checkEmoji())
                print("DEBUG: in quale travel? " + thisTravel.place)
                DataManager.shared.addPhotoToMemory(travel: thisTravel, memoryTitle: getMemoryTitle(), emoji: checkEmoji(), photos: pathPhotosPicked())
            }
            print("DEBUG: \(DataManager.shared.travelStorage[indexOfTravel].cells.count) celle dopo il salvataggio")
            
            DataManager.shared.haveToReloadLayout = true
            DataManager.shared.travelStorage[indexOfTravel].cells.shuffle()
            DataManager.shared.MemoryViewContr.collectionView.reloadData()
            
            
            self.cancelButton()
        } else {
            return
        }
        
        
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem! = nil) {
        if player != nil {
            self.repeatVideo = false
            self.player.pause()
            self.playerLayer = nil
            self.player = nil
        }
        
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: false)
    }


}


extension NewMemoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, HorizontalAdaptingLayoutDelegate {
    
    // MARK - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photoPickedFromGallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMediaAdded", for: indexPath) as! addMediaCollectionCell
        
        cell.imageViewForPhotoPicked.image = photoPickedFromGallery[indexPath.row]
        
        rotellina.removeFromSuperview()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let image = photoPickedFromGallery[indexPath.row]
        let aspectRatio = image.size.width / image.size.height
        let cellWidth = self.collectionView.frame.size.height * aspectRatio
        return CGFloat(cellWidth)
    }

    
}

extension NewMemoryViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        Image.resolve(images: images) { (photosPicked) in
            for photo in photosPicked {
                self.photoPickedFromGallery.append(photo!)
                self.addMediaButtonOutlet.isHidden = true
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
            }
        }
        addMediaButtonOutlet.isHidden = true
        rotellina = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        rotellina.color = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        rotellina.center = addMediaButtonOutlet.center
        rotellina.startAnimating()
        self.view.addSubview(rotellina)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        
        addMediaButtonOutlet.isHidden = true
        rotellina = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        rotellina.color = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        rotellina.center = addMediaButtonOutlet.center
        rotellina.startAnimating()
        self.view.addSubview(rotellina)
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
        
                    self.player = AVPlayer(url: tempPath)
                    self.playerLayer = AVPlayerLayer(player: self.player)
                    self.player.seek(to: kCMTimeZero)
                    self.presentVideo(viewContainer: self.videoView, player: self.player, playerLayer: self.playerLayer)
                    
                    self.rotellina.removeFromSuperview()
    
                    self.videoView.isHidden = false
                    
                    self.videoPickedFromGallery = tempPath
                }
            }
        }
    }
    
    // funzione che presenta il video con oggetto AVPlayer
    func presentVideo(viewContainer: UIView, player: AVPlayer, playerLayer: AVPlayerLayer) {
        
        playerLayer.frame = CGRect(x: 0, y: 0, width: self.videoView.frame.size.width, height: self.videoView.frame.size.height)
        
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        viewContainer.layer.addSublayer(playerLayer)
        
        player.play()
        
        // notifica quando il player arriva alla fine del video e fallo ripartire da capo
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) {Notification in
                                                if self.repeatVideo {
                                                    player.seek(to: kCMTimeZero)
                                                    player.play()
                                                }
            
                                                
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (Notification) in
            if self.repeatVideo {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

