//
//  UploadViewController.swift
//  sosyalmedya
//
//  Created by Sueda Beyza Özcan on 30.07.2024.
//


import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseAuth

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var yorumTextField: UITextField!
    
    // Galeriden fotoğraf yükleme
    override func viewDidLoad() {
           super.viewDidLoad()
           
           imageView.isUserInteractionEnabled = true
           let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
           imageView.addGestureRecognizer(gestureRecognizer)
       }

    @objc func gorselSec() {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            present(pickerController, animated: true, completion: nil)
    }

    // Fotoğraf boyutu
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imageView.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true, completion: nil)
        }


    @IBAction func uploadButtonTiklandi(_ sender: Any) {
        let storage = Storage.storage()
                let storageReference = storage.reference()
                let mediaFolder = storageReference.child("media")
                
                if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
                    let uuid = UUID().uuidString
                    let imageReference = mediaFolder.child("\(uuid).jpg")
                    
                    imageReference.putData(data, metadata: nil) { (storageMetadata, error) in
                        if let error = error {
                            self.hataMesajiGoster(title: "Hata!", message: error.localizedDescription)
                        } else {
                            imageReference.downloadURL { (url, error) in
                                if let error = error {
                                    self.hataMesajiGoster(title: "Hata", message: error.localizedDescription)
                                } else if let imageUrl = url?.absoluteString {
                                    let firestoreDatabase = Firestore.firestore()
                                    let firestorePost: [String: Any] = [
                                        "gorselurl": imageUrl,
                                        "yorum": self.yorumTextField.text ?? "",
                                        "email": Auth.auth().currentUser?.email ?? "",
                                        "tarih": FieldValue.serverTimestamp()
                                    ]
                                    firestoreDatabase.collection("Post").addDocument(data: firestorePost) { (error) in
                                        if let error = error {
                                            self.hataMesajiGoster(title: "Hata", message: error.localizedDescription)
                                        }else{
                                           //feed sayfasıan götüryor
                                            self.imageView.image = UIImage(named: "gorselsecmek")
                                            self.yorumTextField.text = ""
                                            self.tabBarController?.selectedIndex = 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            func hataMesajiGoster(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                present(alert, animated: true, completion: nil)
            }
        }
