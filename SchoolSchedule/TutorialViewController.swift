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
//        autoreleasepool {
//            // Create the managed object context
//            // Custom code here...
//            // Save the managed object context
//            do {
//                try context.save()
//                let dat = try Data(contentsOf: URL(string: Bundle.main.path(forResource: "ZCLASSDATA", ofType: "json")!)!)
//                let cereal = try JSONSerialization.jsonObject(with: dat, options: []) as? NSArray
////                cereal?.enumerateObjects({ (obj, idx, stop) in
////                    let ent = NSEntityDescription.insertNewObject(forEntityName: "ClassData", into: context)
////                    CoreDataStack.
////                    man.setValue((obj as! Dictionary)["minute"], forKey: "minute")
////                    man.setValue((obj as! Dictionary)["hour"], forKey: "hour")
////                    man.setValue((obj as! Dictionary)["day"], forKey: "day")
////                    man.setValue((obj as! Dictionary)["classnumber"], forKey: "classnumber")
////                })
//                try context.save()
//            } catch {
//                print(error)
//            }
////            print("Imported Banks: \(Banks ?? "")")
//        }
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

//    func createShortcut(currentClass: String, toClass: String){
//        let intent = TimeWidgetIntent()
//
//        if let shortcut = INShortcut(intent: intent) {
//            let releventShortcut = INRelevantShortcut(shortcut: shortcut)
//            releventShortcut.shortcutRole = .information
//            releventShortcut.relevanceProviders = [INDailyRoutineRelevanceProvider(situation: .school), INDailyRoutineRelevanceProvider(situation: .school)]// may need to add more relevance providers;
//            let defferedTitle = NSString.deferredLocalizedIntentsString(with: currentClass + " -> " + toClass) as String
//            let defaultTemplate = INDefaultCardTemplate(title: defferedTitle)
//            defaultTemplate.subtitle = NSString.deferredLocalizedIntentsString(with: "", ) as String
//            releventShortcut.watchTemplate = defaultTemplate
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
