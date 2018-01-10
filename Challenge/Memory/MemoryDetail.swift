//
//  MemoryDetail.swift
//  Challenge
//
//  Created by Alessandro Graziani on 18/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class MemoryDetail: UIViewController {
    
    func delay(_ seconds: Double, completion: @escaping ()->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
    
    var indexOfTravel: Int!
    var memoryName: String!
    
    var images: [UIImage] = []
    var videos: [URL] = []
    
    @IBOutlet var fotoView: UIView!
    @IBOutlet var videoViewBackground: UIView!
    @IBOutlet var imageTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var videoView: UIView!
    @IBOutlet var labelNoVideos: UILabel!
    
    var player: AVPlayer!
//    var playerLayer1: AVPlayerLayer!
//    var playerLayer2: AVPlayerLayer!
//    var originalFramLayer1: CGRect!
//    var originalFramLayer2: CGRect!
    var repeatVideo: Bool = true
    
    
    @IBOutlet var imageViewBack: UIImageView!
    @IBOutlet var blurForImage: UIVisualEffect!
    @IBOutlet var imageView: UIImageView!
    var checkNewPhotos: Bool!
    
    @IBOutlet var constraint: NSLayoutConstraint!
    
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Galery view
        gallery = GalleryController()
        gallery.delegate = self

        self.title = memoryName
        
        self.fotoView.backgroundColor = .clear
        self.videoViewBackground.backgroundColor = .clear
        
        switch self.memoryName! {
        case "Funny":
            for memory in DataManager.shared.travelStorage[indexOfTravel].funnyMemories {
                for photoPath in memory.photos {
                    self.images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                }
                for videoURL in memory.videos {
                    self.videos.append(videoURL)
                }
            }
        case "Love":
            for memory in DataManager.shared.travelStorage[indexOfTravel].loveMemories {
                for photoPath in memory.photos {
                    self.images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                }
                for videoURL in memory.videos {
                    self.videos.append(videoURL)
                }
            }
        case "Great":
            for memory in DataManager.shared.travelStorage[indexOfTravel].greatMemories {
                for photoPath in memory.photos {
                    self.images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                }
                for videoURL in memory.videos {
                    self.videos.append(videoURL)
                }
            }
        case "Sad":
            for memory in DataManager.shared.travelStorage[indexOfTravel].sadMemories {
                for photoPath in memory.photos {
                    self.images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                }
                for videoURL in memory.videos {
                    self.videos.append(videoURL)
                }
            }
        case "Secret":
            for memory in DataManager.shared.travelStorage[indexOfTravel].secretMemories {
                for photoPath in memory.photos {
                    self.images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                }
                for videoURL in memory.videos {
                    self.videos.append(videoURL)
                }
            }
        case "Angry":
            for memory in DataManager.shared.travelStorage[indexOfTravel].angryMemories {
                for photoPath in memory.photos {
                    self.images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                }
                for videoURL in memory.videos {
                    self.videos.append(videoURL)
                }
            }
        default:
            for memory in DataManager.shared.travelStorage[indexOfTravel].memories {
                if memory.title == self.memoryName {
                    for photoPath in memory.photos {
                        images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                    }
                    for videoURL in memory.videos {
                        videos.append(videoURL)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for memory in DataManager.shared.travelStorage[indexOfTravel].memories {
            if memory.title == self.memoryName {
                if memory.videos.count > 0 {
                    print("DEBUG: CI SONO VIDEO")
                    print("\(memory.videos[0])")
                }
            }
        }
        
        setNavBarInAppear()
        
        let tapOnPhoto = UITapGestureRecognizer(target: self, action:#selector(photosFullScreen))
        imageView.isUserInteractionEnabled = false
        imageView.addGestureRecognizer(tapOnPhoto)
        
        
        switch UIScreen.main.bounds.width {
        case 834, 1024:
            self.constraint.constant = 370
        default:
            self.constraint.constant = 247
        }
        
//        let tapOnVideo = UITapGestureRecognizer(target: self, action: #selector(videosFullScreen))
//        videoView.isUserInteractionEnabled = false
//        videoView.addGestureRecognizer(tapOnVideo)
        
        if images.count > 0 {
            imageSequence()
        }
        if videos.count > 0 {
            videosPlay()
            labelNoVideos.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavBarInDisappear()
        
        if player != nil {
            repeatVideo = false
            player.pause()
//            playerLayer2.removeFromSuperlayer()
//            playerLayer1.removeFromSuperlayer()
            player = nil
        }
    }
    
    func setNavBarInAppear() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
    }
    
    func setNavBarInDisappear() {
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 95.0/255.0, green: 139.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor(red: 44.0/255.0, green: 43.0/255.0, blue: 73.0/242.0, alpha: 1.0)]
    }
    

    @objc func photosFullScreen() {
        UIView.animate(withDuration: 0.5) {
            switch self.constraint.constant {
            case 0:
                self.navigationController?.navigationBar.alpha = 1.0
                self.imageTopConstraint.constant = 64
                switch UIScreen.main.bounds.width {
                case 834, 1024:
                    self.constraint.constant = 370
                default:
                    self.constraint.constant = 247
                }
            default:
                self.navigationController?.navigationBar.alpha = 0.0
                self.imageTopConstraint.constant = 0
                self.constraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
//    @objc func videosFullScreen() {
//        UIView.animate(withDuration: 0.5, animations: {
//            switch self.constraint.constant {
//            case 247:
//                self.navigationController?.navigationBar.alpha = 0.0
//
//                let newFrame = self.view.bounds
//                self.playerLayer2.frame = newFrame
//                self.playerLayer1.frame = newFrame
//                self.constraint.constant = self.view.frame.size.height
//            default:
//                self.navigationController?.navigationBar.alpha = 1.0
//
//                self.playerLayer1.frame = self.originalFramLayer1
//                self.playerLayer2.frame = self.originalFramLayer2
//                self.constraint.constant = 247
//
//            }
//            self.view.layoutIfNeeded()
//        })
//
//    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imageSequence(index: Int = 0, enlarge: Bool = true, checkNewPhotos: Bool = false) {
        
        imageView.isUserInteractionEnabled = true
        
        if checkNewPhotos {
            return
        }
        if index < images.count {
            
            UIView.transition(with: imageViewBack, duration: 1, options: [.curveEaseOut, .transitionCrossDissolve, .allowUserInteraction], animations: {
                self.imageViewBack.image = self.images[index]
            }, completion: nil)
            UIView.transition(with: imageView, duration: 1, options: [.curveEaseOut, .transitionCrossDissolve, .allowUserInteraction], animations: {
                self.imageView.image = self.images[index]
            }, completion: nil)
            if enlarge {
                UIView.animate(withDuration: 3, delay: 0, options: [.allowUserInteraction], animations: {
                    self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 3, delay: 0, options: [.allowUserInteraction], animations: {
                    self.imageView.transform = .identity
                }, completion: nil)
            }
            delay(3) {
                self.imageSequence(index: index+1, enlarge: !enlarge)
                return
            }
        } else {
            delay(3) {
                self.imageSequence(enlarge: !enlarge)
                return
            }
        }
    }
    
    func videosPlay() {
        videoView.isUserInteractionEnabled = true
        
        var i = 0
        player = AVPlayer(url: videos[i])
        player.seek(to: kCMTimeZero)
//        playerLayer1 = AVPlayerLayer(player: player)
//        playerLayer2 = AVPlayerLayer(player: player)
//
//        playerLayer1.frame = self.videoViewBackground.bounds
//        playerLayer2.frame = self.videoView.bounds
//        originalFramLayer1 = playerLayer1.bounds
//        originalFramLayer2 = playerLayer2.bounds
//
//        playerLayer1.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        playerLayer2.videoGravity = AVLayerVideoGravity.resizeAspect
//
//        videoViewBackground.layer.addSublayer(playerLayer1)
//        videoView.layer.addSublayer(playerLayer2)
//
//        player.play()
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (Notification) in
//            if self.repeatVideo {
//                self.player.seek(to: kCMTimeZero)
//                self.player.play()
//            }
//        }
        
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.addChildViewController(playerController)
        playerController.view.frame = self.videoView.frame
        
        // Add sub view in your view
        self.videoView.addSubview(playerController.view)
        
        player.play()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (Notification) in
            if self.repeatVideo {
//                i += 1
//                if i < self.videos.count {
//                    self.player = AVPlayer(url: self.videos[i])
//                    self.player.seek(to: kCMTimeZero)
//                    self.player.play()
//                } else {
//                    i = 0
//                    self.player = AVPlayer(url: self.videos[i])
//                    self.player.seek(to: kCMTimeZero)
//                    self.player.play()
//                }
                self.player.seek(to: kCMTimeZero)
                self.player.play()
            }
        }

        
    }
    

    @IBAction func addMediaButton(_ sender: UIBarButtonItem) {
        present(gallery, animated: false, completion: nil)
    }
    
}

extension MemoryDetail: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        Image.resolve(images: images) { (photosPicked) in
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var i = 0
            let filename = formatter.string(from: date)
            var photoPath: [String] = []
            
            for photo in photosPicked {
                photoPath.append(DataManager.shared.getPath(image: photo!, fileName: filename + String(i))!)
                i += 1
            }
            
            var emoji = ""
            for memory in DataManager.shared.travelStorage[self.indexOfTravel].memories {
                if memory.title == self.title {
                    emoji = memory.emotions!
                }
            }
            DataManager.shared.addPhotoToMemory(travel: DataManager.shared.travelStorage[self.indexOfTravel],
                                                memoryTitle: self.title!,
                                                emoji: emoji,
                                                photos: photoPath)
        }
        
        for memory in DataManager.shared.travelStorage[indexOfTravel].memories {
            if memory.title == self.memoryName {
                for photoPath in memory.photos {
                    self.images.append(DataManager.shared.loadFromPath(fileName: photoPath)!)
                }
            }
        }
        
        imageSequence()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        
        let rotellina = UIActivityIndicatorView(activityIndicatorStyle: .white)
        rotellina.color = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        rotellina.center = self.videoView.center
        rotellina.startAnimating()
        labelNoVideos.text = ""
        self.videoView.addSubview(rotellina)
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            if let tempPath = tempPath {
                var emoji = ""
                for memory in DataManager.shared.travelStorage[self.indexOfTravel].memories {
                    if memory.title == self.title {
                        emoji = memory.emotions!
                    }
                }
                DataManager.shared.addVideoToMemory(travel: DataManager.shared.travelStorage[self.indexOfTravel],
                                                    memoryTitle: self.title!,
                                                    emoji: emoji,
                                                    videoURL: tempPath)
            }
            
            for memory in DataManager.shared.travelStorage[self.indexOfTravel].memories {
                if memory.title == self.memoryName {
                    for videoURL in memory.videos {
                        self.videos.append(videoURL)
                    }
                }
            }
            
            if self.videos.count > 0 {
                self.videosPlay()
                self.labelNoVideos.isHidden = true
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

