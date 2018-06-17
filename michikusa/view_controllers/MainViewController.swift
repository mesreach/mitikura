import UIKit
import GoogleMaps
import GooglePlaces
import Material
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var findMichikusaButton: RaisedButton!

    var tableView: UITableView!
    var fetcher: GMSAutocompleteFetcher!
    var placesClient: GMSPlacesClient!
    var searchController = UISearchController(searchResultsController: nil)
    var dstPlace: GMSPlace?
    var dstMarker: GMSMarker?

    let defaultLatitude: CLLocationDegrees = 35.531064
    let defaultLongitude: CLLocationDegrees = 139.684389
    var currentLocation: CLLocationCoordinate2D?
    var destLocation: CLLocationCoordinate2D!
    var destDuration: Double = 0
    var destDistance: Double = 0
    var polyline: GMSPolyline?
    var mutablePath: GMSMutablePath?

    var data: [GMSAutocompletePrediction] = []
    
    var locationManager: CLLocationManager!

    fileprivate var card: Card!
    fileprivate var toolbar: Toolbar!
    fileprivate var contentView: UILabel!
    fileprivate var bottomBar: Bar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Location Manager Settings
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation()

        if self.currentLocation == nil {
            self.currentLocation = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)
        }
        
        // GMSMapVIew Settings
        let zoom: Float = 15
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: (self.currentLocation?.latitude)!,
                                                                 longitude: (self.currentLocation?.longitude)!,
                                                                 zoom: zoom)
        
        self.mapView.camera = camera
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true
        
        self.placesClient = GMSPlacesClient.shared()
        
        // TableView Settings
        let y = self.searchBar.frame.origin.y + self.searchBar.frame.height
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: y,
                                                   width: view.frame.maxX,
                                                   height: view.frame.maxY - y),
                                     style: UITableViewStyle.plain)
        self.tableView.isHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.view.addSubview(self.tableView)

        // SearchBar Settings
        self.searchBar.delegate = self
        
        // Google Places API Settings
        let filter = GMSAutocompleteFilter()
        filter.country = "JP"
        fetcher = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        fetcher.delegate = self as GMSAutocompleteFetcherDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.searchController.isActive = true
        if self.polyline != nil {
            self.polyline!.map = self.mapView
        }
        
        if self.dstMarker != nil {
            self.dstMarker!.map = self.mapView
        }
    }
    
    @IBAction func goNext_(_ sender: RaisedButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "searchMichikusaView") as! SearchMichukusaViewController

        let pl = self.polyline
        pl?.map = nil
        next.previousPolyLine = pl
        next.previousMarker = self.dstMarker
        next.previousCamera = self.mapView.camera
        next.previousDestDuration = self.destDuration
        next.previousDestDistance = self.destDistance
        next.originalMutablePath = self.mutablePath
        
        self.present(next, animated: true, completion: nil)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.mapView.clear()
        self.mapView.isHidden = true
        self.tableView.isHidden = false
        self.findMichikusaButton.isHidden = true
        self.view.sendSubview(toBack: self.mapView)
        self.view.bringSubview(toFront: self.tableView)
        
        if let tmp = self.card {
            tmp.removeFromSuperview()
        }
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        fetcher?.sourceTextHasChanged(self.searchBar.text!)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetView(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.searchBar.text!.isEmpty {
            resetView(searchBar)
        } else {
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    func resetView(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.findMichikusaButton.isHidden = true
        self.mapView.isHidden = false
        self.tableView.isHidden = true
        self.view.sendSubview(toBack: self.tableView)
        self.mapView.clear()
        if let tmp = self.card {
            tmp.removeFromSuperview()
        }
    }
}

extension MainViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle,
                                                    reuseIdentifier: "Cell")
        
        cell.textLabel?.text = self.data[indexPath.row].attributedPrimaryText.string
        cell.detailTextLabel?.text = self.data[indexPath.row].attributedSecondaryText?.string
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = self.data[indexPath.row]

        // clean searchBar
        self.searchBar.text = cell.attributedPrimaryText.string
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
        
        // clean tableView and display mapView
        self.mapView.isHidden = false
        self.tableView.isHidden = true
        self.view.sendSubview(toBack: self.tableView)
        
        moveMapTo(placeID: cell.placeID!)
    }
}

