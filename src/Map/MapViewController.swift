//
//  MapViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 14/05/2023.
//  refer to : https://www.youtube.com/watch?v=vUvf_dlr6IU&t=570s by Sean Allen
//
//  This is a view controller that can calculate the direction for the user.
//  User just need to move the map and click go button, the direction will be automatically calculated.
//  So that the user doesn't need to use another application to find the direction if they want to go
//  somewhere nearby.
//

import UIKit
import MapKit
import CoreLocation
class MapViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBAction func goButtonTapped(_ sender: UIButton) {
        getDirection()
        
    }

    let locationManager = CLLocationManager() // manage and receive location-related update from the user's devices
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation? // previously obtained location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
    }
    // configure the location manager
    func setupLocationManager(){
        locationManager.delegate = self
        // highest possible accuracy to be used
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // the function will make the mapView will be on the center on the user's current location
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location,latitudinalMeters: regionInMeters,longitudinalMeters:regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    // determines whether the device's location services are enabled
    func checkLocationServices(){
        DispatchQueue.global().async {//perform the check asynchronously and avoid blocking the main thread
              if CLLocationManager.locationServicesEnabled() {
                  // if location is enabled
                  self.setupLocationManager()
                  self.checkLocationAuthorization()
              }
        }
        
    }
    // this function check the authorization status
    func checkLocationAuthorization(){
        switch locationManager.authorizationStatus{
        case .authorizedWhenInUse: //app is open
            DispatchQueue.main.async {
                self.startTrackingUserLocation()
            }
        case .denied://user not give permission //show alert
            break
        case .notDetermined:// havent decide allowed or not
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //show an alert leeting them know what is up
            break
        case .authorizedAlways: // when app in background
            break
        }
    }
    // calculates and displays directions on the mapView based on the user's current location.
    func getDirection(){
        // if have valid location
        guard let location = locationManager.location?.coordinate else {
            return
        }
        // call create directions request
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        
        // calculate the directions based on the request
        directions.calculate{[unowned self](response, error) in
            guard let response =  response else {return}
            for route in response.routes{
                // create the line
                self.mapView.addOverlay(route.polyline)
                // adjust the map to fit displayed route
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
    }
    // create and calculate the directions between 2 locations
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D)->MKDirections.Request{
        // get centre location of mapview
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        // create MKPlacemark for both starting and ending location
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        // make a request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .any
        request.requestsAlternateRoutes = true
        
        return request
    }
    //enables tracking of the user's location and update location
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
        
    }
    //get center location of mapview
    func getCenterLocation(for mapView: MKMapView)-> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longtitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longtitude)
    }
    
}
extension MapViewController: CLLocationManagerDelegate{
    // this function handle the case when user change authorization status for location services
    func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus){
        checkLocationAuthorization()
    }

}
extension MapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView,regionDidChangeAnimated animated: Bool) {
        //get centre of map
        let center = getCenterLocation(for: mapView)
        // check if there is previous location
        guard let previousLocation = self.previousLocation else{return}
        // if distance more than a decent number
        guard center.distance(from: previousLocation) > 50 else {return}
        self.previousLocation = center
        let geoCoder = CLGeocoder()
        
        // ask for the corresponding address of the location when the user move the map
        geoCoder.reverseGeocodeLocation(center){[weak self](placemarks,error) in
            guard let self = self else {return}
            if let _ = error{
                return
            }
            guard let placemark = placemarks?.first else{
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
            
        }
        
    }
    //control appearance of the line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .yellow
        
        return renderer
    }
    
}
