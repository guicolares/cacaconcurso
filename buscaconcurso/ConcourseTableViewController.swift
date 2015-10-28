//
//  ConcourseTableViewController.swift
//  buscaconcurso
//
//  Created by Guilherme Leite Colares on 10/16/15.
//  Copyright © 2015 Guilherme Leite Colares. All rights reserved.
//

import UIKit

class ConcourseTableViewController: UITableViewController {
    
    var concourses: [Rows] = []
    var userInfo:  String? = nil
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet var concourseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = NSDate()
        
        let preservedComp: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second ]
        let calender:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calender.timeZone = NSTimeZone.localTimeZone()
        let newDate = calender.components(preservedComp, fromDate: date)
        debugPrint(newDate)
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "fetchConcourses", forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showConcourseByNotification:"), name: "showConcourse", object: nil)
        
        
        self.fetchConcourses()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func showConcourseByNotification(notification:NSNotification)
    {
        self.userInfo = notification.userInfo!["concourse"] as? String
        self.fetchConcourses()
    }
    
    func fetchConcourses(){
        
        let cache = PFQuery(className: "region")
        cache.fromPinWithName("regionsSelected")
        cache.findObjectsInBackgroundWithBlock { (regions, error) -> Void in
            let queryConcourse = PFQuery(className: "concourse").orderByDescending("focus,createdAt")
            queryConcourse.limit = 500
            queryConcourse.includeKey("region")
            if let regions = regions {
                self.title = "Concursos Recentes"
                if regions.count > 0 {
                    self.title = "Caça Concursos"
                    queryConcourse.whereKey("region", containedIn: regions)
                }
            }
            queryConcourse.findObjectsInBackgroundWithBlock({ (concourses, error) -> Void in
                self.refreshControl?.endRefreshing()
                self.activityLoading.stopAnimating()
                if error == nil {
                    self.concourses = []
                    for concourse in concourses! {
                        let region: PFObject = concourse["region"] as! PFObject
                        let regionName = region["name"] as! String
                        
                        var row: Rows = Rows()
                        row.region = region
                        row.regionName = regionName
                        
                        var hasRegion: Bool = false
                        var count: Int = 0
                        
                        for rowAux in self.concourses {
                            if (rowAux.region["name"] as! String) == regionName {
                                row = rowAux
                                hasRegion = true
                                break
                            }
                            ++count
                        }
                        
                        row.concourses.append(concourse )
                        
                        if hasRegion {
                            //change concourse
                            self.concourses[count] = row
                        }else{
                            //add new region
                            self.concourses.append(row)
                        }
                        
                        if self.userInfo == concourse.objectId {
                            self.performSegueWithIdentifier("ShowDetail", sender: concourse)
                        }
                    }
                    
                    self.concourseTableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            })
        }
        
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return self.concourses.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.concourses[section].regionName
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.concourses[section].concourses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.concourseTableView.dequeueReusableCellWithIdentifier("ConcourseCell")!
        let imageViewFocus = (cell.viewWithTag(6) as! UIImageView)
        imageViewFocus.hidden = true
        
        let txtPosition =  cell.viewWithTag(3) as! UILabel
        
        let concourse = self.concourses[indexPath.section].concourses[indexPath.row]
        (cell.viewWithTag(1) as! UILabel).text = concourse["part"] as? String
        (cell.viewWithTag(2) as! UILabel).text = concourse["role"] as? String
        
        if (concourse["focus"] as! Bool) == true {
            imageViewFocus.hidden = false
        }else{
            // do somthing
        }
        
        let position = concourse["position"] as! String
        let positionText = position == "Várias" ? position : "\(position) vagas"
        txtPosition.text = positionText
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail"{
            let cdvc = segue.destinationViewController as! ConcourseDetailViewController
            if let _ = sender as? UITableViewCell {
                let cell = sender as! UITableViewCell
                let indexPath = self.concourseTableView.indexPathForCell(cell)!
                cdvc.concourse = self.concourses[indexPath.section].concourses[indexPath.row]
            }else{
                cdvc.concourse = sender as! PFObject
            }
            
        }
    }
    
    
    
    
     @IBAction func backToConcourseTable(segue: UIStoryboardSegue) {
        self.activityLoading.startAnimating()
        self.fetchConcourses()
    }
}

struct Rows {
    var regionName: String!
    var region: PFObject!
    var concourses: [PFObject] = []
    
}