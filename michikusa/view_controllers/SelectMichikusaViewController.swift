import UIKit
import GoogleMaps

class SelectMichikusaViewController: UIViewController {
    @IBOutlet weak var michikusaSpot: PickerKeyboard!
    var data:[String] = ["hoge", "hage"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.michikusaSpot.addData(d: self.data)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
