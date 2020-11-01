//
//  TutorialViewController.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 2/1/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
//import Intents

class TutorialViewController: UIViewController {

    var context: NSManagedObjectContext!
    
    @IBAction func nchsAutoSetup(_ sender: Any) {
        let sqlitePath = Bundle.main.path(forResource: "SchoolSchedule", ofType: "sqlite")
        let URL1 = URL(fileURLWithPath: sqlitePath!)
        let URL2 = URL(fileURLWithPath: CoreDataStack.applicationDocumentsDirectory.relativePath + "/SchoolSchedule.sqlite")
        do {
            try FileManager.default.removeItem(at: URL2)
            sleep(1)
            try FileManager.default.copyItem(at: URL1, to: URL2)
            print("=======================")
            print("FILES COPIED")
            print("=======================")
            do {
                try context.save()
            } catch {
                print(error)
            }
        } catch {
            print("=======================")
            print("ERROR IN COPY OPERATION")
            print(error)
        }
        // Request permission to display alerts and play sounds.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = CoreDataStack.managedObjectContext
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
