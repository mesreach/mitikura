import UIKit

class SearchMichikusaDecorator {
    class func decorate(_ value: Double, tp: String) -> String {
        switch tp {
        case "km":
            return _km_unit_name(value)
        case "tm":
            return _tm_unit_name(value)
        default:
            return ""
        }
    }
    
    fileprivate class func _km_unit_name(_ value: Double) -> String {
        let m = "m"
        let km = "km"

        switch value {
        case 0..<1000:
            return "\(Int(value)) \(m)"
        case 1000..<Double(Int.max):
            return "\(round(value/1000 * 100) / 100) \(km)"
        default:
            return ""
        }
    }
    
    fileprivate class func _tm_unit_name(_ value: Double) -> String {
        let sec = "sec"
        let min = "min"
        let h = "h"
        
        switch value {
        case 0..<60:
            return "\(Int(value)) \(sec)"
        case 60..<3600:
            let v_m = value / 60
            let v_s = (v_m - floor(v_m)) * 60
    
            return "\(Int(v_m)) \(min) \(Int(v_s)) \(sec)"
        default:
            let v_h = value / (60 * 60)
            let v_m = (v_h - floor(v_h) * 60)
            
            return "\(Int(v_h)) \(h) \(Int(v_m)) \(min)"
        }
    }
}
