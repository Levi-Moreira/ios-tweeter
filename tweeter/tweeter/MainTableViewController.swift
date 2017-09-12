//
//  MainTableViewController.swift
//  tweeter
//
//  Created by ifce on 11/09/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import UIKit
import CoreLocation

class MainTableViewController: UITableViewController, RestResponderDelegate, CLLocationManagerDelegate {

    
    @IBOutlet var tweetsTable: UITableView!
    
    var restAcessor =  RestAcessor()
    var tweetsList = [Tweet]()
    
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    let refreshControlView = UIRefreshControl()
    
    let getTweetsSelector = "getTweets"
    
    var locationManager = CLLocationManager()
    
    var currentLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTable.delegate = self
        tweetsTable.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        restAcessor.restResponderDelegate = self
        
        getTweets()
    
        
        refreshControlView.addTarget(self, action: Selector(getTweetsSelector), for: .valueChanged)
        
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControlView
        }else{
            tableView.addSubview(refreshControlView)
        }
        
        loadingIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loadingIndicator.startAnimating()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return tweetsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)

        cell.textLabel?.text = tweetsList[indexPath.row].text

        return cell
    }
 

 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            restAcessor.requestDeleteTweet(tweetID: tweetsList[indexPath.row]._id, pos: indexPath)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
    }


    
    @IBAction func didTabAddTweet(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "Insert a new tweet", message: "Please tip in your new tweet", preferredStyle: .alert)
        
        
        alertView.addAction(UIAlertAction(title: "Tuitar", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let textField = alertView.textFields![0]
            
            if let location = self.currentLocation{
                
                let tweet = Tweet(_id: "", text: textField.text!, lat: location.coordinate.latitude, long: location.coordinate.longitude, created_at: "", updated_at: "")
                
                self.restAcessor.requestCreateTweet(tweet: tweet)
                
                self.loadingIndicator.startAnimating()
            }
            
        }))
        
        alertView.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter text:"
            
        })
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    func getTweets(){
        restAcessor.requestList()
    }
    
    func getListResponse(tweets: [Tweet]) {
        
        tweetsList.removeAll()
        tweetsList.append(contentsOf: tweets)
        tableView.reloadData()
        loadingIndicator.stopAnimating()
        self.refreshControl?.endRefreshing()
        
    }
    
    func deleteTweetResponse(position : IndexPath) {
        loadingIndicator.stopAnimating()
        tweetsList.remove(at: position.row)
        tableView.deleteRows(at: [position], with: .fade)

    }
    
    func postResponse(tweet : Tweet) {
        loadingIndicator.stopAnimating()
        tweetsList.append(tweet)
        tableView.reloadData()

    }
    
    func editResponse(tweet: Tweet) {
        loadingIndicator.stopAnimating()

    }

}
