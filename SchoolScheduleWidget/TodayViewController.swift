//
//  TodayViewController.swift
//  SchoolScheduleWidget
//
//  Created by Addison Hanrattie on 1/25/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData
import CoreMedia

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var ClassLabel: UILabel!
    @IBOutlet weak var LeftDetail: UILabel!
    @IBOutlet weak var RightDetail: UILabel!
    @IBAction func refreshDat(_ sender: Any) {
        widgetPerformUpdate { (comp) in
        }
    }
    
    var context: NSManagedObjectContext!
    var classes: [NSManagedObject] = []
    var baseline: Date!
    var letterDays: Int!
    let usrDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        usrDefaults.set(nil, forKey: "lastupdate")
        if let handles = retrieveData() {
            completionHandler(handles)
            if handles == .noData {
                return
            }
        }
        print(Date())
        ClassLabel.lineBreakMode = .byTruncatingMiddle
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let now = Date()
        let calendar = Calendar.current
        //      NOTE: Errors Will Occur Here must be Calibrated
        let interval = now.timeIntervalSince(baseline) / 86400
        let nowComp = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        let baseComp = Calendar.current.dateComponents(in: TimeZone.current, from: baseline)
        var interval4 = -1
        if nowComp.weekOfYear == baseComp.weekOfYear {
            interval4 = Int(floor(interval))
        } else {
            let bInterval = Int(floor(interval))
            var wkDy1 = 5
            var wkDy2 = 0
            if nowComp.weekday == 7 {
                wkDy1 = 5
            } else if nowComp.weekday != 1 {
                wkDy1 = nowComp.weekday! - 1
            }
            if baseComp.weekday == 7 {
                wkDy2 = 0
            } else if baseComp.weekday != 1 {
                wkDy2 = (7 - baseComp.weekday!) - 1
            }
            if (nowComp.weekOfYear! - baseComp.weekOfYear!) >= 2 {
                interval4 = wkDy1 + wkDy2 + (((nowComp.weekOfYear! - baseComp.weekOfYear!) - 1) * 5)
                if interval4 > 8 {
                    interval4 = interval4 % 8
                }
            } else {
                interval4 = wkDy1 + wkDy2
                if interval4 > 8 {
                    interval4 = interval4 % 8
                }
            }
        }
        let interval5 = interval4
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
        let endFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
        let dayPredicate = NSPredicate(format: "day = %@", "\(interval5 + 1)")
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let hourPredicate = NSPredicate(format: "hour <= %@", NSNumber(value: hour))
        let hdescriptor = NSSortDescriptor(key: "hour", ascending: true) //changed
        let mdescriptor = NSSortDescriptor(key: "minute", ascending: true)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [dayPredicate, hourPredicate])
        fetchRequest.predicate = compoundPredicate
        fetchRequest.sortDescriptors = [hdescriptor, mdescriptor]
        endFetchRequest.predicate = dayPredicate
        endFetchRequest.sortDescriptors = [hdescriptor, mdescriptor]
        do {
            var results = try context.fetch(fetchRequest)
            let endResults = try context.fetch(endFetchRequest)
            if results.last?.value(forKey: "hour") as! Int == hour {
                if (results.last?.value(forKey: "minute") as! Int) < minute {
                    display(managed: results.last!, endManaged: endResults[safe: results.count])
                    completionHandler(.newData)
                } else if results.count == 1 {
                    display(managed: nil, endManaged: results.last)
                } else {
                    print(results.count)
                    results.removeLast()
                    display(managed: results.last, endManaged: endResults[safe: results.count])
                    completionHandler(.newData)
                }
            } else {
                display(managed: results.last, endManaged: endResults[safe: results.count])
                completionHandler(.newData)
            }
//            display(managed: results.last, endManaged: endResults[safe: results.count])
        } catch {
            print(error)
            completionHandler(.failed)
        }
    }
    
    func retrieveData() -> NCUpdateResult? {
        context = CoreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
        let dateRequest = NSFetchRequest<NSManagedObject>(entityName: "DayBaseline")
        if usrDefaults.object(forKey: "lastupdate") == nil {
            do {
                classes = try context.fetch(fetchRequest)
                let baseEnt = try context.fetch(dateRequest)
                letterDays = baseEnt.first?.value(forKey: "days") as? Int
                baseline = baseEnt.first?.value(forKey: "baseline") as? Date
                return nil
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return NCUpdateResult.failed
            }
        } else if ((usrDefaults.object(forKey: "lastupdate") ?? Date.distantFuture) as! Date).timeIntervalSinceNow > 60.0 {
            do {
                classes = try context.fetch(fetchRequest)
                let baseEnt = try context.fetch(dateRequest)
                letterDays = baseEnt.first?.value(forKey: "days") as? Int
                baseline = baseEnt.first?.value(forKey: "baseline") as? Date
                return nil
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return NCUpdateResult.failed
            }
        } else {
            return NCUpdateResult.noData
        }
//        fatalError("line 146 should never execute")
    }
    
    func display(managed: NSManagedObject?, endManaged: NSManagedObject?) {
        if (managed == nil) && (endManaged == nil) {
            fatalError("managed and endmanaged were nil")
        }
        let now = Date()
        let fixation = (managed?.value(forKey: "classnumber") ?? -1) as! Int
        let endFixation = (endManaged?.value(forKey: "classnumber") ?? -1) as! Int
        var resource: NSManagedObject?
        var endResource: NSManagedObject?
        let resourceRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        resourceRequest.predicate = NSPredicate(format: "classnumber = %@", "\(fixation + 1)")
        let endResourceRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        endResourceRequest.predicate = NSPredicate(format: "classnumber = %@", "\(endFixation + 1)")
        do {
            let resources = try context.fetch(resourceRequest)
            resource = resources.first
            let endResources = try context.fetch(endResourceRequest)
            endResource = endResources.first
        } catch {
            print(error)
        }
        var name = (resource?.value(forKey: "classname") ?? "") as! String
        let secName = endResource?.value(forKey: "classname")
        if secName != nil {
            name += " -> "
            name += secName as! String
        }
        ClassLabel.text = name
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = ((endManaged?.value(forKey: "hour") ?? 14) as! Int)
        components.minute = ((endManaged?.value(forKey: "minute") ?? 5) as! Int)
        let dat = gregorian.date(from: components)
        let since = (dat?.timeIntervalSinceNow)!
        LeftDetail.text = "\(Int(round(since / 60)) - 5)m, Day \((managed?.value(forKey: "day") ?? (endManaged?.value(forKey: "day") ?? 0)) as! Int)"
        RightDetail.text = (resource?.value(forKey: "classdetails") ?? "") as? String
        let dataa = (resource?.value(forKey: "image") ?? Data()) as! Data
        let img = UIImage(data: dataa)
        ImageView.image = img
    }
    
    class PersistentContainer: NSPersistentContainer{
        override class func defaultDirectoryURL() -> URL{
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.addisonhanrattie.SchoolSchedule")!
        }
        override init(name: String, managedObjectModel model: NSManagedObjectModel) {
            super.init(name: name, managedObjectModel: model)
        }
    }
    
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

