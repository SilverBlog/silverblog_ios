import UIKit
import Alamofire
import SwiftyJSON
import public_func

class post_list_view: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var array_json = JSON()
    let refreshControl = UIRefreshControl()
    let net = NetworkReachabilityManager()
    let shared = UserDefaults(suiteName: public_func.group_suite)!
    
    @IBOutlet weak var more_button_outlet: UIBarButtonItem!
    
    
    @IBAction func on_more_button_click(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Action", message: "Please select action", preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: "New", style: .default,handler: { (action: UIAlertAction!) -> () in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let edit_post = sb.instantiateViewController(withIdentifier: "edit_post_view") as! edit_post_view
            edit_post.new_mode = true
            edit_post.menu = false
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
        if (net?.isReachable == false) {
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
        AF.request("https://" + global_value.server_url + "/control/"+public_func.version+"/git_page_publish", method: .post, parameters: param, encoding: JSONEncoding.default).validate().responseJSON { response in
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
        self.refreshControl.addTarget(self, action: #selector(post_list_view.refresh), for: .valueChanged)
        
        self.tableView.refreshControl = refreshControl


    }
    @objc func becomeActive(){
        if (shared.bool(forKey: "refresh")){
            shared.set(false, forKey: "refresh")
            shared.synchronize()
            refresh_pull()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(post_list_view.becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        if (global_value.refresh || array_json == JSON()) {
            global_value.refresh = false
            if (net?.isReachable == false) {
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
        self.tableView.setContentOffset(CGPoint(x:0, y:self.tableView.contentOffset.y - (self.refreshControl.frame.size.height)), animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            self.refreshControl.sendActions(for: .valueChanged)
        })
    }
    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        if (net?.isReachable == false) {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ action in refreshControl.endRefreshing()} ))
            self.present(alert, animated: true, completion: nil)
            return
        }
        AF.request("https://" + global_value.server_url + "/control/v2/get/list/post", method: .get).validate().responseJSON { response in
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
                let alert = UIAlertController(title: "Failure", message: "This site cannot be connected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in refreshControl.endRefreshing()}))
                    self.present(alert, animated: true, completion: nil)
            }
            
        }
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (net?.isReachable == false) {
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
                //"sign": public_func.md5(String(indexPath.row) + self.array_json[indexPath.row]["title"].string! + global_value.password)
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
        AF.request("https://" + global_value.server_url + "/control/v2/delete", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
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
                let alert = UIAlertController(title: "Failure", message: "error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let edit_post = sb.instantiateViewController(withIdentifier: "edit_post_view") as! edit_post_view
        edit_post.uuid = array_json[indexPath.row]["uuid"].string!
        edit_post.menu = false
        self.navigationController!.pushViewController(edit_post, animated: true)
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
