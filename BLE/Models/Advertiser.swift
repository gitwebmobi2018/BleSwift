import UIKit

class Advertiser: NSObject, NSCoding {
    
    var uuid = String()
    var deviceName = String()
    var adDataDescription = String()
    
    override init() {
        uuid = String()
        deviceName = String()
        adDataDescription = String()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(deviceName, forKey: "deviceName")
        aCoder.encode(adDataDescription, forKey: "adDataDescription")
    }
    
    required init?(coder aDecoder: NSCoder) {
        deviceName = aDecoder.decodeObject(forKey: "deviceName") as! String
        adDataDescription = aDecoder.decodeObject(forKey: "adDataDescription") as! String
        uuid = aDecoder.decodeObject(forKey: "uuid") as! String
    }
}
