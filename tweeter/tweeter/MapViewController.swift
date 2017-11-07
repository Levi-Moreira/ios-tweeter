//
//  MapViewController.swift
//  tweeter
//
//  Created by ifce on 9/13/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import UIKit
//import MapKit
import GoogleMaps

class MapViewController: UIViewController {


    @IBOutlet var mapVIew: GMSMapView!
    
    var tweetList : [CTweet] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(withLatitude: (tweetList.first?.latitude)!, longitude: (tweetList.first?.longitude)!, zoom: 3.0)
         mapVIew = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
 
        
        if tweetList.count > 0{
            addPinToMapView()
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addPinToMapView(){
        
        for tweet in tweetList{
            addPin(text: tweet.text!, latitude: tweet.latitude, longitude: tweet.longitude)
        }
    }
   
    func addPin(text: String, latitude: Double, longitude: Double){
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.snippet = text
        marker.map = mapVIew
        
    }
    


}
