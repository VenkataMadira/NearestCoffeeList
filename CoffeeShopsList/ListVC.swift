//
//  ListVC.swift
//  CoffeeShopsList
//
//  Created by Venkat Madira on 25/01/2021.
//


import UIKit
import MapKit

class ListVC: UITableViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView?
    var refreshCtl = UIRefreshControl()
    
    fileprivate let foursquareClient = FoursquareClient(clientID: "JOEJMGQDZGRV0JXRKK5IFCEW4ZAXXNC1BGCW3IUPAUQOYWEG", clientSecret: "EONBZIOU3OELGZBWLEHGB3FHKGVYLZISBTWTG0YUCJZSZ4PY")
    fileprivate var coordinate: Coordinate?
    
    fileprivate var locationManager = LocationManager()
    fileprivate var venues: [Venue] = [] {
        didSet {
            tableView.reloadData()
            addMapAnnotations()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refreshCtl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshCtl.addTarget(self, action: #selector(self.refreshCoffeeList(_:)), for: .valueChanged)
        tableView.addSubview(refreshCtl) // not required when using UITableViewController
       
        mapView?.delegate = self
        mapView?.showsUserLocation = true
       
        locationManager.getPermission()
        locationManager.onLocationUpdate = { coordinate in
            self.coordinate = coordinate
            self.fetchCoffeeData()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view Delegates and Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.venue = self.venues[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venueDetails =  self.venues[(indexPath as NSIndexPath).row]
        viewdetailsPopUp(venueName: venueDetails.name, venueStreet: venueDetails.location?.street ?? "its near but Street address not found!")
    }
    
    // MARK: - Fetch
    
    func fetchCoffeeData() {
        if let coordinate = coordinate {
            foursquareClient.fetchCoffeeResturantsFor(coordinate, category: .coffee(nil)) { result in
                switch result {
                case .success(let venues):
                    self.venues = venues
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Map View
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        var region = MKCoordinateRegion()
        region.center = mapView.userLocation.coordinate
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        
        mapView.setRegion(region, animated: true)
        
    }
    
    func addMapAnnotations() {
        removeMapAnnotations()
        
        if venues.count > 0 {
            let annotations: [MKPointAnnotation] = venues.map { venue in
                let point = MKPointAnnotation()
                
                if let coordinate = venue.location?.coordinate {
                    point.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    point.title = venue.name
                }
                
                return point
            }
            
            mapView?.addAnnotations(annotations)
        }
    }
    
    func removeMapAnnotations() {
        if mapView?.annotations.count != 0 {
            for annotation in mapView!.annotations {
                mapView?.removeAnnotation(annotation)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin ")
        
        let title = view.annotation?.title ?? "No Name"
        let coordinate2d = view.annotation?.coordinate
        onClickMapPoint(name: title!, coordinate: coordinate2d!)
        
        
    }
    
    @objc func refreshCoffeeList(_ sender: Any) {
        print("refresh list ")
        fetchCoffeeData()
    }
    
    
    @IBAction func refreshData(_ sender: AnyObject) {
        fetchCoffeeData()
        refreshCtl.endRefreshing()
    }
    
    private func viewdetailsPopUp(venueName:String, venueStreet:String){
        
        let alert = UIAlertController(title: "\(venueName)", message: " Adress :\(venueStreet).", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    private func onClickMapPoint(name:String, coordinate:CLLocationCoordinate2D){
        
        let location = CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
        location.fetchCityAndCountry { firstLine, placeName, error in
            guard let firstLine = firstLine, let placeName = placeName, error == nil else { return }
            print(firstLine + ", " + placeName)  // Rio de Janeiro, Brazil
            self.viewdetailsPopUp(venueName: name, venueStreet: "\(firstLine),\(placeName)")
        }
        
    }
    
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ firstLine: String?, _ placeName:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.name, $0?.first?.locality, $1) }
    }
}


