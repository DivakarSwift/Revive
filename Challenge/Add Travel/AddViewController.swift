//
//  AddViewController.swift
//  Challenge
//
//  Created by Michele Finizio on 12/12/17.
//  Copyright © 2017 Artico. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var fieldName: UITextField!
    
    @IBOutlet var fromOutlet: UIButton!
    @IBOutlet var toOutlet: UIButton!
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nsconstraint: NSLayoutConstraint!

    lazy var actualDate = Date()
    
    // date picker from to
    
    @IBOutlet var textFieldFrom: UITextField!
    @IBOutlet var datePickerFrom: UIDatePicker!
    
    @IBOutlet var textFieldTo: UITextField!
    @IBOutlet var datePickerTo: UIDatePicker!
    
    @IBOutlet var datePickerFromHeight: NSLayoutConstraint!
    @IBOutlet var fieldToHeight: NSLayoutConstraint!
    @IBOutlet var datePickerToHeight: NSLayoutConstraint!
    
    
    @IBOutlet var constChoosePic: [NSLayoutConstraint]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerFrom.backgroundColor = UIColor(red: 0, green: 84.0/255, blue: 147.0/255, alpha: 0.3)
        datePickerTo.backgroundColor = UIColor(red: 0, green: 84.0/255, blue: 147.0/255, alpha: 0.3)
        
        datePickerFrom.layer.masksToBounds = true
        datePickerFrom.layer.cornerRadius = 25
        
        datePickerTo.layer.masksToBounds = true
        datePickerTo.layer.cornerRadius = 25
        
        datePickerFromHeight.constant = 0
        datePickerToHeight.constant = 0

        self.title = "Add Travel"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.fieldName.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIScreen.main.bounds.width == 834 {
            for constraint in constChoosePic {
                constraint.constant = 270
            }
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = (self.view.frame.size.width - (self.nsconstraint.constant*2)) / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    @IBAction func pickPhoto(_ sender: UITapGestureRecognizer) {
        CameraManager.shared.newImageLibrary(controller: self, sourceIfPad: self.view, editing: false) { (image) in
            self.imageView.image = image
        }
    }
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem? = nil) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    
    func exportDate() -> String {
        if textFieldFrom.text == "" || textFieldTo.text == "" {
            return "Failed"
        } else {
            return "from \((textFieldFrom.text)!)\nto \((textFieldTo.text)!)"
        }
    }
    
    func showAlert(message mess: String) {
        let alert = UIAlertController(title: "Warning!", message: mess, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fieldName.resignFirstResponder()
        return true
    }
    
    @IBAction func from(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            if self.datePickerFromHeight.constant == 0 {
                self.datePickerFromHeight.constant = 150
            } else {
                self.textFieldFrom.text = self.donePick(datepicker: self.datePickerFrom)
                self.datePickerFromHeight.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func to(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            if self.datePickerToHeight.constant == 0 {
                self.datePickerToHeight.constant = 150
            } else {
                self.textFieldTo.text = self.donePick(datepicker: self.datePickerTo)
                self.datePickerToHeight.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func donePick(datepicker: UIDatePicker) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: datepicker.date)
    }
    
    
    
    @IBAction func closeKeyboard(_ sender: UITapGestureRecognizer) {
        fieldName.resignFirstResponder()
    }
    
    

    // MARK - PathData
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        if (fieldName.text == "") {
            showAlert(message: "Please, insert the title of the travel")
            return
        } else if exportDate() == "Failed" {
            showAlert(message: "Please, insert the date of the travel")
            return
        } else if (imageView.image == UIImage(named: "choosePhoto")) {
            showAlert(message: "Please, choose an image")
            return
        } else {
            let date = actualDate
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let filename = formatter.string(from: date)
            let pathImage = DataManager.shared.getPath(image: self.imageView.image!, fileName: filename)
            print(pathImage!)
            
            DataManager.shared.addTravel(pathImage: pathImage!, place: fieldName.text!, date: exportDate())
            print("Il Nome è: \(filename)")
            
            DataManager.shared.collectionViewContr.collectionView.setContentOffset(CGPoint.zero, animated: true)
            DataManager.shared.collectionViewContr.currentPage = 0
            DataManager.shared.collectionViewContr.collectionView.reloadData()
            
            self.cancelButton()
        }
    }

}
