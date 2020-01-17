//
//  LoginViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/14.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class LoginViewController: UIViewController {
    
    let logoContainerView : UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        
        
        return view
    }()
    
    let dontHaveAccountButton : UIButton = {
        let button = UIButton(type: .system)
        let attributeTitle = NSMutableAttributedString(string: "アカウントを持っていませんか?   ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributeTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.addTarget(self, action: #selector(showSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributeTitle, for: .normal)
        
        return button
        
    }()
    
    let HUD  = JGProgressHUD(style: .dark)
    var activityIndicator : NVActivityIndicatorView?
    
    
    
    //MARK: StroyBoard
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
   
    //MARK: Lffe Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButtonOutlet.isEnabled = false
        
        navigationController?.isNavigationBarHidden = true

        configureLogoComponents()
        
        configureViewComponets()
        
        addTextfieldActions()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), padding: nil)
    }
    
    //MARK: Configure VIew
    
    private func configureLogoComponents() {
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 150)
        
    }
    
    private func configureViewComponets() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButtonOutlet])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 170)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 70, paddingRight: 0, width: 0, height: 0)
    }
    
    private func addTextfieldActions() {
        emailTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
    }
    
    
    //MARK: IBActios
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        guard isValidEmail(emailTextField.text!) else {
            HUD.textLabel.text = "Eメール用の書式を記入ください"
            HUD.indicatorView = JGProgressHUDErrorIndicatorView()
            HUD.show(in: self.view)
            HUD.dismiss(afterDelay: 3.0)
            return
            
        }
        
        startIndicator()
        
        FUser.loginUser(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error != nil {
                self.hideIndicator()
                
                self.HUD.textLabel.text = "\(error!.localizedDescription)"
                self.HUD.indicatorView = JGProgressHUDErrorIndicatorView()
                self.HUD.show(in: self.view)
                self.HUD.dismiss(afterDelay: 3.0)
                return
            }
            
            self.hideIndicator()
            
            self.goToApp()
        }
        
    }
    
    @IBAction func tappedBackground(_ sender: Any) {
        
        self.view.endEditing(false)
    }
    
    
    @objc func valitation() {
        
        guard emailTextField.text != "" , passwordTextField.text != ""  else {
            loginButtonOutlet.isEnabled = false
            loginButtonOutlet.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            return
        }
        
        loginButtonOutlet.isEnabled = true
        loginButtonOutlet.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
    }
    
    
    
    @objc func showSignUp() {
        let signUpVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
        
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func goToApp() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kOBJECTID : FUser.currentID()])
        
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! MainTabVC
        
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
    
    //MARK: ActivityIndicator
    
    private func startIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }
    }
    
    private func hideIndicator() {
        
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator?.stopAnimating()
        }
    }

  
}
