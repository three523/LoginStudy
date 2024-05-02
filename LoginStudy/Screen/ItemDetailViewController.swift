//
//  ItemDetailViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/01.
//

import UIKit
import SwiftyBootpay

final class ItemDetailViewController: UIViewController {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTItleLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemCountTextField: UITextField!
    @IBOutlet weak var totalItemPriceLabel: UILabel!
    @IBOutlet weak var totalPaymentPriceLabel: UILabel!
    @IBOutlet weak var myPointLabel: UILabel!
    @IBOutlet weak var usingPointTextField: UITextField!
    @IBOutlet weak var usingPointLabel: UILabel!
    
    var item: Item? = nil
    private var itemCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                guard let price = self.item?.price else { return }
                self.totalItemPrice = price * self.itemCount
                self.itemCountTextField.text = String(self.itemCount)
            }
        }
    }
    private var totalItemPrice: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.totalItemPriceLabel.text = "\(self.totalItemPrice)"
                self.updateTotalPaymentPrice()
            }
        }
    }
    private var totalPoint: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.myPointLabel.text = "\(self.totalPoint) 사용가능"
            }
        }
    }
    private var usingPoint: Int = 0 {
        didSet {
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
    var pointManager: PointManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        guard let item else {
            print("아이템이 존재하지 않습니다.")
            return
        }
        updateView(item: item)
    }
    
    private func setupTextField() {
        itemCountTextField.delegate = self
        usingPointTextField.delegate = self
    }
    
    @IBAction func payment(_ sender: Any) {
        payment()
    }
    
    func payment() {
        let item1 = BootpayItem().params { item in
            item.item_name = self.item!.name
            item.qty = 1
            item.unique = "1"
            item.price = Double(totalItemPrice)
        }
        
        let userInfo: [String: String] =
        [
            "username": "사용자 이름",
            "email": "user1234@gmail.com",
            "addr": "사용자 주소",
            "phone": "010-1234-4567"
        ]
        
        let customParams: [String: Any] = [
            "isUsedPoint": usingPoint != 0
        ]
        
        let bootUser = BootpayUser()
        bootUser.params {
           $0.username = "사용자 이름"
           $0.email = "user1234@gmail.com"
           $0.area = "서울" // 사용자 주소
           $0.phone = "010-1234-4567"
        }
        
        let payload = BootpayPayload()
        payload.params { payload in
            payload.price = Double(totalPaymentPrice)
            payload.application_id = BOOTPAY_KEY
            payload.name = self.item!.name
            payload.order_id = "1"
            payload.params = customParams
        }
        
        let extra = BootpayExtra()
        extra.quotas = [0, 2, 3]
        extra.popup = 1
        
        var items = [BootpayItem]()
        items.append(item1)
        
        Bootpay.request(self, sendable: self, payload: payload, user: bootUser, items: items, extra: extra, addView: false)
    }
    
    @IBAction func subtractItemCount(_ sender: Any) {
        if itemCount == 0 { return }
        itemCount -= 1
    }
    
    @IBAction func addItemCount(_ sender: Any) {
        itemCount += 1
    }
    
    private func updateTotalPaymentPrice() {
        totalPaymentPrice = totalItemPrice - usingPoint
    }
    
    private func updateTotalPrice() {
        guard let itemCountText = itemCountTextField.text,
              let itemCount = Int(itemCountText),
              let price = item?.price else { return }
        let totalPrice = itemCount * price
        self.totalItemPrice = totalPrice
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updateView(item: Item) {
        self.item = item
        DispatchQueue.main.async {
            self.itemImageView.image = item.image
            self.itemTItleLabel.text = item.name
            self.itemDescriptionLabel.text = item.description
            if let pointManager = self.pointManager {
                self.totalPoint = pointManager.getTotalPoint()
            }
        }
        updateTotalPrice()
    }
}

extension ItemDetailViewController: BootpayRequestProtocol {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print("error")
        print(data)
    }

    // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.
    func onReady(data: [String: Any]) {
        print("ready")
        print(data)
    }

    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print("confirm")

        var iWantPay = true
        if iWantPay == true {  // 재고가 있을 경우.
            Bootpay.transactionConfirm(data: data) // 결제 승인
        } else { // 재고가 없어 중간에 결제창을 닫고 싶을 경우
            Bootpay.dismiss() // 결제창 종료
        }
    }

    func onCancel(data: [String: Any]) {
        print("cancel")
    }
    func onDone(data: [String: Any]) {
        guard let price = data["price"] as? Double,
              let params = data["params"] as? [String: Any],
              let isUsedPoint = params["isUsedPoint"] as? Bool
            else { return }
        if isUsedPoint {
            pointManager?.subtractPoint(usedPoint: usingPoint)
        } else {
            pointManager?.addPoint(price: Int(price))
        }
    }

    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("close")
        Bootpay.dismiss() // 결제창 종료
    }
}

extension ItemDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            guard let text = textField.text else { return false }
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
        if textField == itemCountTextField {
            totalItemPriceUpdate(textField: textField)
        } else if textField == usingPointTextField {
            updateUsingPoint(textField: textField)
        }
        updateTotalPrice()
    }
    
    func totalItemPriceUpdate(textField: UITextField) {
        if let text = itemCountTextField.text {
            if text.isEmpty {
                itemCount = 0
            } else if let itemCount = Int(text) {
                self.itemCount = itemCount
            }
        }
    }
    
    func updateUsingPoint(textField: UITextField) {
        if let text = textField.text {
            if text.isEmpty {
                usingPoint = 0
            } else if let point = Int(text) {
                if point > totalPoint {
                    let totalPrice = totalItemPrice - totalPoint
                    usingPoint = totalPrice < 0 ? totalPoint + totalPrice : totalPoint
                } else {
                    let totalPrice = totalItemPrice - point
                    usingPoint = totalPrice < 0 ? point + totalPrice : point
                }
                textField.text = String(usingPoint)
            }
        }
    }
}
