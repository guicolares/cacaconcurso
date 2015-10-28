//
//  RegionTableViewController.swift
//  buscaconcurso
//
//  Created by Guilherme Leite Colares on 10/16/15.
//  Copyright © 2015 Guilherme Leite Colares. All rights reserved.
//

import UIKit

class RegionTableViewController: UITableViewController {
    
    @IBOutlet var regionsTableView: UITableView!
    
    var regions:[PFObject] = []
    var regionsSelected: [PFObject]? = []
    var regionsLastSelected: [PFObject]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        let regionsOff: Bool = userDefault.boolForKey("regionsOff")
        
        let query = PFQuery(className: "region").orderByAscending("name")
        if regionsOff {
            query.fromLocalDatastore()
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            self.regions = objects!
            userDefault.setBool(true, forKey: "regionsOff")
            if !regionsOff {
                PFObject.pinAllInBackground(self.regions)
            }
        }
        
        let cache = PFQuery(className: "region")
        cache.fromPinWithName("regionsSelected")
        cache.findObjectsInBackgroundWithBlock { (regions, error) -> Void in
            debugPrint(regions)
            self.regionsSelected = regions
            self.regionsLastSelected = self.regionsSelected
            self.regionsTableView.reloadData()
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.regions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RegionCell")!
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        let region = self.regions[indexPath.row]
        let name = region["name"] as! String
        let province = region["province"] as! String
        (cell.viewWithTag(1) as! UILabel).text = "\(name) (\(province))"
        
        if self.regionsSelected != nil {
            for regionCache in self.regionsSelected! {
                if region.objectId == regionCache.objectId {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    break
                }
            }
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType.rawValue != UITableViewCellAccessoryType.Checkmark.rawValue {
            self.regions[indexPath.row].pinInBackgroundWithName("regionsSelected", block: nil)
            self.regionsSelected?.append(self.regions[indexPath.row])
        }else{
            self.regions[indexPath.row].unpinInBackgroundWithName("regionsSelected", block: nil)
            for var i = 0; i < self.regionsSelected!.count; ++i {
                if self.regionsSelected![i].objectId == self.regions[indexPath.row].objectId {
                    self.regionsSelected!.removeAtIndex(i)
                }
            }
        }
        self.regionsTableView.reloadData()
        
    }
   
    @IBAction func clickOnClose(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        PFObject.unpinAllInBackground(nil, withName: "regionsSelected" )
        PFObject.pinAllInBackground(self.regionsLastSelected, withName: "regionsSelected")
    }
    
    

    
}
