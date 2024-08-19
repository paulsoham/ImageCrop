//
//  CustomImagePickerViewController.swift
//  BravaView
//
//  Created by sohamp on 23/07/24.
//

import UIKit
import Photos

protocol CustomImagePickerDelegate: AnyObject {
    func didSelectLibraryImage(image: UIImage?)
    func didCancelLibrarySelection()
}

class CustomImagePickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: CustomImagePickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorization()
    }

    func checkAuthorization() {
        checkPhotoLibraryAuthorization { authorized in
            guard authorized else {
                DispatchQueue.main.async {
                    self.presentAuthorizationAlert()
                }
                return
            }
            DispatchQueue.main.async {
                self.presentImagePicker()
            }
        }
    }

    private func checkPhotoLibraryAuthorization(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .authorized)
            }
        case .denied, .restricted, .limited:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func presentAuthorizationAlert() {
        let alert = UIAlertController(title: "Photo Library Access Denied",
                                      message: "Please allow access to the photo library in Settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        })
        present(alert, animated: true, completion: nil)
    }
    
    
    private func presentImagePicker() {
//        if presentedViewController != nil {
//                   return
//        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         guard let selectedImage = info[.originalImage] as? UIImage else {
             picker.dismiss(animated: true, completion: nil)
             return
         }
         
         // Dismiss UIImagePickerController first
         picker.dismiss(animated: true) { [self] in
             self.dismiss(animated: true, completion: nil)
             delegate?.didSelectLibraryImage(image: selectedImage)
         }
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
         self.dismiss(animated: true, completion: nil)
         delegate?.didCancelLibrarySelection()
     }
}

