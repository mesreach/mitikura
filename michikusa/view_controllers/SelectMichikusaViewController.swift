import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class SelectMichikusaViewController: UIViewController {
    
    @IBOutlet weak var michikusaSpot: PickerKeyboard!
    @IBOutlet weak var mapView: GMSMapView!
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    var michikusaRange: Int?
    var data:[String] = ["hoge", "hage"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.michikusaSpot.addData(d: self.data)
        drawMap()
        //GooglePlace検索＆マップ表示
        getPlaceList(location:self.previousMarker!.position,mapView:mapView)
        //getPlaceList(mapView:mapView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func drawMap() {
        if self.previousMarker != nil {
            self.previousMarker!.map = self.mapView
        }
    }
    
    
    func getPlaceList (location: CLLocationCoordinate2D, mapView:GMSMapView) {
    //func getPlaceList (mapView:GMSMapView) {
        //検索条件の指定
        let location = [35.529792,139.698568] //ひとまずリクエストの中心は固定で試す。。
        let range = 500
        let type = "cafe"
        //GooglePlaceAPIにリクエスト&JSONパース
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        Alamofire.request(url,parameters:["location":location,"radius":range,"type":type]).responseJSON { response in
            let json = try! JSON(data: response.data!)
            let placeList = json["result"].arrayValue
            print(response.result.description)
            //print("routes count: \(routes.count)")
            //APIでの取得結果をマップ上にプロット
            for place in placeList {
                var marker :GMSMarker
                var geometry = place["geometry"].dictionary
                let placeLat = geometry?["lat"]?.doubleValue
                let placeLng = geometry?["lng"]?.doubleValue
                marker = GMSMarker(position: CLLocationCoordinate2D(latitude: placeLat!, longitude: placeLng!))
                marker.map = mapView
            }
        }
    }
}


