//
//  EditUserViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/18.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView
import Firebase


class EditUserViewController: UIViewController {
    
    //MARK: View Items
    let plusPhotoButton : UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        if FUser.currentUser()?.avatar != "" {
            imageFromData(pictureData: FUser.currentUser()!.avatar) { (avatar) in
                button.setImage(avatar?.circleMasked!.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        return button
        
    }()
    
    
    @IBOutlet weak var firstNameTextField: UITextField! {
        didSet {
            firstNameTextField.text = FUser.currentUser()?.firstName
        }
    }
    @IBOutlet weak var lastNameTextField: UITextField! {
        didSet {
            lastNameTextField.text = FUser.currentUser()?.lastName
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.text = FUser.currentUser()?.email
        }
    }
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!

    
    
    //MARK: vars
    
    var avatarImage : UIImage?
    
    let HUD = JGProgressHUD(style: .dark)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstrait()
        
        addTextFieldValitation()
    }
    
    //MARK: IBactions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        guard isValidEmail(emailTextField.text!) else {
            HUD.textLabel.text = "Eメール用の書式を記入ください"
            HUD.indicatorView = JGProgressHUDErrorIndicatorView()
            HUD.show(in: self.view)
            HUD.dismiss(afterDelay: 3.0)
            return
        }
        saveButtonOutlet.isEnabled = false
        
        let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
        var withValues = [kFISRSTNAME :firstNameTextField.text!,
                          kLATNAME : lastNameTextField.text!,
                          kFULLNAME : fullName,
                          kEMAIL : emailTextField.text!]
        
        if avatarImage != nil {
            let avatarData = avatarImage!.jpegData(compressionQuality: 0.3)
            let avatar = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            withValues[kAVATAR] = avatar
        }
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                self.HUD.textLabel.text = error!.localizedDescription
                self.HUD.indicatorView = JGProgressHUDErrorIndicatorView()
                self.HUD.show(in: self.view)
                self.HUD.dismiss(afterDelay: 3.0)
                self.saveButtonOutlet.isEnabled = true
                return
            }
            
            // no error
            self.HUD.textLabel.text = "Update!!"
            self.HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
            self.HUD.show(in: self.view)
            self.HUD.dismiss(afterDelay: 3.0)
            
            self.saveButtonOutlet.isEnabled = true
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        
    }
    
    @IBAction func backGroundTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    //MARK: set Constrait
    
    private func setConstrait() {
        
//        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 20
//        print(navigationBarHeight)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [firstNameTextField,lastNameTextField,emailTextField])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 170)
        
        
    }
    
    private func addTextFieldValitation() {
        
        let textArray = [firstNameTextField,lastNameTextField,emailTextField]
        
        // addtarget to 3 textField
        
        for tf in textArray {
            tf?.addTarget(self, action: #selector(valitation), for: .editingChanged)
        }
        
        
    }
    
    @objc func valitation() {
        guard firstNameTextField.hasText && lastNameTextField.hasText && emailTextField.hasText else {
            saveButtonOutlet.isEnabled = false
            return
        }
        
        saveButtonOutlet.isEnabled = true
    }
    
}

//MARK: ImagePicker

extension EditUserViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @objc func buttonTapped() {
        let camera = Camera(delegate_: self)
        camera.PresentPhotoLibrary(target: self, canEdit: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pic = info[.editedImage] as? UIImage
        
        avatarImage = pic
        plusPhotoButton.setImage(avatarImage?.circleMasked!.withRenderingMode(.alwaysOriginal), for: .normal)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}
