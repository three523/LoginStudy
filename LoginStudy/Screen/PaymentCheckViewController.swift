//
//  PaymentCheckViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/01.
//

import UIKit

final class PaymentCheckViewController: BottomSheetViewController {
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var myPointLabel: UILabel!
    @IBOutlet weak var pointTextfield: UITextField!
    @IBOutlet weak var paymentPriceLabel: UILabel!
    @IBOutlet weak var usingPointLabel: UILabel!
    @IBOutlet weak var totalPaymentPriceLabel: UILabel!
    
    var pointManager: PointManager?
    var itemName: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.itemTitleLabel.text = self.itemName
            }
        }
    }
    var paymentPrice: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.paymentPriceLabel.text = "\(self.paymentPrice)원"
                self.updateTotalPaymentPrice()
            }
        }
    }
    var presentingVCDismissAction: (() -> Void)?
    private var totalPoint: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.myPointLabel.text = "\(self.totalPoint) 사용가능"
            }
        }
    }
    private var usingPoint: Int = 0 {
        didSet {print(usingPoint)
            DispatchQueue.main.async {
                self.usingPointLabel.text = "-\(self.usingPoint)원"
                self.updateTotalPaymentPrice()
            }
        }
    }
    private var totalPaymentPrice: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.totalPaymentPriceLabel.text = "\(self.totalPaymentPrice)원"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        guard pointManager != nil else {
            print("point manager의 값이 nil 입니다.")
            return
        }
        setupTotalPoint()
    }
    
    private func setupTextField() {
        pointTextfield.delegate = self
    }
    
    private func setupTotalPoint() {
        guard let pointManager else { return }
        self.totalPoint = pointManager.getTotalPoint()
    }
    
    private func updateTotalPaymentPrice() {
        totalPaymentPrice = paymentPrice - usingPoint
    }
    @IBAction func payment(_ sender: Any) {
        pointManager?.subtractPoint(usedPoint: usingPoint)
        presentingVCDismissAction?()
        dismiss(animated: true)
    }
    
}

extension PaymentCheckViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("replacement: \(string)")
        if string.isEmpty {
            guard let text = pointTextfield.text else { return false }
            if text.count <= 1 {
                textField.text = String(0)
                return false
            } else {
                return true
            }
        }
        return Int(string) != nil
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("empty \(usingPointLabel.text!.isEmpty)\(pointTextfield.text!)")
        if let text = pointTextfield.text {
            if text.isEmpty {
                usingPoint = 0
                textField.text = "0"
            } else if let point = Int(text) {
                if point > totalPoint {
                    let totalPrice = paymentPrice - totalPoint
                    usingPoint = totalPrice < 0 ? totalPoint + totalPrice : totalPoint
                    textField.text = String(usingPoint)
                } else {
                    usingPoint = point
                    textField.text = String(point)
                }
            }
        }
    }
}
