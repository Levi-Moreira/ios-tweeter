//
//  MainTableViewController.swift
//  tweeter
//
//  Created by ifce on 11/09/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire


class MainTableViewController: UITableViewController, CLLocationManagerDelegate {

    
    @IBOutlet var tweetsTable: UITableView!
    
    @IBOutlet var mapButton: UIBarButtonItem!
    
    @IBOutlet var addButton: UIBarButtonItem!
    
    
    var restAcessor =  RestAcessor()
    var tweetsList = [CTweet]()
    
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
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }



    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return tweetsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)

        cell.textLabel?.text = tweetsList[indexPath.row].text
        
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
            cell.detailTextLabel?.text = "Unavailable"
        case .online:
            print("Connected")
            getTweetLocation(tweet: tweetsList[indexPath.row], completionHandler: {(location) in
                cell.detailTextLabel?.text = location
                
            })
        }

        


        return cell
    }
 

 
    func getTweetLocation(tweet: CTweet, completionHandler: @escaping (_ locationCity: String)-> Void){
        let geocoder = CLGeocoder()
        
        
        let location = CLLocation(latitude: CLLocationDegrees(tweet.latitude), longitude: CLLocationDegrees(tweet.longitude))
        
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            if (error != nil) {
                completionHandler("")
            }
            
            if((placemark?.count)! > 0){
                completionHandler((placemark?.first?.locality)!)
            }else{
                completionHandler("")
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, index) in
            
            let tweet = self.tweetsList[indexPath.row]

            
            let alertView = UIAlertController(title: "Review and edit your tweet", message: "Change anything you like", preferredStyle: .alert)
            
            
            alertView.addAction(UIAlertAction(title: "Leave it be", style: .default, handler: { (action) in
                alertView.dismiss(animated: true, completion: nil)
            }))
            
            alertView.addAction(UIAlertAction(title: "Change it!", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                let textField = alertView.textFields![0]
                
                
                
                tweet.text = textField.text!
                
                if let location = self.currentLocation{
                    
                    tweet.latitude = location.coordinate.latitude
                    tweet.longitude = location.coordinate.longitude
                    
                    self.restAcessor.performEditTweet(tweet: self.tweetsList[indexPath.row], position: indexPath, completionHandler: {(position) in
                        self.loadingIndicator.stopAnimating()
                        self.tableView.reloadRows(at: [position], with: .fade)
                        CTweet.save()
                    })
                    
                    self.loadingIndicator.startAnimating()
                }
                
            }))
            
            alertView.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter text:"
                textField.text = tweet.text
                
            })
            
            self.present(alertView, animated: true, completion: nil)
            
        }
        
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, index) in
            
            let alertView = UIAlertController(title: "R u sure about this?", message: "Do you really want to delete this tweet?", preferredStyle: .alert)
            
            
            alertView.addAction(UIAlertAction(title: "I do not", style: .default, handler: { (action) in
                alertView.dismiss(animated: true, completion: nil)
            }))
                
            alertView.addAction(UIAlertAction(title: "Destroy it!", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                
                
                self.restAcessor.performTweetDelete(tweetID: self.tweetsList[indexPath.row].id!, pos: indexPath, completionHandler: {(position) in
                    self.loadingIndicator.stopAnimating()
                    let tweetToRemove = self.tweetsList.remove(at: position.row)
                    tweetToRemove.delete()
                    CTweet.save()
                    tableView.deleteRows(at: [position], with: .fade)
                    
                })
                
                self.loadingIndicator.startAnimating()
                
            }))

            
            self.present(alertView, animated: true, completion: nil)

        }
        
        deleteAction.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        
        
        return [deleteAction, editAction]
    }
    

 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
        addButton.isEnabled = true
        mapButton.isEnabled = true
    }


    
    @IBAction func didTabAddTweet(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "Insert a new tweet", message: "Please type in your new tweet", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action) in
            alertView.dismiss(animated: true, completion: nil)
        }))
        
        
        alertView.addAction(UIAlertAction(title: "Tuitar", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let textField = alertView.textFields![0]
            
            if let location = self.currentLocation{
                
                let tweet = CTweet.create()
                tweet.id = ""
                tweet.text = textField.text!
                tweet.latitude = location.coordinate.latitude
                tweet.longitude = location.coordinate.longitude
                tweet.created_at = ""
                tweet.updated_at = ""
                
               
                self.restAcessor.performCreateTweet(tweet: tweet, completionHandler: {(tweet) in
                    self.loadingIndicator.stopAnimating()
                    self.tweetsList.append(tweet)
                    self.tableView.reloadData()
                    CTweet.save()
                })
                
                self.loadingIndicator.startAnimating()
            }
            
        }))
        
        alertView.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter text:"
            
        })
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    func getTweets(){
        
        
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
  
            
            if let tweets = CTweet.getAllRecords(){
                self.tweetsList.removeAll()
                self.tweetsList.append(contentsOf: tweets)
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating()
                self.refreshControl?.endRefreshing()
            }
        case .online:
            print("Connected")

            loadingIndicator.startAnimating()
            restAcessor.performGetList { (tweets) in
                self.tweetsList.removeAll()
                self.tweetsList.append(contentsOf: tweets)
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating()
                self.refreshControl?.endRefreshing()
                CTweet.save()
            }

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapViewSegue"{
            var mapViewController : MapViewController = segue.destination as! MapViewController
            mapViewController.tweetList = tweetsList
        
        }
    }
    
        

}
