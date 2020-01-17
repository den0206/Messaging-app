//
//  ChatsViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Messages"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()

    }
    
    //MARK: IBActions
    
    
    @IBAction func createNewChatsButtonPressed(_ sender: Any) {
        let usersVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC") as! UsersTableViewController
        
        navigationController?.pushViewController(usersVC, animated: true)
    }
    
  
}

extension ChatsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentsTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    
}
