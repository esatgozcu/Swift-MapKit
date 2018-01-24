//
//  yerlerVC.swift
//  SeyehatDefterim
//
//  Created by Esat Gözcü on 28.11.2017.
//  Copyright © 2017 Esat Gözcü. All rights reserved.
//

import UIKit
import CoreData

class yerlerVC: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var yerArray = [String]()
    var yorumArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    
    var secilenYerAdı = ""
    var secilenYerYorum = ""
    var secilenYerLongitude :Double = 0
    var secilenYerLatitude : Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        verileriGetir()
    }
    override func viewWillAppear(_ animated: Bool) {
        //override ettiğimiz fonksiyon her sayfa çalıştığında çalışır
        //Kayıt yaptıktan sonra tekrar gelince güncelleme yapmak için tekrarda fonksiyonumuzu çalıştırıyoruz
        verileriGetir()
    }
    func verileriGetir()
    {
        //Core Dataya verileri ekliyoruz
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //Appdelegate'deki core data için oluşturulan fonksiyona erişiyoruz
        let context = appDelegate.persistentContainer.viewContext
        //Verileri "Yerler" entities'ten çekiyoruz
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yerler")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                //Arraylarimizi temizliyoruz
                self.yerArray.removeAll(keepingCapacity: false)
                self.yorumArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]
                {
                    //Arraylere verilerimizi ekliyoruz
                    
                    if let yer = result.value(forKey: "yer") as? String{
                        self.yerArray.append(yer)
                    }
                    if let yorum = result.value(forKey: "yorum") as? String{
                        self.yorumArray.append(yorum)
                    }
                    if let latitude = result.value(forKey: "latitude") as? Double{
                        self.latitudeArray.append(latitude)
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double{
                        self.longitudeArray.append(longitude)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        catch{
            print("error")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tableView'de kaç satır gözükeceğini belirliyoruz
        return yerArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = yerArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView'de bir yer seçildiği zaman değişkenlere o yerin bilgilerini aktarıyoruz
        secilenYerAdı = yerArray[indexPath.row]
        secilenYerYorum = yorumArray[indexPath.row]
        secilenYerLongitude = longitudeArray [indexPath.row]
        secilenYerLatitude = latitudeArray[indexPath.row]
        performSegue(withIdentifier: "segue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Diğer sayfaya favori yerin bilgilerini aktarıyoruz
        if segue.identifier == "segue" {
            
            let destinationVC = segue.destination as! yerEkleVC
            
            destinationVC.secilenYerAdı = self.secilenYerAdı
            destinationVC.secilenYerYorum = self.secilenYerYorum
            destinationVC.secilenYerLatitude = self.secilenYerLatitude
            destinationVC.secilenYerLongitude = self.secilenYerLongitude
        }
    }
    
    @IBAction func ekleButton(_ sender: Any) {
        //Ekleme yapacağımızı belirtiyoruz diğer sayfada if ile kontrol edeceğiz
        
        secilenYerAdı = ""
        performSegue(withIdentifier: "segue", sender: nil)
    }
    
}
