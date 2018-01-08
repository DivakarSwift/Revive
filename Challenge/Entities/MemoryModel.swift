//
//  MemoryModel.swift
//  Challenge
//
//  Created by Alessandro Graziani on 11/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import AVFoundation


struct MemoryModel: Codable {
    
    var title: String
    var photos: [String]
    var videos: [URL]
    
    var emotions: String?
    
    init(title: String, emotions: String = "") {
        self.title = title
        self.emotions = emotions
        self.photos = []
        self.videos = []
    }
}

