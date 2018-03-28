//
//  menu_list_view.swift
//  silverblog
//
//  Created by qwe7002 on 2018/3/28.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class menu_list_view: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var array_json = JSON()
    override func viewDidLoad() {
        super.viewDidLoad()
        let alertController = UIAlertController(title: "Now Loading, please wait...", message: "", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        self.load_data()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func load_data(){
        Alamofire.request(global_value.server_url + "/control/get_list/menu", method: .post, parameters: [:], encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result.isSuccess {
            case true:
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if let value = response.result.value {
                    self.array_json = JSON(value)
                    print(self.array_json)
                    self.tableView.reloadData()
                }
            case false:
                print(response.result.error)
            }
        }
    }
    @objc func refresh(refreshControl: UIRefreshControl) {
        load_data()
        refreshControl.endRefreshing()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array_json.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = self.array_json[indexPath.row]["title"].string
        return cell
    }
}
