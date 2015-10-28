//
//  ConcourseDetailViewController.swift
//  buscaconcurso
//
//  Created by Guilherme Leite Colares on 10/16/15.
//  Copyright © 2015 Guilherme Leite Colares. All rights reserved.
//

import UIKit

class ConcourseDetailViewController: UIViewController {
    
    var concourse: PFObject!
    
    @IBOutlet weak var lblPart: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var lblPosition: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblPart.text = self.concourse["part"] as? String
        self.lblPosition.text = self.concourse["role"] as? String
        self.detailTextView.text = self.concourse["description"] as! String
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.detailTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}
