import UIKit
import Foundation

class Utile: NSObject {
    
    static let shared = Utile()
    
    //MARK: - UserStandardDefault
    func saveObjectDataToNSUserDefault(saveObject: NSObject, forKey: String) {
        let userDefaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: saveObject)
        userDefaults.set(encodedData, forKey: forKey)
    }
    
    func loadObjectDataToNSUserDefault(forKey: String) -> NSObject? {
        var loadObject:NSObject? = nil
        let userDefaults = UserDefaults.standard
        let data = userDefaults.data(forKey: forKey)
        if data != nil {
            loadObject = NSKeyedUnarchiver.unarchiveObject(with: data!) as? NSObject
        }
        return loadObject
    }
    
    //MARK: - UIAlertController
    func showAlert(vc: UIViewController, title: String, content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }
}
