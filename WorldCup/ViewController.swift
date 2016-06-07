/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

private let teamCellIdentifier = "teamCellReuseIdentifier"

class ViewController: UIViewController {
  
  var coreDataStack: CoreDataStack!
  var fetchedResultsController: NSFetchedResultsController!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!
    
    

  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let fetchRequest = NSFetchRequest(entityName: "Team")
    let zoneSort = NSSortDescriptor(key: "qualifyingZone", ascending: true)
    let scoreSort = NSSortDescriptor(key: "wins", ascending: false)
    let nameSort = NSSortDescriptor(key: "teamName", ascending: true)
    fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort]
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: coreDataStack.context,
                                                            sectionNameKeyPath: "qualifyingZone",
                                                            cacheName: "worldCup")
    fetchedResultsController.delegate = self
    
    do {
        try fetchedResultsController.performFetch()
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
    
    
    
  }
  
  func configureCell(cell: TeamCell, indexPath: NSIndexPath) {
    
    let team = fetchedResultsController.objectAtIndexPath(indexPath) as! Team
    
    cell.flagImageView.image = UIImage(named: team.imageName!)
    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins!)"
  }
}

extension ViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView
    (tableView: UITableView) -> Int {
      
      return fetchedResultsController.sections!.count
  }
  
  func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      
    let sectionInfo = fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }
  
  func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
      
      let cell =
      tableView.dequeueReusableCellWithIdentifier(
        teamCellIdentifier, forIndexPath: indexPath)
        as! TeamCell
      
      configureCell(cell, indexPath: indexPath)
      
      return cell
  }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
}

extension ViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let team = fetchedResultsController.objectAtIndexPath(indexPath) as! Team
    
    let wins = team.wins!.integerValue
    team.wins = NSNumber(integer: wins + 1)
    coreDataStack.saveContext()
  }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! TeamCell
            configureCell(cell, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case .Insert:
            tableView.insertSections(indexSet, withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
        default:
            break
        }
    }
}
