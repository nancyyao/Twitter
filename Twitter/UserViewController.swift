//
//  UserViewController.swift
//  Twitter
//
//  Created by Nancy Yao on 6/28/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import AFNetworking

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    var userTweets: [Tweet]?
    var user: User!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var headerImageView: UIImageView!
    
//    var refreshControl: UIRefreshControl!
    
    var customView: UIView!
    var refreshImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadUserTimeline()
        
        //refresh control
        let refreshControl = UIRefreshControl()
        //refreshControl.bounds = CGRectMake(refreshControl.bounds.origin.x, refreshControl.bounds.origin.y, refreshControl.bounds.size.width, 100)
//        refreshControl.backgroundColor = UIColor.clearColor()
//        refreshControl.tintColor = UIColor.clearColor()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

//        loadCustomRefreshContents(refreshControl)

        // Set up header
        let nib = UINib(nibName: "UserHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "UserHeader")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //LOAD DATA
    func loadUserTimeline() {
        TwitterClient.sharedInstance.userTimeline(user.screenname! as String, success: { (tweets: [Tweet]) in
            self.userTweets = tweets
            self.tableView.reloadData()
            print("loaded user timeline")
        }) { (error: NSError) in
                print("error: \(error.localizedDescription)")
        }
    }
    
    //REFRESH
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadUserTimeline()
        refreshControl.endRefreshing()
    }
//    func loadCustomRefreshContents(refreshControl: UIRefreshControl) {
//        let refreshView = NSBundle.mainBundle().loadNibNamed("RefreshView", owner: self, options: nil)
//        customView = refreshView[0] as! UIView
//        customView.frame = refreshControl.bounds
//        refreshImageView = customView.viewWithTag(1) as! UIImageView
//        
//        if let bannerUrl = user.bannerImageUrl {
//            refreshImageView.setImageWithURL(bannerUrl)
//        }
//        
//        refreshControl.addSubview(customView)
//        
//    }
    
    //TABLEVIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userTweets = userTweets {
            return userTweets.count
        } else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserTableViewCell
        let userTweet = userTweets![indexPath.row]
        
        cell.userTimelineImageView.layer.borderWidth = 0
        cell.userTimelineImageView.layer.cornerRadius = cell.userTimelineImageView.frame.height/10
        cell.userTimelineImageView.clipsToBounds = true
        cell.userTimelineImageView.setImageWithURL(user.profileUrl!)
        cell.userTimelineNameLabel.text = user.name as? String
        cell.userTimelineUsernameLabel.text = "@\(user.screenname)"
        cell.userTimelineTextLabel.text = userTweet.text as? String
        cell.userTimelineRetweetLabel.text = String(userTweet.retweetCount)
        cell.userTimelineLikeLabel.text = String(userTweet.favoritesCount)
        
        if userTweet.retweeted == true {
            cell.userTimelineRetweetButton.selected = true
        } else {
            cell.userTimelineRetweetButton.selected = false
        }
        if userTweet.favorited == true {
            cell.userTimelineLikeButton.selected = true
        } else {
            cell.userTimelineLikeButton.selected = false
        }
        
        if let timestamp = userTweet.timestamp {
            let currentTime = NSDate()
            let timeInSeconds = currentTime.timeIntervalSinceDate(timestamp)
            if timeInSeconds < 60 {
                cell.userTimelineTimeLabel.text = String(format: "%.0f", timeInSeconds) + "s"
            }
            else if timeInSeconds < 3600 {
                let timeInMinutes = round(timeInSeconds / 60)
                cell.userTimelineTimeLabel.text = String(format: "%.0f", timeInMinutes) + "m"
            }
            else if timeInSeconds < 86400 {
                let timeInHours = round(timeInSeconds / 3600)
                cell.userTimelineTimeLabel.text = String(format: "%.0f", timeInHours) + "h"
            }
            else {
                let timeInDays = round(timeInSeconds / 86400)
                cell.userTimelineTimeLabel.text = String(format: "%.0f", timeInDays) + "d"
            }
        }
        return cell
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("UserHeader") as! UserHeader
        let header = cell
        
        if let bannerUrl = user.bannerImageUrl {
            cell.userHeaderImageView.setImageWithURL(bannerUrl)
        }
        
        cell.userBackgroundImageView.layer.borderWidth = 0
        cell.userBackgroundImageView.layer.cornerRadius = cell.userBackgroundImageView.frame.height/10
        cell.userBackgroundImageView.clipsToBounds = true
        
        cell.userImageView.layer.borderWidth = 0
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height/10
        cell.userImageView.clipsToBounds = true
        cell.userImageView.setImageWithURL(user.profileUrl!)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        header.userNameLabel.text = user.name as? String
        header.userUsernameLabel.text = "@\(user.screenname!)"
        header.userImageView.setImageWithURL(user.profileUrl!)
        header.userTweetsLabel.text = numberFormatter.stringFromNumber(user.tweetsCount)
        header.userFollowingLabel.text = numberFormatter.stringFromNumber(user.following)
        header.userFollowersLabel.text = numberFormatter.stringFromNumber(user.followers)
        header.userTaglineLabel.text = user.tagline as? String
        
        return cell
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let replyVC = segue.destinationViewController as? ReplyViewController {
            let button = sender as! UIButton
            let view = button.superview!
            let buttonCell = view.superview as! UITableViewCell
            let indexPath = tableView.indexPathForCell(buttonCell)
            
            let replyTweet = userTweets![indexPath!.row] as Tweet
            let replyUser = replyTweet.tweetUser!
            replyVC.screenname = replyUser.screenname as! String
            replyVC.replyId = replyTweet.tweetID as Int!
        }
    }

}
