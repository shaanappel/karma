//
//  NewPostCollectionViewCell.swift
//  Karma
//
//  Created by Jessica Ji on 4/6/16.
//  Copyright © 2016 MDB - Karma. All rights reserved.
//

import UIKit
import Parse

protocol NewPostCollectionViewDelegate {
    func selectLocationsPressed(cell : NewPostCollectionViewCell)
}

class NewPostCollectionViewCell: UICollectionViewCell, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var setAudience: UIButton!
    //let dropDown = DropDown()
    
    var selectedAudience = "Berkeley"
    var currUser = PFUser.currentUser()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    var usersInRange = Array<PFObject>()    
    
    var delegate:NewPostCollectionViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //
        //        dropDown.dataSource = [
        //            "Berkeley",
        //            "California"
        //        ]
        //
        //        dropDown.selectionAction = { [unowned self] (index, item) in
        ////            self.setAudience.setTitle(item, forState: .Normal)
        //            print("Selected Action: %@", item)
        //        }
        //        dropDown.anchorView = setAudience
        //        dropDown.direction = .Top
        ////        dropDown.bottomOffset = CGPoint(x: 0, y:setAudience.bounds.height)
        //        dropDown.topOffset = CGPoint(x: 0, y:-setAudience.bounds.height)
    }
    
    //    @IBAction func showOrDismiss(sender: AnyObject) {
    //        dropDown.reloadAllComponents()
    //
    //        if dropDown.hidden {
    //            dropDown.show()
    //        } else {
    //            dropDown.hide()
    //        }
    //    }
    
    //    @IBAction func viewTapped() {
    //        view.endEditing(false)
    //    }
    
    @IBAction func selectLocationPressed(sender: AnyObject)
    {
        //Present setAudiencepopover and select location
        //        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("locationSelection") as! LocationsViewController
        //        var nav = UINavigationController(rootViewController: vc)
        //        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        //        var popover = nav.popoverPresentationController
        //        vc.preferredContentSize = CGSizeMake(320,300)
        //        popover!.delegate = self
        //        popover!.sourceView = self.setAudience
        //        popover!.sourceRect = self.setAudience.frame
        //
        ////        self.presentViewController(nav, animated: true, completion: nil)
        //        self.window?.rootViewController?.presentViewController(nav, animated: true, completion: nil)
        delegate!.selectLocationsPressed(self)
    }
    @IBAction func sendMessage(sender: AnyObject) {
        print(textView.text)
        currUser!["audienceLim"] = currUser!["audienceLim"] as! Int + 1
        if (textView.text != "" || textView.text != "What's on your mind?") {
            let msg = PFObject(className: "Messages")
            msg["messageBody"] = textView.text
            msg["sentLocation"] = currUser!["location"] as! PFGeoPoint
            msg["senderId"] = currUser!.objectId
            msg["sentDate"] = NSDate()
            msg["authorized"] = false
            msg["flagged"] = false
            msg["favorited"] = false
            
            msg["audience"] = selectedAudience
            
            //Edit once approved:
            //msg["readIds"] = Array<ObjectIds>
            //msg["replyText"] = String
            
            let recieverIds = NSMutableArray()
            let recievedLocations = NSMutableArray()
            
            let userGeoPoint = currUser!["location"] as! PFGeoPoint
            
            let query = PFQuery(className:"_User")
            print(DataStorage.getDouble("radius"))
            query.whereKey("location", nearGeoPoint:userGeoPoint, withinMiles: DataStorage.getDouble("radius"))
            query.limit = currUser!["audienceLim"] as! Int
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            if (object.objectId != self.currUser?.objectId) {
                                recieverIds.addObject(object.objectId!)
                                recievedLocations.addObject(object["location"])
                            }
                        }
                        msg["recieverIds"] = recieverIds
                        msg["recievedLocations"] = recievedLocations
                        
                        
                        msg.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            self.setPlaceholder()
                            self.textView.endEditing(true)
                            if (success) {
                                print("yaaaaas")
                                // if tap outside then shrink the box
                                // but if inside then expand and show the button
                            } else {
                                print("error saving")
                                // display what kind of error?
                            }
                        }
                        
                        
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
                        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.sentLabel.alpha = 1.0
                            }, completion: nil)
                        UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.sentLabel.alpha = 0.0
                            }, completion: {
                                (finished: Bool) -> Void in
                        })
            
        }
    }
    
    func setPlaceholder() {
        textView.delegate = self
        textView.text = "What's on your mind?"
        textView.textColor = UIColor.lightGrayColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //
        //        dropDown.dataSource = [
        //            "Berkeley",
        //            "California"
        //        ]
        //
        //        dropDown.selectionAction = { [unowned self] (index, item) in
        //            //            self.setAudience.setTitle(item, forState: .Normal)
        //            print("Selected Action: %@", item)
        //        }
        //        dropDown.anchorView = setAudience
        //        dropDown.direction = .Bottom
        //        dropDown.topOffset = CGPoint(x: 0, y:-30)
        
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = "What's on your mind?"
            textView.textColor = UIColor.lightGrayColor()
        }
        textView.resignFirstResponder()
    }
    
    
    //dismiss keyboard
    
}
