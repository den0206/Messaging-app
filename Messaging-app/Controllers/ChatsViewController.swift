//
//  ChatsViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController {
    
    
    @IBOutlet weak var searchOptionView: UIView! {
        didSet {
            searchOptionView.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchButtonOutlet: UIButton!
    @IBOutlet weak var hideButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats : [NSDictionary] = []
    var filterdChats : [NSDictionary] = []
    
    var recentsListner : ListenerRegistration!
    
     let searchController = UISearchController(searchResultsController: nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Messages"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        
        
        searchAreaConstraint()
        

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
               
            }
        })
    }
    
    //MARK: IBActions
    
    
    @IBAction func createNewChatsButtonPressed(_ sender: Any) {
        let usersVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC") as! UsersTableViewController
        
        navigationController?.pushViewController(usersVC, animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchController.searchBar.searchTextField.text = searchTextField.text
        filterContentForText(searchText: searchController.searchBar.searchTextField.text!)
    }
    
    
    @IBAction func hideButtonPressed(_ sender: Any) {
        
         animateSearchOptionIn()
    }
    
  
    
    
}

//MARK: tableView Delegare

extension ChatsViewController : UITableViewDelegate, UITableViewDataSource{
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  searchTextField.text != "" {
            return filterdChats.count
        } else {
            return recentChats.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var recent : NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentsTableViewCell
        
        if searchTextField.text != "" {
            recent = filterdChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        
        
        
        cell.delegate = self
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent : NSDictionary
        
        if searchTextField.text != "" {
            recent = filterdChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        
        let messageVC = MessageViewController()
        messageVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        messageVC.memberIds = (recent[kMEMBERS] as? [String])!
        messageVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        
        navigationController?.pushViewController(messageVC, animated: true)
        
        
    }

}

extension ChatsViewController : RecentTableViewCellDelegate {
    
    //MARK: Recent Cell Delagate
    
    func avatarTapped(indexpath: IndexPath) {
        
        var recent : NSDictionary!
        
        if searchTextField.text != "" {
            recent = filterdChats[indexpath.row]
        } else {
            recent = recentChats[indexpath.row]
        }
        
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

extension ChatsViewController : UISearchResultsUpdating, UITextFieldDelegate{
   
    private func searchAreaConstraint() {
    
        searchOptionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: tableView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        searchTextField.anchor(top: searchOptionView.safeAreaLayoutGuide.topAnchor, left: searchOptionView.leftAnchor, bottom: searchOptionView.centerYAnchor, right: searchOptionView.rightAnchor, paddingTop: 14, paddingLeft: 40, paddingBottom: 200, paddingRight: 20, width: 100, height: 40)
       
        searchTextField.placeholder = "Search User..."
        
        let stackView = UIStackView(arrangedSubviews: [searchButtonOutlet, hideButtonOutlet])
        
        stackView.axis = .horizontal
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        
        searchOptionView.addSubview(stackView)
        
        stackView.anchor(top: searchTextField.bottomAnchor, left: searchOptionView.leftAnchor, bottom: searchOptionView.bottomAnchor, right: searchOptionView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingBottom: 10, paddingRight: 30, width: 0, height: 40)
        
        searchTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
    }
    
    private func animateSearchOptionIn() {
        
        let widthConstraint = searchOptionView.widthAnchor.constraint(equalToConstant: 100)
        let heightCofnstrait = searchOptionView.heightAnchor.constraint(equalToConstant: 100)
        UIView.animate(withDuration: 0.5) {
            self.searchOptionView.isHidden = !self.searchOptionView.isHidden
            widthConstraint.isActive = false
            heightCofnstrait.isActive = false
            
        }
//        if self.searchOptionView.isHidden {
//            self.searchOptionView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        } else {
//
//        }
    }
    
    @objc func valitation() {
        guard searchTextField.hasText else {
            searchButtonOutlet.isEnabled = false
            searchButtonOutlet.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            tableView.reloadData()
            return
        }
        searchButtonOutlet.isEnabled = true
        searchButtonOutlet.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    
    }
    
    //MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchController.searchBar.searchTextField.text = searchTextField.text
        filterContentForText(searchText: searchController.searchBar.searchTextField.text!)
        return true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForText(searchText: searchController.searchBar.text!)
        
    }
    
    func filterContentForText(searchText : String, scope : String = "All") {
        
        filterdChats = recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
        print(filterdChats.count)
    }
    
    
}
