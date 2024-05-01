//
//  ItemListViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/01.
//

import UIKit

class ItemListViewController: UIViewController {
    @IBOutlet weak var itemListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupItemListTableView()
        // Do any additional setup after loading the view.
    }
    
    private func setupItemListTableView() {
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
    }

}

extension ItemListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        
        cell.itemImageView = UIImageView(image: UIImage(systemName: "person"))
        cell.itemTitleLable.text = "제목"
        cell.itemPriceLable.text = "12,000원"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemListStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let itemListViewController = itemListStoryboard.instantiateViewController(identifier: "ItemDetailViewController") as? ItemDetailViewController else { return }
        itemListViewController.price = 12000
        navigationController?.pushViewController(itemListViewController, animated: true)
    }
}
