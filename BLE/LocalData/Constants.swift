import Foundation
import CoreBluetooth

let CHARACTERISTIC_UUID = "08590F7E-DB05-467E-8757-72F6F66666D4"
let SERVICE_NAME = "Lecturer"
let NOTIFY_MTU = 20

let transferCharacteristicUUID = CBUUID(string: CHARACTERISTIC_UUID)

var LECTURER_NAME = "Lecturer"

var STUDENT_NAME = "Student"
var STUDENT_ID = "Student ID"
var STUDENT_COMMENT = "Student comment"

struct C_TABLEVIEW_CELL_IDS {
    static let PERIPHERAL_CELL = "PeripheralCellID"
}

struct C_USER_STANDARD_KEYS {
    static let USER_DATA_KEY = "user_advertisement_data_key"
    static let ADVERTISERS_KEY = "ADVERTISERS_KEY"
}

struct C_BLUETOOTH_DATA {
    static let SERVICE_UUID = "0000B81D-0000-1000-8000-00805F9B34FB"
//    static let SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD666661"
    static let TRANSFER_SERVICE_UUID = CBUUID(string: C_BLUETOOTH_DATA.SERVICE_UUID)
}

struct C_APP_INFO {
    static let APP_ID = "com.duulygmbh.duuly.BluetoothLE"
}
