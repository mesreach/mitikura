import UIKit
import GoogleMaps
import GooglePlaces
import Material

class MainViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!

    var tableView: UITableView!
    var fetcher: GMSAutocompleteFetcher!
    var placesClient: GMSPlacesClient!
    var searchController = UISearchController(searchResultsController: nil)
    var dstPlace: GMSPlace?

    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389

    var data: [GMSAutocompletePrediction] = []

    fileprivate var card: Card!
    fileprivate var toolbar: Toolbar!
    fileprivate var contentView: UILabel!
    fileprivate var bottomBar: Bar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // GMSMapVIew Settings
        let zoom: Float = 15
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude,
                                                                 longitude: longitude,
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
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "nextView")
        self.present(next, animated: true, completion: nil)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.mapView.isHidden = true
        self.tableView.isHidden = false
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
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        self.mapView.isHidden = false
        self.tableView.isHidden = true
        self.view.sendSubview(toBack: self.tableView)
        self.mapView.clear()
        self.card.removeFromSuperview()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
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
            let marker = GMSMarker(position: position)
            marker.title = place.name
            marker.map = self.mapView
            self.mapView.animate(to: camera)
            self.displayPlaceDetailed(place: place, marker: marker)
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
