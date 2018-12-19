import UIKit
import CoreBluetooth

enum ActionMode {
    case Select
    case View
}

class AdvertisersVC: UIViewController {
    
    //MARK: Components
    @IBOutlet weak var mTableView: UITableView!
    
    //MARK: Properties    
    var advertisersDic = [String : Advertiser]()
    var uuids = [String]()
    
    var selectedRows = [IndexPath]()
    var actionMode = ActionMode.View
    
    var parentVC = ScanPeripheralsVC()
    
    //MARK: override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let advertisersData = Utile.shared.loadObjectDataToNSUserDefault(forKey: C_USER_STANDARD_KEYS.ADVERTISERS_KEY)
        if advertisersData != nil {
            advertisersDic = advertisersData as! [String : Advertiser]
            uuids = Array(advertisersDic.keys).sorted()
            mTableView.reloadData()
        } else {
            Utile.shared.showAlert(vc: self, title: "Empty", content: "There is no advertiser yet!")
        }
        setActionModeVC(mode: .View)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - UI processing functions
    func setActionModeVC(mode: ActionMode) {
        actionMode = mode
        if mode == .Select {
            let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDoneBtnIBAction))
            let deleteBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onDeleteBtnIBAction))
            self.navigationItem.rightBarButtonItem = nil
            deleteBtn.isEnabled = false
            self.navigationItem.rightBarButtonItems = [doneBtn, deleteBtn]
        } else {
            let selectBtn = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(onSelectBtnIBAction))
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.rightBarButtonItem = selectBtn
        }
    }
    
    //MARK: - Alert Processing Functions
    func showWarnDelete() {
        let alert = UIAlertController(title: "Warning!", message: "Do you really want to delete the selected advertisers?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (yesAction) in
//            var removedKeys = [String]()
            var removedKeys = [Int]()
            for indexPath in self.selectedRows {
                GlobalData.shared.removeAdvertiser(uuidStr: self.uuids[indexPath.row])
                self.advertisersDic.removeValue(forKey: self.uuids[indexPath.row])
                removedKeys.append(indexPath.row)
            }
//            for removeKey in removedKeys {
//                let index = self.uuids.index(of: removeKey)!
//                self.uuids.remove(at: index)
//            }
            self.uuids.remove(at: removedKeys)
            self.mTableView.beginUpdates()
            self.mTableView.deleteRows(at: self.selectedRows, with: .fade)
            self.mTableView.endUpdates()
            self.setActionModeVC(mode: .View)
            self.selectedRows.removeAll()
            self.parentVC.setAdvertisable()
        }
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - @objc Functions
    @objc func onSelectBtnIBAction() {
        setActionModeVC(mode: .Select)
    }
    
    @objc func onDoneBtnIBAction() {
        selectedRows.removeAll()
        setActionModeVC(mode: .View)
        mTableView.reloadData()
    }
    
    @objc func onDeleteBtnIBAction() {
        showWarnDelete()
    }
        
}

//MARK: UITableViewDelegate
extension AdvertisersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if actionMode == .View {
            
        } else {
            if selectedRows.contains(indexPath) {
                let index = (selectedRows.index(of: indexPath))
                selectedRows.remove(at: index!)
            } else {
                selectedRows.append(indexPath)
            }
            let deleteBtn = self.navigationItem.rightBarButtonItems![1]
            if selectedRows.count == 0 {
                deleteBtn.isEnabled = false
            } else {
                deleteBtn.isEnabled = true
            }
            mTableView.beginUpdates()
            mTableView.reloadRows(at: [indexPath], with: .fade)
            mTableView.endUpdates()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: UITableViewDataSource
extension AdvertisersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C_TABLEVIEW_CELL_IDS.PERIPHERAL_CELL, for: indexPath) as! PeripheralCell
        
        cell.initial(with: (advertisersDic[uuids[indexPath.row]]?.deviceName)!, and: (advertisersDic[uuids[indexPath.row]]?.adDataDescription)!, isAdvertiser: false)
        if selectedRows.contains(indexPath) && actionMode == .Select {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

//remove multiple values with indexs at once
extension Array {
    mutating func remove(at indexes: [Int]) {
        var lastIndex: Int? = nil
        for index in indexes.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index)
            lastIndex = index
        }
    }
}
