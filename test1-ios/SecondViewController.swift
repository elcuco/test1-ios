//
//  SecondViewController.swift
//  test1-ios
//
//  Created by diego on 20/12/2018.
//  Copyright © 2018 Diego. All rights reserved.
//

import UIKit
import FeedKit

class SecondViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var mainTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTable.dataSource = self
        
        fetchBuisinessRss()
    }

    @IBAction func segmentedControlChanged(_ segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            fetchBuisinessRss()
            break
        case 1:
            fetchEnvironmentRss()
            fetchEntertaintmentRss()
            break
        default:
            print("FAIL?")
        }
    }
    
    var feeds: [String: RSSFeed?] = [:]
    var feedItems: [String: [RSSFeedItem]] = [:]

    func fetchFeed( _ name: String) {
        print("Start loading " + name  )
        
        // OK - FAIL
        // why http? why Reuters does not support HTTPS for these feeds, so
        // I am forced to allow http for the that domain.
        // Another option -
        //   Feedkit internally uses Data(URL) for getting the xml. Instead I
        //   could use another transport library, and for those specific calls
        //   ignore the HTTPS issue.
        //   However - using HTTP is secure for this, as we only fetch data,
        //   and this is RO data only.
        let url = "http://feeds.reuters.com/reuters/" + name
        let feedURL = URL(string: url)!
        let parser = FeedParser(URL: feedURL)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            print("Finish loading " + name  )
            
            // in theory - we don't need this. But I am keeping it,
            // just in case... Probably a mistake
            self.feeds[name] = result.rssFeed
            
            self.feedItems[name] = result.rssFeed?.items
            
            // and this is the epic hack - I merge both feeds into one
            self.feedItems["mixed"] =
                (self.feeds["entertainment"]??.items ?? []) +
                (self.feeds["environment"]??.items ?? [])
            DispatchQueue.main.async {
                self.mainTable.reloadData()
            }
        }
    }
    
    func fetchBuisinessRss() {
        fetchFeed("businessNews")
    }
    
    func fetchEntertaintmentRss() {
        fetchFeed("entertainment")
    }
    
    func fetchEnvironmentRss() {
        fetchFeed("environment")
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // UITable
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            if let feeds = self.feeds["businessNews"]  {
                return feeds?.items?.count ?? 0
            }
            return 0
        case 1:
            if let feeds = self.feedItems["mixed"]  {
                return feeds.count
            }
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var text = "FAIL"
        var subText = "...?"
        
        if let item = feedsForIndex(indexPath: indexPath) {
            text = item.title ?? "FAIL #\(indexPath.row)"
            if item.pubDate != nil {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                subText = formatter.string(from: item.pubDate!)
            }
        }
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "rssLine")!
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = subText
        return cell
    }

    func feedsForIndex(indexPath: IndexPath) -> RSSFeedItem? {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            if let feedItems = self.feedItems["businessNews"] {
                return feedItems[indexPath.row]
            }
            break
        case 1:
            if let feedItems = self.feedItems["mixed"] {
                return feedItems[indexPath.row]
            }
            break
        default:
            return nil
        }
        return nil
    }
}

