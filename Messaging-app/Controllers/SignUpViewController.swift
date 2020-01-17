//
//  SignUpViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/14.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView
import Firebase

class SignUpViewController: UIViewController {
    
    //MARK: Vars
    
    let plusPhotoButton : UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal) , for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
        
    }()
    
    //MARK: Storyboard
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var signupButtonOutlet: UIButton!
    
    let alreadtHaveAccountButton : UIButton = {
        let button = UIButton(type: .system)
        let attributeTitle = NSMutableAttributedString(string: "アカウントを持っている方は   ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributeTitle.append(NSAttributedString(string: "Log In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.addTarget(self, action: #selector(showLogin), for: .touchUpInside)
        button.setAttributedTitle(attributeTitle, for: .normal)
        
        return button
        
    }()
    
    var avatarImage : UIImage!
    
    let HUD  = JGProgressHUD(style: .dark)
    var activityIndicator : NVActivityIndicatorView?
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupButtonOutlet.isEnabled = false

        configureStoryBoardParts()
        
        addTextfieldAction()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.width / 2 - 30, y: view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), padding: nil)
    }
    
    //MARK: Configure View
    
    private func configureStoryBoardParts() {
        
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,rePasswordTextField,firstNameTextField,lastNameTextField,signupButtonOutlet])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 270)
        
        view.addSubview(alreadtHaveAccountButton)
        alreadtHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 70, paddingRight: 0, width: 0, height: 50)
    }
    
    private func addTextfieldAction() {
        
        emailTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
        rePasswordTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(valitation), for: .editingChanged)
        
    }
    
    
    
    //MARK: IBActions
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        
        guard isValidEmail(emailTextField.text!) else {
            HUD.textLabel.text = "Eメール用の書式を記入ください"
            HUD.indicatorView = JGProgressHUDErrorIndicatorView()
            HUD.show(in: self.view)
            HUD.dismiss(afterDelay: 3.0)
            return
            
        }
        
        guard passwordTextField.text! == rePasswordTextField.text! else {
            HUD.textLabel.text = "確認用パスワードが一致しません"
            HUD.indicatorView = JGProgressHUDErrorIndicatorView()
            HUD.show(in: self.view)
            HUD.dismiss(afterDelay: 3.0)
            return
        }
        
        FUser.registerUser(email: emailTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (error) in
            
            self.startIndicator()
            
            if error != nil {
                self.hideIndicator()
                
                self.HUD.textLabel.text = "\(error?.localizedDescription)"
                self.HUD.indicatorView = JGProgressHUDErrorIndicatorView()
                self.HUD.show(in: self.view)
                self.HUD.dismiss(afterDelay: 3.0)
                return
            }
            
            self.regstration()
            
        }
    
    }
    
    private func regstration() {
        
        let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
        
        var tempDictionary :Dictionary =
            [kFISRSTNAME : firstNameTextField.text!,
             kLATNAME : lastNameTextField.text!,
             kFULLNAME : fullName] as [String : Any]
        
        if avatarImage == nil {
            
            imageFromInitials(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (initialAvatar) in
                
                let avatarData = initialAvatar.jpegData(compressionQuality: 0.3)
                let avatar = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                self.fiinishRegistration(withValues: tempDictionary)
                
            }
        } else {
            
            let avatarData = avatarImage.jpegData(compressionQuality: 0.3)
            let avatar = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDictionary[kAVATAR] = avatar
            
            self.fiinishRegistration(withValues: tempDictionary)
            
        }
 
        
    }
    
    private func fiinishRegistration(withValues : [String : Any] ) {
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                self.HUD.textLabel.text = "\(error?.localizedDescription)"
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
    
    
    @objc func showLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func valitation() {
        guard emailTextField.text != "", passwordTextField.text != "", rePasswordTextField.text != "", firstNameTextField.text != "", lastNameTextField.text != "" else {
            
            signupButtonOutlet.isEnabled = false
            signupButtonOutlet.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            return
        }
        
        signupButtonOutlet.isEnabled = true
        signupButtonOutlet.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
    }
    
    private func goToApp() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kOBJECTID : FUser.currentID()])
        
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! MainTabVC
        
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
    
    //MARK: Activity Indicator
    
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

extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func buttonTapped() {
        
        let camera = Camera(delegate_: self)
        
        camera.PresentPhotoLibrary(target: self, canEdit: false)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let picture = info[.originalImage] as? UIImage
        
        avatarImage = picture
        plusPhotoButton.setImage(avatarImage.circleMasked!.withRenderingMode(.alwaysOriginal), for: .normal)
        
        print(avatarImage!)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
