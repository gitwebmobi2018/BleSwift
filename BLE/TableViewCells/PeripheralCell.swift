import UIKit

class PeripheralCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak private var lblTimer: UILabel!
    @IBOutlet weak var lblManufacturerData: UILabel!
    
    //MARK: - Properties
    private var timer: Timer?
    private var timeCounter: Double = 0
    
    var expiryTimeInterval: TimeInterval? {
        didSet {
            startTimer()
        }
    }
    
    //MARK: - Override Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Custom Functions
    func initial(with name: String, and adDataDescription: String, isAdvertiser: Bool) {
        lblDeviceName.text = name
        lblManufacturerData.text = adDataDescription
        lblTimer.text = "Registered"
        lblTimer.isHidden = !isAdvertiser
    }
    
    private func startTimer() {
        if let interval = expiryTimeInterval {
            timeCounter = interval
            if #available(iOS 10.0, *) {
                timer = Timer(timeInterval: 1.0,
                              repeats: true,
                              block: { [weak self] _ in
                                guard let strongSelf = self else {
                                    return
                                }
                                strongSelf.onComplete()
                })
            } else {
                timer = Timer(timeInterval: 1.0,
                              target: self,
                              selector: #selector(onComplete),
                              userInfo: nil,
                              repeats: true)
            }
        }
    }
    
    //MARK: - @objc Functions
    @objc func onComplete() {
        guard timeCounter >= 0 else {
            timer?.invalidate()
            timer = nil
            return
        }
        lblTimer.text = String(format: "%d", timeCounter)
        timeCounter -= 1
    }

}