extension MainViewController {
    func moveMapTo(placeID: String) {
        self.placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            let latlong = place.coordinate
            let camera = GMSCameraPosition.camera(withLatitude: latlong.latitude,
                                                  longitude: latlong.longitude,
                                                  zoom: 15)
            let position = CLLocationCoordinate2D(latitude: latlong.latitude,
                                                  longitude: latlong.longitude)
            self.destLocation = position
            self.dstMarker = GMSMarker(position: position)
            self.dstMarker!.title = place.name
            self.dstMarker!.map = self.mapView
            self.mapView.animate(to: camera)
            self.displayPlaceDetailed(place: place, marker: self.dstMarker!)
        })
    }
    
    func displayPlaceDetailed(place: GMSPlace, marker: GMSMarker) -> Void {
        prepareToolbar(place: place)
        prepareBottomBar()
        prepareContentView()
        prepareCard(marker: marker)
    }
}

extension MainViewController {
    fileprivate func prepareCard(marker: GMSMarker) {
        card = Card()
        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .square3
        card.toolbarEdgeInsets.bottom = 0
        card.toolbarEdgeInsets.right = 8

        card.contentView = contentView
        card.contentViewEdgeInsetsPreset = .wideRectangle3

        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2

        view.layout(card).horizontally(left: 20, right: 20).center(offsetX: 0, offsetY: 120)
    }

    fileprivate func prepareToolbar(place: GMSPlace) {
        toolbar = Toolbar()
        
        toolbar.title = place.name
        toolbar.titleLabel.textAlignment = .left
        
        toolbar.detail = place.formattedAddress
        toolbar.detailLabel.textAlignment = .left
        toolbar.detailLabel.textColor = Color.grey.base
    }

    fileprivate func prepareBottomBar() {
        bottomBar = Bar()

        let button = RaisedButton(title: "Find Route!", titleColor: .white)
        button.pulseColor = .white
        button.backgroundColor = Color.blue.base
        button.addTarget(self, action: #selector(MainViewController.showDirection(sender:)), for: .touchUpInside)

        bottomBar.centerViews = [button]
    }

    fileprivate func prepareContentView() {
        contentView = UILabel()
        contentView.numberOfLines = 0
        contentView.text = ""
        contentView.font = RobotoFont.regular(with: 14)
    }
}

extension MainViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        self.data = predictions
        self.tableView.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        // TODO
    }
}

extension MainViewController: CLLocationManagerDelegate {
    @objc func showDirection(sender: UIButton) {
        self.card.removeFromSuperview()
        self.findMichikusaButton.isHidden = false
        
        drawPath(startLocation: self.currentLocation!, endLocation: self.destLocation)
    }

    func drawPath(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D) {
        let origin = "\(startLocation.latitude),\(startLocation.longitude)"
        let destination = "\(endLocation.latitude),\(endLocation.longitude)"
        let mediumPoint = CLLocationCoordinate2D(latitude: (startLocation.latitude + endLocation.latitude) / 2,
                                                 longitude: (startLocation.longitude + endLocation.longitude) / 2)
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        Alamofire.request(url).responseJSON { response in
            let json = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            print("routes count: \(routes.count)")
            var durationText: String = ""
            var distanceText: String = ""
            var distance: Double = 0
            var duration: Double = 0
            
            for route in routes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath(fromEncodedPath: points!)
                
                self.mutablePath = GMSMutablePath(path: path!)

                self.polyline = GMSPolyline(path: path)
                let legs = route["legs"].arrayValue.last
                distance = (legs!["distance"].dictionary?["value"]?.doubleValue)!
                duration = (legs!["duration"].dictionary?["value"]?.doubleValue)!
                durationText = (legs!["duration"].dictionary?["text"]?.stringValue)!
                distanceText = (legs!["distance"].dictionary?["text"]?.stringValue)!
                
                self.destDuration = duration
                self.destDistance = distance
                self.polyline!.strokeWidth = 4
                self.polyline!.strokeColor = Color.indigo.darken1
                self.polyline!.title = "所要時間 \(durationText), 距離: \(distanceText)"
                self.polyline!.isTappable = true
                self.polyline!.map = self.mapView
            }
            
            let camera = GMSCameraPosition.camera(withTarget: mediumPoint, zoom: Float(self.getAppreciateZoomSize(distance: distance)))
            self.mapView.camera = camera
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.currentLocation = location?.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: (self.currentLocation?.latitude)!,
                                              longitude: (self.currentLocation?.longitude)!,
                                              zoom: 15)
        self.mapView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    
    func getAppreciateZoomSize(distance: Double) -> Int {
        print(distance)
        switch distance {
        case 1..<1000:
            return 16
        case 1000..<5000:
            return 14
        case 5000..<10000:
            return 13
        case 10000..<20000:
            return 12
        case 20000..<50000:
            return 7
        case 50000..<1000000000000:
            return 7
        default:
            return 10
        }
        
    }
}
