//
//  MainTabVC.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/16.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

       checkUserLogin()
    }
    
    private func checkUserLogin() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                
                let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                
                let navigationVC = UINavigationController(rootViewController: loginVC)
                navigationVC.modalPresentationStyle = .fullScreen
                self.present(navigationVC, animated: true, completion: nil)
                
                return
            }
        }
    }
    

}
