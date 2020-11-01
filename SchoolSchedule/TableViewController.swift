//
//  TableViewController.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 2/5/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }

    var resources: NSManagedObject!
    var context: NSManagedObjectContext!
    var sectionHours: [[Int?]] = []
    var oldIndex: IndexPath? = nil
    
    @IBAction func editButton(_ sender: Any) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    @IBAction func addButton(_ sender: Any) {
        if resources.value(forKey: "days") != nil {
            let entity = NSEntityDescription.entity(forEntityName: "ClassData", in: context)
            let object = NSManagedObject(entity: entity!, insertInto: context)
            object.setValue(1, forKey: "day")
            object.setValue(0, forKey: "hour")
            do {
                try context.save()
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        } else {
            print("nothing")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        context = CoreDataStack.managedObjectContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "DayBaseline")
        do {
            resources = try context.fetch(fetch).first
        } catch {
            print(error)
        }
        let sections = (resources.value(forKey: "days") ?? 0) as! Int
        print(sections, 999)
        sectionHours = []
        for _ in 0...sections - 1 {
            sectionHours.append([])
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
        let day = section + 1
        print(section, "section")
        let predicateA = NSPredicate(format: "day == %@", "\(day)")
        fetch.predicate = predicateA
        do {
            let results = try context.fetch(fetch)
            print(results)
            var values: [Int?] = []
            for result in results {
                let val = result.value(forKey: "hour") as! Int?
                print(val as Any)
                values.append(val)
            }
            print(values)
            values.sort(by: { (first, second) -> Bool in
                if first != nil && second != nil {
                    return first! < second!
                } else if first != nil || second != nil {
                    if first == nil {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            })
//            sectionHours[section] = values
            sectionHours[section] = values
            print(sectionHours)
            return results.count
        } catch {
            print(error)
            return 0
        }
        print("this should not be printed")
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.compare(oldIndex ?? IndexPath(row: -1, section: -1)) == .orderedSame {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BigCell", for: indexPath) as! BigCellView
//            cell.tag = cantorPairingNumber(row: indexPath.row + 1, section: indexPath.section + 1)
            print(indexPath.section, "index section")
            let cellHr = sectionHours[indexPath.section][indexPath.row] ?? 0
            let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
            let day = indexPath.section + 1
            let predicateA = NSPredicate(format: "day == %@", "\(day)")
            print("\(cellHr)")
            let predicateB = NSPredicate(format: "hour == %@", "\(cellHr)") //error may occur here with nil values
            let compPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateA, predicateB])
            fetch.predicate = compPredicate
            do {
                let results = try context.fetch(fetch)
                var result: NSManagedObject!
                if results.count == 1 {
                    result = results.first
                } else {
                    for i in 1...100 {
                        print(indexPath.row, indexPath.section)
                        print(indexPath.row - i, "01010")
                        if indexPath.row - i < 0 {
                            print(i, 555)
                            result = results[i - 1]
                            break
                        } else if sectionHours[indexPath.section][indexPath.row - i] != cellHr {
                            result = results[i - 1]
                            break // should kill the 1 to 100 loop
                        }
                    }
                }
                cell.object = result
            } catch {
                print(error)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellReuser", for: indexPath) as! TableViewCell
//            cell.tag = cantorPairingNumber(row: indexPath.row + 1, section: indexPath.section + 1)
            print(indexPath.section, "index section")
            let cellHr = sectionHours[indexPath.section][indexPath.row] ?? 0
            let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
            let day = indexPath.section + 1
            let predicateA = NSPredicate(format: "day == %@", "\(day)")
            print("\(cellHr)")
//            let predicateB = NSPredicate(format: "hour == %@", "\(cellHr)") //error may occur here with nil values
//            let compPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateA, predicateB])
            fetch.predicate = predicateA
            let hdescriptor = NSSortDescriptor(key: "hour", ascending: true)
            let mdescriptor = NSSortDescriptor(key: "minute", ascending: true)
            fetch.sortDescriptors = [hdescriptor, mdescriptor]
            do {
                let results = try context.fetch(fetch)
                var result: NSManagedObject!
                print(results.count, 20002)
                result = results[indexPath.row]
                if let oNumb = result.value(forKey: "classnumber") as! Int? {
                    //                cell.hL1.text = String(describing: result.value(forKey: "classnumber") as! Int?)
                    let cNumb = oNumb + 1
                    cell.hL1.text = String(describing: (result.value(forKey: "classnumber") ?? 0) as! Int)
                    let resourceFetch = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
                    resourceFetch.predicate = NSPredicate(format: "classnumber = %@", "\(cNumb)")
                    let resourceResul = try context.fetch(resourceFetch)
                    let resourceResults = resourceResul.first
                    cell.textLabel?.text = ((resourceResults?.value(forKey: "classname") ?? "error") as! String)
                } else {
                    cell.textLabel?.text = "nil"
                    cell.hL1.text = "nil"
                }
                print(result as Any)
                let m = (result.value(forKey: "minute") ?? -1) as! Int
                if m > 9 {
                    cell.detailTextLabel?.text = "\(cellHr):\(m)"
                } else {
                    cell.detailTextLabel?.text = "\(cellHr):0\(m)"
                }
            } catch {
                print(error)
            }
            //Configure the cell...
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Day \(section + 1)"
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
//        if indexPath.compare(oldIndex ?? IndexPath(row: -1, section: -1)) == .orderedSame {
//            return false
//        }
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCell
        if editingStyle == .delete {
            // Delete the row from the data source
            let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
            let dayOf = indexPath.section + 1
            print(cell.hL1 as Any)
            let predicateA = NSPredicate(format: "day = %@", "\(dayOf)")
            let predicateB = NSPredicate(format: "classnumber = %@", cell.hL1.text!)
            let firstColon = cell.detailTextLabel?.text?.firstIndex(of: ":") ?? cell.hL1.text?.endIndex
            let hour = cell.detailTextLabel?.text?.prefix(upTo: firstColon!)
            let minute = cell.detailTextLabel?.text?.suffix(from: firstColon!)
            print(String(describing: hour)," hour")
            let predicateH = NSPredicate(format: "hour = %@", String(describing: hour!))
            print(String(describing: minute!.dropFirst()))
            let predicateM = NSPredicate(format: "minute = %@", String(describing: minute!.dropFirst()))
            let abPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateA, predicateB])
            let timPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateH, predicateM])
            let compPredicate = NSCompoundPredicate(type: .and, subpredicates: [abPredicate, timPredicate])
            fetch.predicate = compPredicate
            do {
                let results = try context.fetch(fetch)
                context.delete(results.first!)
                try context.save()
                print(results.first as Any, "results.first")
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        oldIndex = indexPath
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        oldIndex = nil
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.compare(oldIndex ?? IndexPath(row: -1, section: -1)) == .orderedSame {
            return 289.5
        }
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        print("go throughhhhhhhhhhhhh")
        let cell = self.tableView.cellForRow(at: fromIndexPath) as! TableViewCell
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ClassData")
        let dayOf = fromIndexPath.section + 1
        print(cell.hL1 as Any)
        let predicateA = NSPredicate(format: "day = %@", "\(dayOf)")
        let predicateB = NSPredicate(format: "classnumber = %@", cell.hL1.text!)
        let firstColon = cell.detailTextLabel?.text?.firstIndex(of: ":") ?? cell.hL1.text?.endIndex
        let hour = cell.detailTextLabel?.text?.prefix(upTo: firstColon!)
        let minute = cell.detailTextLabel?.text?.suffix(from: firstColon!)
        print(String(describing: hour)," hour")
        let predicateH = NSPredicate(format: "hour = %@", String(describing: hour!))
        let predicateM = NSPredicate(format: "minute = %@", String(describing: minute!.dropFirst()))
        let abPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateA, predicateB])
        let timPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateH, predicateM])
        let compPredicate = NSCompoundPredicate(type: .and, subpredicates: [abPredicate, timPredicate])
        fetch.predicate = compPredicate
        do {
            let results = try context.fetch(fetch)
            print(results.count, "err")
            let result = results.first
            result?.setValue((to.section + 1), forKey: "day")
            try context.save()
            print(results.first as Any, "results.first")
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func cantorPairingNumber(row: Int, section: Int) -> Int {
        let a = row + section
        let b = a + 1
        let c = a * b
        let d = c / 2
        return d + section
    }

}
