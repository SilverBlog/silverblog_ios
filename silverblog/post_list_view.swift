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
    var array_json = JSON()
    let refreshControl = UIRefreshControl()
    let net = NetworkReachabilityManager()
    @IBOutlet weak var publish_button: UIBarButtonItem!

    @IBAction func publish_click(_ sender: Any) {
        if net?.isReachable == false {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let doneController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        doneController.view.addSubview(loadingIndicator)
        self.present(doneController, animated: true, completion: nil)
        Alamofire.request("https://" + global_value.server_url + "/control/git_page_publish", method: .post, parameters: [:], encoding: JSONEncoding.default).validate().responseJSON { response in
            doneController.dismiss(animated: true) {
                switch response.result {
                case .success(let json):
                    let dict = json as! Dictionary<String, AnyObject>
                    let status = dict["status"] as! Bool
                    var message = "Publish failed."
                    if (status) {
                        message = "Publish success."
                    }
                    let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    let alert = UIAlertController(title: "Failure", message: error as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController!.navigationItem.setRightBarButton(publish_button, animated: true)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl


    }
    @objc func becomeActive(){
        let shared = UserDefaults(suiteName: "group.silverblog.client")!
        if (shared.bool(forKey: "refresh")){
            shared.set(false, forKey: "refresh")
            shared.synchronize()
            self.load_data(first_load: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(post_list_view.becomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        if (global_value.reflush || array_json == JSON()) {
            global_value.reflush = false
            if (net?.isReachable == false) {
                let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.load_data(first_load: true)
        }
        self.tabBarController!.title = "Post"
    }

    @objc func refresh(refreshControl: UIRefreshControl) {
        if (net?.isReachable == false) {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.load_data(first_load: false)
    }

    func load_data(first_load: Bool) {
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        if (first_load) {
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            alertController.view.addSubview(loadingIndicator)
            self.present(alertController, animated: true, completion: nil)
        }
        Alamofire.request("https://" + global_value.server_url + "/control/get_list/post", method: .post, parameters: [:], encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result.isSuccess {
            case true:
                if (first_load) {
                    alertController.dismiss(animated: true) {
                    }
                }
                if let value = response.result.value {
                    let jsonobj = JSON(value)
                    if (self.array_json != jsonobj) {
                        self.array_json = jsonobj
                        self.tableView.reloadData()
                    }
                }
            case false:
                let alert = UIAlertController(title: "Failure", message: "This site cannot be connected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                    self.navigationController!.popViewController(animated: true)
                }))
                if (first_load) {
                    alertController.dismiss(animated: true) {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                if (!first_load) {
                    self.present(alert, animated: true, completion: nil)
                }

            }
            self.refreshControl.endRefreshing()
        }

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (net?.isReachable == false) {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let alertController = UIAlertController(title: "Warning！", message: "Are you sure you want to delete this article?", preferredStyle: UIAlertControllerStyle.alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (ACTION) in
            let parameters: Parameters = [
                "post_id": indexPath.row,
                "sign": public_func.md5(String(indexPath.row) + self.array_json[indexPath.row]["title"].string! + global_value.password)
            ]
            self.delete_post(parameters: parameters)
        }
        alertController.addAction(okAction);
        alertController.addAction(CancelAction);
        self.present(alertController, animated: true, completion: nil)

    }

    func delete_post(parameters: Parameters) {
        let doneController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        doneController.view.addSubview(loadingIndicator)
        self.present(doneController, animated: true, completion: nil)
        Alamofire.request("https://" + global_value.server_url + "/control/delete", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            doneController.dismiss(animated: true) {
                switch response.result {
                case .success(let json):
                    let dict = json as! Dictionary<String, AnyObject>
                    let status = dict["status"] as! Bool
                    if (!status) {
                        let alert = UIAlertController(title: "Failure", message: "Delete failed.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    if (status) {
                        self.load_data(first_load: true)
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Failure", message: error as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let edit_post = sb.instantiateViewController(withIdentifier: "edit_post_view") as! edit_post_view
        edit_post.row = indexPath.row
        edit_post.menu = false
        self.navigationController!.pushViewController(edit_post, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
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
