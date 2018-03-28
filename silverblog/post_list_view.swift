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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(global_value.server_url + "/control/get_list/post", method: .post, parameters: [:], encoding: JSONEncoding.default).responseString { response in

            let json = JSON(response.result.value)

            if let title = json[0]["title"].string {
                print(title)
            }
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = "abcde"
        return cell
    }

}
