import UIKit
import Foundation
import CoreBluetooth

class GlobalData: NSObject {
    
    static let shared = GlobalData()
    
    //MARK: - GlobalData Processing
    var G_Advertisers = [String : Advertiser]()
    
    func setNewAdvertiser(uuidStr : String, advertiser: Advertiser) {
        G_Advertisers[uuidStr] = advertiser
        Utile.shared.saveObjectDataToNSUserDefault(saveObject: G_Advertisers as NSObject, forKey: C_USER_STANDARD_KEYS.ADVERTISERS_KEY)
    }
    
    func removeAdvertiser(uuidStr : String) {
        G_Advertisers.removeValue(forKey: uuidStr)
        Utile.shared.saveObjectDataToNSUserDefault(saveObject: G_Advertisers as NSObject, forKey: C_USER_STANDARD_KEYS.ADVERTISERS_KEY)
    }
    
}
