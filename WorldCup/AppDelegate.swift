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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  lazy var  coreDataStack = CoreDataStack()

  func application(application: UIApplication,
    didFinishLaunchingWithOptions
    launchOptions: [NSObject: AnyObject]?) -> Bool {
      
      importJSONSeedDataIfNeeded()
      
      let navController = window!.rootViewController as! UINavigationController
      let viewController = navController.topViewController as! ViewController
      viewController.coreDataStack = coreDataStack
      
      return true
  }
  
  func applicationWillTerminate(application: UIApplication) {
    coreDataStack.saveContext()
  }
  
  
  func importJSONSeedDataIfNeeded() {
    
    let fetchRequest = NSFetchRequest(entityName: "Team")
    var error:NSError? = nil
    
    let count = coreDataStack.context
      .countForFetchRequest(fetchRequest, error: &error)
    
    if count == 0 {
      importJSONSeedData()
    }
  }
  
  func importJSONSeedData() {
    let jsonURL = NSBundle.mainBundle().URLForResource("seed", withExtension: "json")
    let jsonData = NSData(contentsOfURL: jsonURL!)
    
    do {
      let jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments) as! NSArray
      let entity = NSEntityDescription.entityForName("Team", inManagedObjectContext: coreDataStack.context)
      
      for jsonDictionary in jsonArray {
        let teamName = jsonDictionary["teamName"] as! String
        let zone = jsonDictionary["qualifyingZone"] as! String
        let imageName = jsonDictionary["imageName"] as! String
        let wins = jsonDictionary["wins"] as! NSNumber
        
        let team = Team(entity: entity!,
          insertIntoManagedObjectContext: coreDataStack.context)
        team.teamName = teamName
        team.imageName = imageName
        team.qualifyingZone = zone
        team.wins = wins
      }
      
      coreDataStack.saveContext()
      print("Imported \(jsonArray.count) teams")
      
    } catch let error as NSError {
      print("Error importing teams: \(error)")
    }
  }
}

