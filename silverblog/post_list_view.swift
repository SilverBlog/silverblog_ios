import UIKit
import Alamofire
import SwiftyJSON
import public_func

class post_list_view: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var array_json = JSON()
    let REFRESH_CONTROL = UIRefreshControl()
    let NET_REACHABILITY_MANAGER = NetworkReachabilityManager()
    let USER_CONFIG = UserDefaults(suiteName: public_func.USER_DEFAULTS_GROUP)!
    
    @IBOutlet weak var more_button_outlet: UIBarButtonItem!
    
    @IBAction func on_more_button_click(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Action", message: "Please select action", preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: "New", style: .default,handler: { (action: UIAlertAction!) -> () in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let edit_post = sb.instantiateViewController(withIdentifier: "edit_post_view") as! edit_post_view
            edit_post.new_mode = true
            self.navigationController!.pushViewController(edit_post, animated: true)
        }))
        actionSheetController.addAction(UIAlertAction(title: "Publish", style: .default,handler: {(action: UIAlertAction!) -> () in
            self.publish_click()
        }))
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        if let popover = actionSheetController.popoverPresentationController {
            popover.barButtonItem  = self.tabBarController?.navigationItem.rightBarButtonItem
             popover.permittedArrowDirections = .up
        }

        self.present(actionSheetController, animated: true, completion: nil)
    }
    

    func publish_click() {
        if (NET_REACHABILITY_MANAGER?.isReachable == false) {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let doneController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        doneController.view.addSubview(loadingIndicator)
        self.present(doneController, animated: true, completion: nil)
        let timestamp = public_func.get_timestamp()
        let sign = public_func.hmac_hex(hashName: "SHA512", message: "git_page_publish", key: global_value.password+String(timestamp))

        let param = ["sign" : sign,"send_time" : timestamp] as [String : Any]
        AF.request(get_url.Publish(server_url: global_value.server_url), method: .post, parameters: param, encoding: JSONEncoding.default).validate().responseJSON { response in
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
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                case .failure:
                    let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error: (response.response?.statusCode)!), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController!.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.never
        self.tabBarController!.navigationItem.setRightBarButton(more_button_outlet, animated: true)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.REFRESH_CONTROL.addTarget(self, action: #selector(post_list_view.refresh), for: .valueChanged)
        self.tableView.backgroundColor = UIColor.systemBackground
        self.tableView.refreshControl = REFRESH_CONTROL


    }
    @objc func becomeActive(){
        if (USER_CONFIG.bool(forKey: "refresh")){
            USER_CONFIG.set(false, forKey: "refresh")
            USER_CONFIG.synchronize()
            refresh_pull()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(post_list_view.becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        if (global_value.refresh || array_json == JSON()) {
            global_value.refresh = false
            if (NET_REACHABILITY_MANAGER?.isReachable == false) {
                let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            refresh_pull()
        }
        self.tabBarController!.title = "Post"
    
    }
    func refresh_pull(){
        self.tableView.setContentOffset(CGPoint(x:0, y:self.tableView.contentOffset.y - (self.REFRESH_CONTROL.frame.size.height)), animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            self.REFRESH_CONTROL.sendActions(for: .valueChanged)
        })
    }
    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        if (NET_REACHABILITY_MANAGER?.isReachable == false) {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ action in refreshControl.endRefreshing()} ))
            self.present(alert, animated: true, completion: nil)
            return
        }
        AF.request(get_url.get_list(server_url:global_value.server_url, list_name:"post"), method: .get).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.value {
                    let jsonobj = JSON(value)
                    self.array_json = jsonobj
                    self.tableView.reloadData()
                    refreshControl.endRefreshing()
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error: error.responseCode ?? -1), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in refreshControl.endRefreshing()}))
                    self.present(alert, animated: true, completion: nil)
            }
            
        }
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (NET_REACHABILITY_MANAGER?.isReachable == false) {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let alertController = UIAlertController(title: "Warning！", message: "Are you sure you want to delete this article?", preferredStyle: UIAlertController.Style.alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) { (ACTION) in
            let send_time = public_func.get_timestamp()
            let parameters: Parameters = [
                "post_uuid": self.array_json[indexPath.row]["uuid"].string!,
                "sign": public_func.hmac_hex(hashName: "SHA512", message: self.array_json[indexPath.row]["uuid"].string!+self.array_json[indexPath.row]["title"].string!+self.array_json[indexPath.row]["name"].string!, key: global_value.password+String(send_time)),
                "send_time": send_time
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
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        doneController.view.addSubview(loadingIndicator)
        self.present(doneController, animated: true, completion: nil)
        AF.request(get_url.delete(server_url:global_value.server_url), method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            doneController.dismiss(animated: true)
            switch response.result {
            case .success(let json):
                let dict = json as! Dictionary<String, AnyObject>
                let status = dict["status"] as! Bool
                if (!status) {
                    let alert = UIAlertController(title: "Failure", message: "Delete failed.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                if (status) {
                    self.refresh_pull()
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error: error.responseCode ?? -1), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let story_board = UIStoryboard(name: "Main", bundle: nil)
        
        let edit_post_view_control = story_board.instantiateViewController(withIdentifier: "edit_post_view") as! edit_post_view
        
        let parameters: Parameters = [
            "post_uuid": array_json[indexPath.row]["uuid"].string!
        ]
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        alertController.view.addSubview(loadingIndicator)
        self.present(alertController, animated: true, completion: nil)
        AF.request(get_url.get_content(server_url:global_value.server_url, list_name:"post"), method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            alertController.dismiss(animated: true){
                switch response.result {
                case .success:
                    if let value = response.value {
                        edit_post_view_control.json = JSON(value)
                        edit_post_view_control.uuid = self.array_json[indexPath.row]["uuid"].string!
                        self.navigationController!.pushViewController(edit_post_view_control, animated: true)
                    }
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Failure", message: public_func.get_error_message(error: error.responseCode ?? -1), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Delete"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array_json.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = self.array_json[indexPath.row]["title"].string
        return cell
    }
}
