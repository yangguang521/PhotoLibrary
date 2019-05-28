//
//  TableViewController.swift
//  PhotoLibrary
//
//  Created by Joe on 2019/5/24.
//  Copyright © 2019年 tony. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet var contentTableView: UITableView!
    private let titleArray = ["检查图库授权状态", "判断自定义相册是否存在", "创建自定义相册", "向系统相册加入图片", "向自定义相册加入图片"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        contentTableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = self.titleArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            self.checkPhotoLibraryAuthorization(resultBlock: nil)
        case 1:
            self.isExistMyPhotoAlbum(resultBlock: nil)
        case 2:
            self.createMyPhotoAlbum()
        case 3:
            self.addPictureToSystemPhotoAlbum()
        case 4:
            self.addPictureToMyCreatedPhotoAlbum()
        default:
            print("--\(indexPath.row)")
        }
    }
    
    //MARK: - 检查图库的权限
    func checkPhotoLibraryAuthorization(resultBlock:((_ isAuthorizated: Bool) -> ())?) {
        PhotoLibraryManager.shared.checkPhotoLibraryAuthorization { (isAuthorizated) in
            if isAuthorizated {
                print("图库得到了授权访问")
                resultBlock?(true)
            }else {
                self.showAlertController(title: nil, msg: "图库被拒绝访问，请前往设置打开访问权限", cancelTitle: "取消", ensureTitle: "打开", cancelBlock: nil, ensureBlock: {
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                })
                resultBlock?(false)
            }
        }
    }
    
    //MARK: - 是否存在自定义相册
    func isExistMyPhotoAlbum(resultBlock:((_ isExist: Bool) -> ())?) {
        self.checkPhotoLibraryAuthorization { [weak self] (isAuthorizated) in
            guard let `self` = self else { return }
            if isAuthorizated {
                let isExist = PhotoLibraryManager.shared.isExistPhotoAlbum(albumName: self.getAppDisplayName())
                if isExist {
                    self.showAlertController(title: nil, msg: "已经存在自定义相册", cancelTitle: nil, ensureTitle: "确定", cancelBlock: nil, ensureBlock: nil)
                }else {
                    self.showAlertController(title: nil, msg: "自定义相册不存在", cancelTitle: nil, ensureTitle: "确定", cancelBlock: nil, ensureBlock: nil)
                }
            }
        }
    }
    
    //MARK: - 创建自定义相册
    func createMyPhotoAlbum() {
        self.checkPhotoLibraryAuthorization { [weak self] (isAuthorizated) in
            guard let `self` = self  else { return }
            if isAuthorizated {
                let isExist = PhotoLibraryManager.shared.isExistPhotoAlbum(albumName: self.getAppDisplayName())
                if isExist {
                    self.showAlertController(title: nil, msg: "已经存在自定义相册", cancelTitle: nil, ensureTitle: "确定", cancelBlock: nil, ensureBlock: nil)
                }else {
                    PhotoLibraryManager.shared.createPhotoAlbum(albumName: self.getAppDisplayName())
                }
            }
        }
    }
    
    //MARK: - 向系统相册添加图片
    func addPictureToSystemPhotoAlbum() {
        self.checkPhotoLibraryAuthorization { [weak self] (isAuthorizated) in
            guard let `self` = self  else { return }
            if isAuthorizated {
                if let image = UIImage(named: "mypicture") {
                    PhotoLibraryManager.shared.addPictureToSystemPhotoAlbum(image: image) { (isSuccess, error) in
                        if isSuccess {
                            self.showAlertController(title: nil, msg: "保存图片到系统相册成功！", cancelTitle: nil, ensureTitle:"确定", cancelBlock: nil, ensureBlock: nil)
                        }else {
                            self.showAlertController(title: nil, msg: "保存图片到系统相册失败！-\(error?.localizedDescription ?? "")", cancelTitle: nil, ensureTitle:"确定", cancelBlock: nil, ensureBlock: nil)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - 向自定义相册添加图片
    func addPictureToMyCreatedPhotoAlbum() {
        self.checkPhotoLibraryAuthorization { [weak self] (isAuthorizated) in
            guard let `self` = self  else { return }
            if isAuthorizated {
                if let image = UIImage(named: "mypicture") {
                    PhotoLibraryManager.shared.addPictureToMyPhotoAlbum(image: image, photoAlbumName: self.getAppDisplayName(), resultBlock: { (isSuccess, error) in
                        if isSuccess {
                            self.showAlertController(title: nil, msg: "保存图片到自定义相册成功！", cancelTitle: nil, ensureTitle:"确定", cancelBlock: nil, ensureBlock: nil)
                        }else {
                            self.showAlertController(title: nil, msg: "保存图片到自定义相册失败！-\(error?.localizedDescription ?? "")", cancelTitle: nil, ensureTitle:"确定", cancelBlock: nil, ensureBlock: nil)
                        }
                    })
                }
            }
        }
    }
    
    
    //MARK: - showAlertController
    func showAlertController(title: String?, msg: String?, cancelTitle: String?, ensureTitle: String?, cancelBlock:(() -> ())?, ensureBlock:(() -> ())?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            if let title = cancelTitle {
                let cancelAction = UIAlertAction(title: title, style: .cancel, handler: { (action) in
                    cancelBlock?()
                })
                alertController.addAction(cancelAction)
            }
            if let title = ensureTitle {
                let ensureAction = UIAlertAction(title: title, style: .default) { (action) in
                    ensureBlock?()
                }
                alertController.addAction(ensureAction)
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - 获得app显示的名字
    func getAppDisplayName() -> String {
        if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        }
        return ""
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
