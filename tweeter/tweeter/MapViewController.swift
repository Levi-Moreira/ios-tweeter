//
//  MapViewController.swift
//  tweeter
//
//  Created by ifce on 9/13/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    var tweetList : [CTweet] = []
    
    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if tweetList.count > 0 {
            addPinToMapView()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPinToMapView(){
        
        for tweet in tweetList{
            addPin(text: tweet.text!, latitude: tweet.latitude, longitude: tweet.longitude)
        }
    }
    
    
    func addPin(text: String, latitude: Double, longitude: Double){
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        annotation.coordinate = location
        annotation.title = text
        mapView.addAnnotation(annotation)
    }
    


}
