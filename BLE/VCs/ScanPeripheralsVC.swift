import UIKit
import CoreBluetooth

enum ScanStatus {
    case CheckBluetoothLEDevice
    case ScanPeripherals
    case PoweredOff
    case Resetting
    case Unauthorized
    case Unknown
    case Unsupported
}

class ScanPeripheralsVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDisabledBle: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var btnUserData: UIBarButtonItem!
    
    private let refreshControl = UIRefreshControl()
    
    //MARK: - Properties    
//    struct BluetoothPeripheral {
//        let name: String
//        let UUID: String
//        let RSSI: String
//        let peripheral: CBPeripheral
//
//        init(name: String, UUID: String, RSSI: NSNumber, peripheral: CBPeripheral) {
//            self.name = "\(name)"
//            self.UUID = "\(UUID)"
//            self.RSSI = "\(RSSI)"
//            self.peripheral = peripheral
//        }
//    }
    
    var centralManager : CBCentralManager?
    var peripheralManager : CBPeripheralManager?
    
    var selectedPeripheral : CBPeripheral?
    
    var peripherals = Array<CBPeripheral>()
    var advertiementDic = [String : String]()
    
    var userDataAlert = UIAlertController()
    
    var refreshTimer : Timer?
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userData = Utile.shared.loadObjectDataToNSUserDefault(forKey: C_USER_STANDARD_KEYS.USER_DATA_KEY) {
            print(userData as! String)
            initial()
        } else {
            showAlertForUserData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Advertisers" {
            let vc = segue.destination as! AdvertisersVC
            vc.parentVC = self
        }
    }
    
    //MARK: - Initial Functions
    func initial() {
        mTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0/255.0, green: 107/255.0, blue: 244.0/255.0, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh device list...", attributes: nil)
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        toolbar.isHidden = false
        
        if let advertisers = Utile.shared.loadObjectDataToNSUserDefault(forKey: C_USER_STANDARD_KEYS.ADVERTISERS_KEY) {
            GlobalData.shared.G_Advertisers = advertisers as! [String : Advertiser]
            print(GlobalData.shared.G_Advertisers)
        }
        
        setUserDataStrToBarBtn()
    }
    
    //MARK: - @Objc Functions
    @objc func refreshTableView(_ sender: Any) {
        peripherals.removeAll()
        advertiementDic.removeAll()
        mTableView.reloadData()
        centralManager?.stopScan()
        scan()
        refreshControl.endRefreshing()
    }
    
    @objc func stopRefresh() {
        refreshControl.endRefreshing()
    }
    
    @objc func changedUserDataTF(_ sender: UITextField) {
        userDataAlert.actions[0].isEnabled = sender.text!.count > 0
    }
    
    //MARK: - Custom Functions    
    func setStatusLayouts(statusMode: ScanStatus) {
        if statusMode == .CheckBluetoothLEDevice {
            activity.isHidden = false
            lblDisabledBle.isHidden = true
            lblDisabledBle.textColor = UIColor(red: 0/255.0, green: 107/255.0, blue: 244.0/255.0, alpha: 1.0)
            lblStatus.textColor = UIColor(red: 0/255.0, green: 107/255.0, blue: 244.0/255.0, alpha: 1.0)
            lblStatus.text = "Checking device..."
        } else if statusMode == .ScanPeripherals {
            activity.isHidden = false
            lblDisabledBle.isHidden = true
            lblDisabledBle.textColor = UIColor(red: 0/255.0, green: 107/255.0, blue: 244.0/255.0, alpha: 1.0)
            lblStatus.textColor = UIColor(red: 0/255.0, green: 107/255.0, blue: 244.0/255.0, alpha: 1.0)
            lblStatus.text = "Scanning..."
        } else {
            activity.isHidden = true
            lblDisabledBle.isHidden = false
            lblDisabledBle.textColor = UIColor.red
            lblStatus.textColor = UIColor.red
            if statusMode == .PoweredOff {
                lblStatus.text = "Bluetooth is powered off!"
            } else if statusMode == .Resetting {
                lblStatus.text = "Bluetooth is resetting..."
            } else if statusMode == .Unauthorized {
                lblStatus.text = "Bluetooth is unauthorized!"
            } else if statusMode == .Unknown {
                lblStatus.text = "Unknown error..."
            } else if statusMode == .Unsupported {
                lblStatus.text = "Bluetooth is unsupported!"
            }
        }
    }
    
    func setUserDataStrToBarBtn() {
        let userData = Utile.shared.loadObjectDataToNSUserDefault(forKey: C_USER_STANDARD_KEYS.USER_DATA_KEY) as! String
        btnUserData.title = userData
    }
    
    func updateMTableViewCell(of index: Int, isAdd: Bool) {
        mTableView.beginUpdates()
        if isAdd {
            mTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            mTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
        mTableView.endUpdates()
    }
    
    //MARK: - CBManager Processing
    func scan() {
        centralManager?.scanForPeripherals(withServices: nil, options:
            [
//             CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true as Bool),
//             CBCentralManagerRestoredStateScanOptionsKey: NSNumber(value: true as Bool),
//             CBCentralManagerRestoredStateScanServicesKey: NSNumber(value: true as Bool),
             CBCentralManagerRestoredStatePeripheralsKey: NSNumber(value: true as Bool),
             ])
//        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func advertising() {
        let userData = Utile.shared.loadObjectDataToNSUserDefault(forKey: C_USER_STANDARD_KEYS.USER_DATA_KEY) as! String
        peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[C_BLUETOOTH_DATA.TRANSFER_SERVICE_UUID], CBAdvertisementDataLocalNameKey: userData])
    }
    
    func setAdvertisable() {
        let uuids = Array(self.advertiementDic.keys)
        let registeredIDs = Array(GlobalData.shared.G_Advertisers.keys)
        if registeredIDs.count == 0 {
            self.peripheralManager?.stopAdvertising()
        } else {
            for registeredID in registeredIDs {
                if uuids.contains(registeredID) {
                    self.advertising()
                    break
                } else {
                    let index = registeredIDs.index(of: registeredID)!
                    if index == registeredIDs.count - 1 {
                        self.peripheralManager?.stopAdvertising()
                    }
                }
            }
        }
    }
    
    func setAdvertiser() {
        let keys = Array(self.advertiementDic.keys)
        if keys.contains((self.selectedPeripheral?.identifier.uuidString)!) {
            let advertiserItem = Advertiser()
            if let name = self.selectedPeripheral?.name {
                advertiserItem.deviceName = name
            } else {
                advertiserItem.deviceName = "N/A"
            }
            advertiserItem.uuid = (self.selectedPeripheral?.identifier.uuidString)!
            advertiserItem.adDataDescription = self.advertiementDic[(self.selectedPeripheral?.identifier.uuidString)!]!
            GlobalData.shared.setNewAdvertiser(uuidStr: advertiserItem.uuid, advertiser: advertiserItem)
            self.mTableView.reloadData()
        } else {
            Utile.shared.showAlert(vc: self, title: "Warning!", content: "Something went wrong! Please select the device again.")
        }
    }
    
    //MARK: - Alert Functions
    func showAlertForUserData() {
        userDataAlert = UIAlertController(title: "Required user data", message: "Please input your device data.", preferredStyle: .alert)
        userDataAlert.addTextField { (userDataTF) in
            userDataTF.placeholder = "User data"
            if let userData = Utile.shared.loadObjectDataToNSUserDefault(forKey: C_USER_STANDARD_KEYS.USER_DATA_KEY) {
                userDataTF.text = userData as? String
            }
            userDataTF.addTarget(self, action: #selector(self.changedUserDataTF(_:)), for: .editingChanged)
        }
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { (doneAction) in
            let userData = self.userDataAlert.textFields![0].text! as NSObject
            Utile.shared.saveObjectDataToNSUserDefault(saveObject: userData, forKey: C_USER_STANDARD_KEYS.USER_DATA_KEY)
            self.initial()
        })
        if let userData = Utile.shared.loadObjectDataToNSUserDefault(forKey: C_USER_STANDARD_KEYS.USER_DATA_KEY) {
            doneAction.isEnabled = true
            print(userData)
        } else {
            doneAction.isEnabled = false
        }
        userDataAlert.addAction(doneAction)
        self.present(userDataAlert, animated: true, completion: nil)
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Actions", message: "You can perform below listed actions with selected BluetoothLE devices.", preferredStyle: .actionSheet)
        let addToAdvertiserAction = UIAlertAction(title: "Add to Advertiser", style: .default) { (addToAdvertiserAction) in
            self.setAdvertiser()
        }
        actionSheet.addAction(addToAdvertiserAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - IBActions
    @IBAction func onAdvertisersBtn(_ sender: Any) {
        
    }
    
    @IBAction func onLogBtn(_ sender: Any) {
        
    }
    
    @IBAction func onUserDataBtn(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let changeUserDataAction = UIAlertAction(title: "Edit User Data", style: .default) { (changeUserDataAction) in
            self.showAlertForUserData()
        }
        alert.addAction(changeUserDataAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDelegate & UITableviewDataSource
extension ScanPeripheralsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C_TABLEVIEW_CELL_IDS.PERIPHERAL_CELL, for: indexPath) as! PeripheralCell
        
        var deviceName = String()
        if let name = peripherals[indexPath.row].name {
            deviceName = name
        } else {
            deviceName = "N/A"
        }
        let keys = Array(GlobalData.shared.G_Advertisers.keys)
        cell.initial(with: deviceName, and: advertiementDic[peripherals[indexPath.row].identifier.uuidString]!, isAdvertiser: keys.contains(peripherals[indexPath.row].identifier.uuidString))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let keys = Array(GlobalData.shared.G_Advertisers.keys)
        if keys.contains(peripherals[indexPath.row].identifier.uuidString) {
            
        } else {
            self.selectedPeripheral = peripherals[indexPath.row]
            self.showActionSheet()
        }
    }
    
}

//MARK: - CBCentralManagerDelegate
extension ScanPeripheralsVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scan()
            setStatusLayouts(statusMode: .ScanPeripherals)
            refreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(refreshTableView(_:)), userInfo: nil, repeats: true)
            break
        case .poweredOff:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Bluetooth is powered off! Please turn on Bluetooth of your device!")
            setStatusLayouts(statusMode: .PoweredOff)
            refreshTimer = nil
            break
        case .resetting:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Bluetooth is resetting...")
            setStatusLayouts(statusMode: .Resetting)
            refreshTimer = nil
            break
        case .unauthorized:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Bluetooth function for this application is Unautherized!")
            setStatusLayouts(statusMode: .Unauthorized)
            refreshTimer = nil
            break
        case .unknown:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Unkown error!")
            setStatusLayouts(statusMode: .Unknown)
            refreshTimer = nil
            break
        case .unsupported:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "This device is unsupported for Bluetooth!")
            setStatusLayouts(statusMode: .Unsupported)
            refreshTimer = nil
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.identifier.uuidString)
        advertiementDic[peripheral.identifier.uuidString] = advertisementData.description
        
        var index = 0
        var isContained = false
        for pDevice in peripherals {
            if peripheral.identifier.uuidString == pDevice.identifier.uuidString {
                isContained = true
                break
            }
            index += 1
        }
        if isContained {
            updateMTableViewCell(of: index, isAdd: false)
        } else {
            peripherals.append(peripheral)
            peripherals = peripherals.sorted(by: { (first, second) -> Bool in
                return first.identifier.uuidString > second.identifier.uuidString
            })
            var index1 = 0
            for pDevice in peripherals {
                if peripheral.identifier.uuidString == pDevice.identifier.uuidString {
                    break
                }
                index1 += 1
            }
            updateMTableViewCell(of: index1, isAdd: true)
        }
        setAdvertisable()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print(peripheral)
    }
}

extension ScanPeripheralsVC: CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            let serialService = CBMutableService(type: C_BLUETOOTH_DATA.TRANSFER_SERVICE_UUID, primary: true)
            let writeCharacteristics = CBMutableCharacteristic(type: C_BLUETOOTH_DATA.TRANSFER_SERVICE_UUID, properties: .write, value: nil, permissions: .writeable)
            serialService.characteristics = [writeCharacteristics]
            peripheralManager?.add(serialService)
            break
        case .poweredOff:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Bluetooth is powered off! Please turn on Bluetooth of your device!")
            setStatusLayouts(statusMode: .PoweredOff)
            break
        case .resetting:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Bluetooth is resetting...")
            setStatusLayouts(statusMode: .Resetting)
            break
        case .unauthorized:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Bluetooth function for this application is Unautherized!")
            setStatusLayouts(statusMode: .Unauthorized)
            break
        case .unknown:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "Unkown error!")
            setStatusLayouts(statusMode: .Unknown)
            break
        case .unsupported:
            Utile.shared.showAlert(vc: self, title: "Bluetooth status", content: "This device is unsupported for Bluetooth!")
            setStatusLayouts(statusMode: .Unsupported)
            break
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        setAdvertisable()
    }
}
