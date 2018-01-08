
//
//  TravelModel.swift
//  Challenge
//
//  Created by Alessandro Graziani on 11/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit
import MediaPlayer

struct TravelModel: Codable {

    var travelBackground: String
    var place: String
    var date: String
    var memories: [MemoryModel]
    
    var funnyMemories: [MemoryModel]
    var loveMemories: [MemoryModel]
    var greatMemories: [MemoryModel]
    var sadMemories: [MemoryModel]
    var secretMemories: [MemoryModel]
    var angryMemories: [MemoryModel]
    
    var cells: [MemoryModel] = []
    
    
    init(image: String, place: String, date: String) {
        self.travelBackground = image
        self.place = place
        self.date = date
        self.memories = []
        
        self.funnyMemories = []
        self.loveMemories = []
        self.greatMemories = []
        self.sadMemories = []
        self.secretMemories = []
        self.angryMemories = []
        
        self.cells = []
    }

}


