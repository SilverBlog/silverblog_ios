import UIKit
import Alamofire
import SwiftyJSON
import public_func

class menu_list_view: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var array_json = JSON()
    let refreshControl = UIRefreshControl()
    let net = NetworkReachabilityManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.refreshControl = refreshControl
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (global_value.refresh || array_json == JSON()) {
            global_value.refresh = false
            if net?.isReachable == false {
                let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            refresh_pull()
        }
        self.tabBarController!.title = "Menu"

    }
    func refresh_pull(){
        self.tableView.setContentOffset(CGPoint(x:0, y:self.tableView.contentOffset.y - (self.refreshControl.frame.size.height)), animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            self.refreshControl.sendActions(for: .valueChanged)
        })
    }

    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        if net?.isReachable == false {
            let alert = UIAlertController(title: "Failure", message: "No network connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                refreshControl.endRefreshing()
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        AF.request("https://" + global_value.server_url + "/control/v2/get/list/menu", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if array_json[indexPath.row]["absolute"].string != nil {
            let url = URL(string: array_json[indexPath.row]["absolute"].string!)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let edit_post_view_control = sb.instantiateViewController(withIdentifier: "edit_post_view") as! edit_post_view
        //load
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
        AF.request("https://" + global_value.server_url + "/control/"+public_func.version+"/get/content/menu", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            alertController.dismiss(animated: true){
                switch response.result {
                case .success:
                    if let value = response.value {
                        edit_post_view_control.json = JSON(value)
                        edit_post_view_control.uuid = self.array_json[indexPath.row]["uuid"].string!
                        edit_post_view_control.function = "menu"
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array_json.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = self.array_json[indexPath.row]["title"].string
        return cell
    }
}
