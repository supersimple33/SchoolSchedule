//
//  ClassesViewController.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 2/1/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import CoreData

class ClassesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    var context: NSManagedObjectContext!
    var resources: NSManagedObject!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var TitleField: UITextField!
    @IBOutlet weak var detailsView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func setTitleText(_ sender: Any) {
        if TitleField.text != nil && TitleField.text != "" {
            resources.setValue(TitleField.text, forKey: "classname")
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    @IBAction func setDetail(_ sender: Any) {
        if TitleField.text != nil && TitleField.text != "" {
            resources.setValue(TitleField.text, forKey: "classname")
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    @IBAction func chooseImage(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true) {
            print("presented")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            if let dat = pickedImage.jpegData(compressionQuality: 0.4) {
                resources.setValue(dat, forKey: "image")
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            } else {
                print("error")
            }
        } else {
            print("error")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            print("dissmissed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        context = CoreDataStack.managedObjectContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        do {
            let results = try context.fetch(fetch)
            for resource in results {
                if self.restorationIdentifier == "\(resource.value(forKey: "classnumber") as! Int)" {
                    resources = resource
                }
            }
        } catch {
            print(error)
        }
        print(resources)
        let titleName = (resources.value(forKey: "classname") ?? "") as! String
        TitleField.text = titleName
        TitleField.placeholder = "Choose A Class Name"
        TitleField.delegate = self
        TitleField.returnKeyType = .done
        let detailText = (resources.value(forKey: "classdetails") ?? "Type Your Detail Text Here") as! String
        detailsView.text = detailText
        detailsView.delegate = self
//        detailsView.returnKeyType = .done
        let datView = (resources.value(forKey: "image") ?? Data()) as! Data
        imageView.image = UIImage(data: datView)
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
