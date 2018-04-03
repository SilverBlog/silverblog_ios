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
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.refreshControl = refreshControl
        self.tabBarController!.title="Menu"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(global_value.reflush || array_json==JSON()){
           global_value.reflush = false
           self.load_data()
        }
        
    }
    func load_data(){
        let alertController = UIAlertController(title: "Now Loading, please wait...", message: "", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        Alamofire.request(global_value.server_url + "/control/get_list/menu", method: .post, parameters: [:], encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result.isSuccess {
            case true:
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if let value = response.result.value {
                    self.array_json = JSON(value)
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            case false:
                let alert = UIAlertController(title: "Failure", message: response.result.error as! String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @objc func refresh(refreshControl: UIRefreshControl) {
        load_data()

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "edit_post_view") as! edit_post_view
        vc.row = indexPath.row
        vc.menu = true
        self.navigationController!.pushViewController(vc, animated:true)

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
