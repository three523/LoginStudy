//
//  ItemDetailViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/01.
//

import UIKit

final class ItemDetailViewController: UIViewController {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTItleLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemCountTextField: UITextField!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var item: Item? = nil
    private var totalPrice: Int = 0
    var pointManager: PointManager? = PointManager(userInfo: UserInfo(point: 1200))
    
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
    }
    @IBAction func payment(_ sender: Any) {
        let paymentCheckStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let paymentCheckViewController = paymentCheckStoryboard.instantiateViewController(identifier: "PaymentCheckViewController") as? PaymentCheckViewController else { return }
        paymentCheckViewController.modalPresentationStyle = .custom
        paymentCheckViewController.transitioningDelegate = self
        paymentCheckViewController.pointManager = pointManager
        paymentCheckViewController.paymentPrice = totalPrice
        paymentCheckViewController.presentingVCDismissAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        present(paymentCheckViewController, animated: true)
    }
    
    @IBAction func subtractItemCount(_ sender: Any) {
        if let itemCountText = itemCountTextField.text,
           let count = Int(itemCountText) {
            if count == 0 { return }
            itemCountTextField.text = String(count - 1)
            updateTotalPrice()
        }
    }
    
    @IBAction func addItemCount(_ sender: Any) {
        if let itemCountText = itemCountTextField.text,
           let count = Int(itemCountText) {
            itemCountTextField.text = String(count + 1)
            updateTotalPrice()
        }
    }
    
    private func updateTotalPrice() {
        guard let itemCountText = itemCountTextField.text,
              let itemCount = Int(itemCountText),
              let price = item?.price else { return }
        let totalPrice = itemCount * price
        DispatchQueue.main.async {
            self.totalPriceLabel.text = "\(totalPrice)원"
        }
        self.totalPrice = totalPrice
    }
    
    func updateView(item: Item) {
        self.item = item
        DispatchQueue.main.async {
            self.itemImageView.image = item.image
            self.itemTItleLabel.text = item.name
            self.itemDescriptionLabel.text = item.description
        }
        updateTotalPrice()
    }
}

extension ItemDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("replacement: \(string)")
        if string.isEmpty {
            guard let text = itemCountTextField.text else { return false }
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
        print("empty \(itemCountTextField.text!.isEmpty)\(itemCountTextField.text!)")
        if let text = itemCountTextField.text {
            if text.isEmpty {
                textField.text = "0"
            } else if let itemCount = Int(text) {
                textField.text = String(itemCount)
            }
        }
        updateTotalPrice()
    }
}

extension ItemDetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting, size: 0.5)
    }
}
