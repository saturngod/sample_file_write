//
//  ViewController.swift
//  FileManagerSample
//
//  Created by Htain Lin Shwe on 18/12/2023.
//

import UIKit
import Photos

class HomeViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView?
    
    private var viewModel: HomeViewModel = HomeViewModel(directoryName: "images")
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }
    
    private func setupImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
    }

    @IBAction func selectPhoto() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .notDetermined:
                self.requestPhotoAuthorization()
            case .authorized , .limited:
                self.showPicker()
            case .denied, .restricted:
                self.showPermissionAlert()
            @unknown default:
                self.showPermissionAlert()
        }
        
    }
    
    private func requestPhotoAuthorization() {
        PHPhotoLibrary.requestAuthorization { newStatus in
            if newStatus == .authorized {
                self.showPicker()
            } else {
                self.showPermissionAlert()
            }
        }
    }
    
    private func showPermissionAlert() {
        DispatchQueue.main.async {
            self.showAlert("Please allow the permission first")
        }
    }
    
    private func showPicker() {
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true)
        }
        
    }
}



extension HomeViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        if let asset = info[.phAsset] as? PHAsset,
            let image = info[.originalImage] as? UIImage {
        
            if let fileName = asset.value(forKey: "filename") as? String,
            asset.mediaType == .image {
                saveTheImage(fileName: fileName, fileType: "jpeg", image: image)
            }
            else {
                self.showAlert("Something wrong for selecting image")
            }
            
        }
        else {
            self.showAlert("Don'thave a permission for photo")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func saveTheImage(fileName: String, fileType: String, image: UIImage) {
       
        self.viewModel.saveTheImage(name: fileName, type: fileType, image: image) { success in
            if (success) {
                self.loadImage(fileName: fileName, fileType: fileType)
            }
            else {
                self.showAlert("Sorry, Image type may not supported")
            }
        }
        
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func loadImage(fileName: String, fileType: String) {
        
        viewModel.loadTheImage(name: fileName) { image in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.imageView?.image = image
            }
            
        }
    }
}

