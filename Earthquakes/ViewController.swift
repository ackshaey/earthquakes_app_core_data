//
//  ViewController.swift
//  Earthquakes
//
//  Created by Ackshaey Singh on 3/26/15.
//  Copyright (c) 2015 Ackshaey Singh. All rights reserved.
//

import UIKit
import CoreData

let urlString = "http://earthquake-report.com/feeds/recent-eq?json"


// By default, structures get an init which is called a default initializer.
// we don't need to explicitly initialize the properties in declaration.
struct Earthquake {
    let title: String
    let magnitude: Double
    let latitude: Double
    let longitude: Double
    let link: String
    let depth: Double
    let dateTime: NSDate
    let location: String
}

class ViewController: UIViewController, UITableViewDataSource {
    
    var urlSession: NSURLSession?
    
    var moc: NSManagedObjectContext?
    
    var mainMoc: NSManagedObjectContext?
    
    var deleteMoc: NSManagedObjectContext?
    
    var dataList: [Quake] = [Quake]() // Empty array of quakes.
    
    // DO THIS FOR WITHOUT CORE DATA
    // var quakeList: [Earthquake] = [Earthquake]() // Initialize array to empty array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell view class
        self.tbView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        moc = appDelegate.managedObjectContext
        
        mainMoc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        
        deleteMoc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        
        // Point to the parent MOC. Wrap in perform sync so that we ensure it's
        // on the main queue. Don't need to synce it's already on main queue.
        
        mainMoc?.parentContext = moc
        
        deleteMoc?.parentContext = moc
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ********* Table View To Make It Work
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return self.quakeList.count
        return self.dataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = (dataList[indexPath.row] as Quake).quakeTitle
        
        return cell
    }
    
    @IBOutlet weak var tbView: UITableView!
    
    @IBAction func updateList(sender: AnyObject) {
        // Uses disk as cache and keychain for other storage
        let urlSessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: urlSessionConfig)
        // The NSError! will be used if there is no internet, or no
        if let url = NSURL(string: urlString) {
            
            // For POST, use NSMutableURLRequest and make the request a var.
            //var urlPostRequest = NSMutableURLRequest(URL: url)
            //urlPostRequest.HTTPBody = "{username: something}"
            //urlPostRequest.HTTPMethod = "POST"
            
            
            // If this is not a property, then ARC will release it as soon as the method is over.
            let urlRequest = NSURLRequest(URL: url)
            
            // By Default, this is paused
            let dataTask = self.urlSession?.dataTaskWithRequest(urlRequest, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                
                var jsonError: NSError?
                
                // If array of dictionaries:
                //  then [AnyObject]
                // If dictionary:
                //  then [NSObject: AnyObject]
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &jsonError) as? [AnyObject] {
                    
                    self.moc!.performBlock({ () -> Void in
                        
                        // Delete data
                        self.deleteData()
                        
                        // Inside this for loop we will
                        for element in json {
                            
                            if let leaf = element as? [NSObject : AnyObject] {
                                
                                let quakeTitle = leaf["title"] as String
                                let quakeLocation = leaf["location"] as String
                                let quakeMagnitude = (leaf["magnitude"] as NSString).doubleValue
                                let quakeDepth = (leaf["depth"] as NSString).doubleValue
                                let quakeLatitude = (leaf["latitude"] as NSString).doubleValue
                                let quakeLongitude = (leaf["longitude"] as NSString).doubleValue
                                let quakeDate = leaf["date_time"] as String
                                let quakeLink = leaf["link"] as String
                                
                                let dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:sszzzz"
                                if let date = dateFormatter.dateFromString(quakeDate) {
                                    
                                    // DO THIS FOR WITHOUT CODE DATA.
                                    // let quake = Earthquake(title: quakeTitle, magnitude: quakeMagnitude, latitude: quakeLatitude, longitude: quakeLongitude, link: quakeLink, depth: quakeDepth, dateTime: date, location: quakeLocation)
                                    // self.quakeList.append(quake)
                                    
                                    
                                    let quake = NSEntityDescription.insertNewObjectForEntityForName("Quake", inManagedObjectContext: self.moc!) as Quake
                                    
                                    quake.quakeTitle = quakeTitle
                                    quake.quakeDate = date
                                    quake.quakeMagnitude = quakeMagnitude
                                    
                                    let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.moc!) as Location
                                    
                                    location.latitude = quakeLatitude
                                    location.longitude = quakeLongitude
                                    location.depth = quakeDepth
                                    location.link = quakeLink
                                    location.locationName = quakeLocation
                                    
                                    // Assigning the relationship
                                    quake.location = location
                                }
                            }
                        }
                    })
                    
                    
                    var mocError: NSError?
                    
                    
                    
                    // Here, we need to save on the secondary queue as the saving MOC is on a secondary queue. So we need to use the performBlock.
                    self.moc!.performBlock({ () -> Void in
                        if self.moc!.save(&mocError) {
                            // We need to switch to the main queue here. We should use the performBlock instead
                            // of using GCD.
                            self.mainMoc!.performBlock({ () -> Void in
                                if let results = self.fetchData() {
                                    self.dataList = results
                                    self.tbView.reloadData()
                                }
                            })
                        }
                    })
                    
                    // Ask the tableView to reloadData
                    // THis needs to be dispatched on the main queue.
                    // self.tbView.reloadData()
                    // dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //    self.tbView.reloadData()
                    // })
                    
                    
                }
            })
            
            // This will start the data task
            dataTask?.resume()
        }
    }
    
    func fetchData() -> [Quake]? {
        let fetchRequest = NSFetchRequest()
        let quake = NSEntityDescription.entityForName("Quake", inManagedObjectContext: self.mainMoc!)
        fetchRequest.entity = quake
        
        let sortDescriptor = NSSortDescriptor(key: "quakeMagnitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var fetchError: NSError?
        let quakes = self.mainMoc!.executeFetchRequest(fetchRequest, error: &fetchError) as [Quake] // Array of quakes
        
        return quakes
    }
    
    func deleteData() {
        // We can add another MOC to do deletion.
        self.deleteMoc?.performBlockAndWait({ () -> Void in
            
            let fetchRequest = NSFetchRequest()
            let quake = NSEntityDescription.entityForName("Quake", inManagedObjectContext: self.deleteMoc!)
            fetchRequest.entity = quake
            var fetchError: NSError?
            let quakes = self.deleteMoc!.executeFetchRequest(fetchRequest, error: &fetchError) as [Quake] // Array of quakes
            
            for quake in quakes {
                // This deletes the object in the 'deleteMoc'. 
                // However, we need to save TWICE. The first save saves the objects in MOC. The second save saves it in the persistent store.
                self.deleteMoc?.deleteObject(quake)
            }
            
            var deleteMocError: NSError?
            if self.deleteMoc!.save(&deleteMocError) { // if saved, i.e. all object are updated in the MOC
                
                // Now we need the MOC to save. So we need to wrap it in the perform block
                self.moc!.performBlock({ () -> Void in
                    var mocError: NSError?
                    var saved = self.moc!.save(&mocError)
                    if (!saved) {
                        NSLog("\(mocError), \(mocError!.localizedDescription) ")
                        abort() // Don't use this in production.
                    }
                })
            }
        })
    }
}

