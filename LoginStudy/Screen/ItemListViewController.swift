//
//  ItemListViewController.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/01.
//

import UIKit

final class ItemListViewController: UIViewController {
    @IBOutlet weak var itemListTableView: UITableView!
    private var itemList: [Item] = [Item(image: UIImage(systemName: "pencil.line"), price: 500, name: "연필", description: "글을 쓰고 지울수 있습니다"), Item(image: UIImage(systemName: "eraser.fill"), price: 300, name: "지우개", description: "연필로 쓴 내용을 지울때 사용합니다")]
    private var pointManager: PointManager = PointManager(userInfo: UserInfo(point: 1200))
    
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
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        
        let item = itemList[indexPath.row]
        
        cell.itemImageView.image = item.image
        cell.itemTitleLable.text = item.name
        cell.itemPriceLable.text = "\(item.price)원"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemListStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let itemListViewController = itemListStoryboard.instantiateViewController(identifier: "ItemDetailViewController") as? ItemDetailViewController else { return }
        itemListViewController.item = itemList[indexPath.row]
        itemListViewController.pointManager = pointManager
        navigationController?.pushViewController(itemListViewController, animated: true)
    }
}
