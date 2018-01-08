//
//  PlaylistManager.swift
//  Challenge
//
//  Created by Alessandro Graziani on 19/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistManager: NSObject {

    static let shared = PlaylistManager()
    
    var playlist: MPMediaItemCollection!
}

