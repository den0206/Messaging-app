//
//  ChatsViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import  FirebaseFirestore

class ChatsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats : [NSDictionary] = []
    
    var recentsListner : ListenerRegistration!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Messages"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        loadRecentsChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        recentsListner.remove()
    }
    
    //MARK: Load recent
    private func loadRecentsChats() {
        
        recentsListner = firebaseReferences(.Recent).whereField(kUSERID, isEqualTo: FUser.currentID()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                // change snapshot to NSDictionary
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        
                        self.recentChats.append(recent)
                    }
                }
                self.tableView.reloadData()
                print(self.recentChats.count)
            }
        })
    }
    
    //MARK: IBActions
    
    
    @IBAction func createNewChatsButtonPressed(_ sender: Any) {
        let usersVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC") as! UsersTableViewController
        
        navigationController?.pushViewController(usersVC, animated: true)
    }
    
  
}

extension ChatsViewController : UITableViewDelegate, UITableViewDataSource{
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var recent : NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentsTableViewCell
        
        recent = recentChats[indexPath.row]
        
        cell.delegate = self
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

}

extension ChatsViewController : RecentTableViewCellDelegate {
    
    //MARK: Recent Cell Delagate
    
    func avatarTapped(indexpath: IndexPath) {
        
        var recent : NSDictionary!
        
        recent = recentChats[indexpath.row]
        
        if recent[kTYPE] as! String == kPRIVATE {
            firebaseReferences(.User).document(recent[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {return}
                
                if snapshot.exists {
                    let userDictionary = snapshot.data() as! NSDictionary
                    let user = FUser(_dictionary: userDictionary)
                    
                    self.showProfile(user: user)
                }
            }
        }
        
    }
    
    private func showProfile(user : FUser) {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as! ProfileTableViewController
        
        profileVC.user = user
        
        navigationController?.pushViewController(profileVC, animated: true)
        
        
    }
    
    
}
