//
//  Launchscreen.swift
//  Challenge
//
//  Created by Alessandro Graziani on 19/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import AVFoundation

class Launchscreen: UIViewController {
    
    @IBOutlet var videoview: UIView!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var path: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        path = Bundle.main.path(forResource: "launchvideo", ofType: "mp4")
        player = AVPlayer(url: NSURL(fileURLWithPath: path) as URL)
        player.seek(to: kCMTimeZero)
        
        presentVideo()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
        player = nil
        playerLayer.removeFromSuperlayer()
        playerLayer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentVideo() {
        
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoview.layer.addSublayer(playerLayer!)
        
        player?.play()
        
        // notifica quando il player arriva alla fine del video e fallo ripartire da capo
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: nil,
                                               queue: nil) {Notification in
                                                self.performSegue(withIdentifier: "launchApp", sender: self)}
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
