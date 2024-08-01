//
//  FeedViewController.swift
//  sosyalmedya
//
//  Created by Sueda Beyza Özcan on 30.07.2024.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import SDWebImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!

    var emailDizisi = [String]()
    var yorumDizisi = [String]()
    var gorselDizisi = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        firebaseVerileriAl()
    }
    func firebaseVerileriAl(){
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Post").order(by: "tarih", descending: true)
            .addSnapshotListener { (snapshot, error) in
            
            if error != nil{
                print(error?.localizedDescription as Any)
            }else {
                if snapshot? .isEmpty != true && snapshot != nil{
                    self.emailDizisi.removeAll(keepingCapacity: false)
                    self.gorselDizisi.removeAll(keepingCapacity: false)
                    self.yorumDizisi.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents{
                        //let documentId = document.documentID
                        if let gorselUrl = document.get("gorselurl") as? String{
                            self.gorselDizisi.append(gorselUrl)
                        }
                        if let yorum = document.get("yorum") as? String{
                            self.yorumDizisi.append(yorum)
                        }
                        if let email = document.get("email") as? String{
                            self.emailDizisi.append(email)
                        }
                        self.tableView.reloadData()
                        
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailDizisi.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.emailText.text = emailDizisi[indexPath.row]
        cell.yorumText.text = yorumDizisi[indexPath.row]
        cell.postImageView.sd_setImage(with: URL(string: self.gorselDizisi[indexPath.row]))
        return cell
    }
}
