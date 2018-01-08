//
//  DataManagel.swift
//  Challenge
//
//  Created by Alessandro Graziani on 12/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    static let shared = DataManager()
    
    var travelStorage: [TravelModel] = []
    var filePath: String!
    
    var collectionViewContr: MainScreen!
    var MemoryViewContr: MemoryViewController!
    
    var haveToReloadLayout: Bool = true
    
    
    // MARK - From String->UIImage and UIImage->String
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    func getPath(image: UIImage, fileName: String) -> String? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    func loadFromPath(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    ////////////////////////////////
    
    func loadData() {
        filePath = documentsFolder() + "/travelStorage.plist"
        
        if FileManager.default.fileExists(atPath: filePath) {
            guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data else {return}
            do {
                travelStorage = try PropertyListDecoder().decode([TravelModel].self, from: data)
            } catch {
                return
            }
        } else {
            let pathImage1 = getPath(image: UIImage(named: "photo7")!, fileName: "foto1")
            let travel1 = TravelModel(image: pathImage1!, place: "Mare", date: "dicembre 2017")
            
            let pathImage2 = getPath(image: UIImage(named: "photo9")!, fileName: "foto2")
            let travel2 = TravelModel(image: pathImage2!, place: "Fiume", date: "ottobre 2017")
            
            let pathImage3 = getPath(image: UIImage(named: "photo3")!, fileName: "foto3")
            let travel3 = TravelModel(image: pathImage3!, place: "Mare", date: "luglio 2017")
            
            let pathImage4 = getPath(image: UIImage(named: "photo4")!, fileName: "foto4")
            let travel4 = TravelModel(image: pathImage4!, place: "Ponte", date: "luglio 2016")
            
            let pathImage5 = getPath(image: UIImage(named: "photo5")!, fileName: "foto5")
            let travel5 = TravelModel(image: pathImage5!, place: "Scogli", date: "giugno 2016")
            
            travelStorage = [travel1, travel2, travel3, travel4, travel5]
            
            saveData()
        }
    
    }
    
    func addTravel(pathImage: String, place: String, date: String) {
        let newTravel = TravelModel(image: pathImage, place: place, date: date)
        travelStorage.insert(newTravel, at: 0)
        
        saveData()
    }
    
    func removeTravel(place: String) {
        for i in 0..<travelStorage.count {
            if travelStorage[i].place == place {
                travelStorage.remove(at: i)
                saveData()
                return
            }
        }
    }
    
    func indexOfTravel(travel: TravelModel) -> Int {
        for i in 0..<travelStorage.count {
            // find travel in storage
            if (travelStorage[i].place + travelStorage[i].date) == (travel.place + travel.date) {
                return i
            }
        }
        return 0
    }


    
    func addPhotoToMemory(travel: TravelModel, memoryTitle: String, emoji: String, photos: [String]) {
        for i in 0..<travelStorage.count {
            if (travelStorage[i].place + travelStorage[i].date) == (travel.place + travel.date) {
                // scorro le memorie con un for per vedere se ne esiste una con questo nome
                for j in 0..<travelStorage[i].memories.count {
                    if travelStorage[i].memories[j].title == memoryTitle {
                        print("DEBUG: Nel viaggio \(travel.place) esisteva già questo ricordo. Contiene \(travelStorage[i].memories[j].photos.count) foto")
                        travelStorage[i].memories[j].photos += photos
                        print("DEBUG: Ne ho aggiunte \(photos.count) Ora contiene \(travelStorage[i].memories[j].photos.count) photo")
                        saveData()
                        return
                    }
                }
                // se non l'ho trovata la creo ora
                print("DEBUG: Non c'era questo ricordo, lo creo adesso")
                var newMemory = MemoryModel(title: memoryTitle, emotions: emoji)
                newMemory.photos += photos
                travelStorage[i].memories.insert(newMemory, at: 0)
                print("DEBUG: Ho creato il ricordo \(travelStorage[i].memories[0].title)")
                makeEmotionsCategory(indexOfTravel: i, emotion: emoji)
            }
        }
        saveData()
    }
    
    
    func addVideoToMemory(travel: TravelModel, memoryTitle: String, emoji: String, videoURL: URL) {
        for i in 0..<travelStorage.count {
            if (travelStorage[i].place + travelStorage[i].date) == (travel.place + travel.date) {
                // scorro le memorie con un for per vedere se ne esiste una con questo nome
                for j in 0..<travelStorage[i].memories.count {
                    if travelStorage[i].memories[j].title == memoryTitle {
                        travelStorage[i].memories[j].videos.insert(videoURL, at: 0)
                        saveData()
                        return
                    }
                }
                // se non l'ho trovata la creo ora
                var newMemory = MemoryModel(title: memoryTitle, emotions: emoji)
                newMemory.videos.insert(videoURL, at: 0)
                travelStorage[i].memories.insert(newMemory, at: 0)
                
                makeEmotionsCategory(indexOfTravel: i, emotion: emoji)
            }
        }
        saveData()
    }
    
    func makeEmotionsCategory(indexOfTravel: Int, emotion: String) {
        switch emotion {
        case "😂":
            travelStorage[indexOfTravel].funnyMemories.append(travelStorage[indexOfTravel].memories[0])
//            travelStorage[indexOfTravel].funnyMemories[0].photos += travelStorage[indexOfTravel].memories[0].photos
        case "😍":
            travelStorage[indexOfTravel].loveMemories.append(travelStorage[indexOfTravel].memories[0])
        case "😎":
            travelStorage[indexOfTravel].greatMemories.append(travelStorage[indexOfTravel].memories[0])
        case "😢":
            travelStorage[indexOfTravel].sadMemories.append(travelStorage[indexOfTravel].memories[0])
        case "🤫":
            travelStorage[indexOfTravel].secretMemories.append(travelStorage[indexOfTravel].memories[0])
        case "🤬":
            travelStorage[indexOfTravel].angryMemories.append(travelStorage[indexOfTravel].memories[0])
        default:
            break
        }
        
        travelStorage[indexOfTravel].cells.removeAll()
        
        if travelStorage[indexOfTravel].funnyMemories.count > 0 {
            let funnyMemories = MemoryModel(title: "Funny")
            travelStorage[indexOfTravel].cells.append(funnyMemories)
        }
        if travelStorage[indexOfTravel].loveMemories.count > 0 {
            let loveMemories = MemoryModel(title: "Love")
            travelStorage[indexOfTravel].cells.append(loveMemories)
        }
        if travelStorage[indexOfTravel].greatMemories.count > 0 {
            let greatMemories = MemoryModel(title: "Great")
            travelStorage[indexOfTravel].cells.append(greatMemories)
        }
        if travelStorage[indexOfTravel].sadMemories.count > 0 {
            let sadMemories = MemoryModel(title: "Sad")
            travelStorage[indexOfTravel].cells.append(sadMemories)
        }
        if travelStorage[indexOfTravel].secretMemories.count > 0 {
            let secretMemories = MemoryModel(title: "Secret")
            travelStorage[indexOfTravel].cells.append(secretMemories)
        }
        if travelStorage[indexOfTravel].angryMemories.count > 0 {
            let angryMemories = MemoryModel(title: "Angry")
            travelStorage[indexOfTravel].cells.append(angryMemories)
        }
        
        travelStorage[indexOfTravel].cells.append(contentsOf: travelStorage[indexOfTravel].memories)
        
        // MARK - DEBUG
        print("DEBUG: Il viaggio a \(travelStorage[indexOfTravel].place) contiene \(travelStorage[indexOfTravel].memories.count) ricordi. Tra cui: \n \(travelStorage[indexOfTravel].funnyMemories.count) ricordi funny \n \(travelStorage[indexOfTravel].loveMemories.count) ricordi love \n \(travelStorage[indexOfTravel].greatMemories.count) ricordi great \n \(travelStorage[indexOfTravel].sadMemories.count) ricordi sad \n \(travelStorage[indexOfTravel].secretMemories.count) ricordi secret \n \(travelStorage[indexOfTravel].angryMemories.count) ricordi angry. \n Il totale delle celle è \(travelStorage[indexOfTravel].cells.count)")
    }
    
    func removeEmotionCategory(indexOfTravel: Int, emotion: String) {
        switch emotion {
        case "😂":
            if travelStorage[indexOfTravel].funnyMemories.count > 0 {
                travelStorage[indexOfTravel].funnyMemories.remove(at: 0)
            }
        case "😍":
            if travelStorage[indexOfTravel].loveMemories.count > 0 {
                travelStorage[indexOfTravel].loveMemories.remove(at: 0)
            }
        case "😎":
            if travelStorage[indexOfTravel].greatMemories.count > 0 {
                travelStorage[indexOfTravel].greatMemories.remove(at: 0)
            }
        case "😢":
            if travelStorage[indexOfTravel].sadMemories.count > 0 {
                travelStorage[indexOfTravel].sadMemories.remove(at: 0)
            }
        case "🤫":
            if travelStorage[indexOfTravel].secretMemories.count > 0 {
                travelStorage[indexOfTravel].secretMemories.remove(at: 0)
            }
        case "🤬":
            if travelStorage[indexOfTravel].angryMemories.count > 0 {
                travelStorage[indexOfTravel].angryMemories.remove(at: 0)
            }
        default:
            break
        }
        
        travelStorage[indexOfTravel].cells.removeAll()
        
        if travelStorage[indexOfTravel].funnyMemories.count > 0 {
            let funnyMemories = MemoryModel(title: "Funny")
            travelStorage[indexOfTravel].cells.append(funnyMemories)
        }
        if travelStorage[indexOfTravel].loveMemories.count > 0 {
            let loveMemories = MemoryModel(title: "Love")
            travelStorage[indexOfTravel].cells.append(loveMemories)
        }
        if travelStorage[indexOfTravel].greatMemories.count > 0 {
            let greatMemories = MemoryModel(title: "Great")
            travelStorage[indexOfTravel].cells.append(greatMemories)
        }
        if travelStorage[indexOfTravel].sadMemories.count > 0 {
            let sadMemories = MemoryModel(title: "Sad")
            travelStorage[indexOfTravel].cells.append(sadMemories)
        }
        if travelStorage[indexOfTravel].secretMemories.count > 0 {
            let secretMemories = MemoryModel(title: "Secret")
            travelStorage[indexOfTravel].cells.append(secretMemories)
        }
        if travelStorage[indexOfTravel].angryMemories.count > 0 {
            let angryMemories = MemoryModel(title: "Angry")
            travelStorage[indexOfTravel].cells.append(angryMemories)
        }
        
        travelStorage[indexOfTravel].cells.append(contentsOf: travelStorage[indexOfTravel].memories)
        
        // MARK - DEBUG
        print("DEBUG: Il viaggio a \(travelStorage[indexOfTravel].place) contiene \(travelStorage[indexOfTravel].memories.count) ricordi. Tra cui: \n \(travelStorage[indexOfTravel].funnyMemories.count) ricordi funny \n \(travelStorage[indexOfTravel].loveMemories.count) ricordi love \n \(travelStorage[indexOfTravel].greatMemories.count) ricordi great \n \(travelStorage[indexOfTravel].sadMemories.count) ricordi sad \n \(travelStorage[indexOfTravel].secretMemories.count) ricordi secret \n \(travelStorage[indexOfTravel].angryMemories.count) ricordi angry. \n Il totale delle celle è \(travelStorage[indexOfTravel].cells.count)")
    }
    
    func removeMemory(indexOfTravel: Int, memoryName: String) {
        
        for i in 0..<travelStorage[indexOfTravel].memories.count {
            if travelStorage[indexOfTravel].memories[i].title == memoryName {
                removeEmotionCategory(indexOfTravel: indexOfTravel, emotion: travelStorage[indexOfTravel].memories[i].emotions!)
                travelStorage[indexOfTravel].memories.remove(at: i)
                break
            }
        }
        for i in 0..<travelStorage[indexOfTravel].cells.count {
            if travelStorage[indexOfTravel].cells[i].title == memoryName {
                travelStorage[indexOfTravel].cells.remove(at: i)
                break
            }
        }
        saveData()
    }
    
    func saveData() {
        do {
            let data = try PropertyListEncoder().encode(travelStorage)
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
            print(success ? "Save" : "Save failed")
        } catch {
            print("Save failed")
        }
    
    }
    
    // String for document folder
    func documentsFolder() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //print(paths[0])
        return paths[0]
    }
    
    // URL for document folder
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}
