//
//  post_list_view.swift
//  silverblog
//
//  Created by 黄江华 on 2018/3/28.
//  Copyright © 2018年 qwe7002. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class post_list_view: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var arrjson = JSON()
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(global_value.server_url + "/control/get_list/post", method: .post, parameters: [:], encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result.isSuccess {
            case true:
                if let value = response.result.value {
                    self.arrjson = JSON(value)
                    print(self.arrjson)
                    self.tableView.reloadData()
                }
            case false:
                print(response.result.error)
            }
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.arrjson.count)
        return self.arrjson.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = self.arrjson[indexPath.row]["title"].string
        return cell
    }

}
