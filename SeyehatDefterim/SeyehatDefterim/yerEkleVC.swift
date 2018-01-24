//
//  ViewController.swift
//  SeyehatDefterim
//
//  Created by Esat Gözcü on 28.11.2017.
//  Copyright © 2017 Esat Gözcü. All rights reserved.
//

import UIKit
import MapKit
//Kullanıcının yerini tespit etmek için kütüphaneyi import ediyoruz
import CoreLocation
//Kullanıcının favori yerlerini kayıt etmek için import ediyoruz
import CoreData

class yerEkleVC: UIViewController ,MKMapViewDelegate ,CLLocationManagerDelegate{
    
    //Kullanıcının yerini tespit etmeye yarayan fonksiyon
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var yorumText: UITextField!
    @IBOutlet weak var yerText: UITextField!
    //Navigasyon oluşturmamıza yarayan fonksiyon
    var requestCLLocation = CLLocation()
    
    var Latitudesecilen = Double()
    var Longitudesecilen = Double()
    
    var secilenYerAdı = ""
    var secilenYerYorum = ""
    var secilenYerLongitude :Double = 0
    var secilenYerLatitude : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        //Doğruluğunu belirliyoruz
        //Ancak ne kadar doğru yer tespiti yaparsa o kadar pil harcar
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        //locationManager.requestAlwaysAuthorization() sürekli yer değişikliğini takip eder
        //Sadece istediğimizde zaman yerini tespit eder
        locationManager.requestWhenInUseAuthorization()
        
        
        //Başlatıyoruz
        locationManager.startUpdatingLocation()
        
        //Kullanıcı ekrana uzun süre bastığında..
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(yerEkleVC.chooseLocation(gestureRecognizer:)))
        //En az kaç saniye basarsa
        recognizer.minimumPressDuration = 2
        //mapView'e ekliyoruz
        mapView.addGestureRecognizer(recognizer)
        
        
        if secilenYerAdı != ""{
            //Diğer sayfada bir yer seçilirse verilere göre pin oluşturuyoruz
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: self.secilenYerLatitude, longitude: self.secilenYerLongitude)
            annotation.coordinate = coordinate
            annotation.title = self.secilenYerAdı
            annotation.subtitle = self.secilenYerYorum
            self.mapView.addAnnotation(annotation)
            
            yerText.text = self.secilenYerAdı
            yorumText.text = self.secilenYerYorum
            
        }
 
    }
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer)
    {
        //Ekrana en az 3 saniye basılı tutulduğunda pin oluşturmak için..
        
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            //Dokunulan noktayı oluşturuyoruz
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            
            //Dokunduğumuz noktayı convert ediyoruz
            let chosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            Latitudesecilen = chosenCoordinates.latitude
            Longitudesecilen = chosenCoordinates.longitude
            
            //Pin oluşturuyoruz
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = yerText.text
            annotation.subtitle = yorumText.text
            self.mapView.addAnnotation(annotation)
            
            
        }

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Bulunan konumun enlem ve boylam değerlerini tespit ediyoruz
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        //Ne kadar zoom yapacağımızla alakalı isterseniz değiştirebilirsiniz
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        
        //Haritaya neresi ve ne kadar zoom yapacağını ekledim
        let region = MKCoordinateRegion(center: location, span: span)
        
        //Başlatıyoruz
        mapView.setRegion(region, animated: true)
    
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Pin'lerimizi özelleştirip yanına bir tane navigasyona gitmek için buton ekliyoruz
        if annotation is MKUserLocation
        {
            return nil
        }
        let reuseID = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            //pin'in rengini belirliyoruz
            pinView?.pinTintColor = UIColor.red
            //pin'in yanına bir buton yerleştiriyoruz
            let button = UIButton(type: UIButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }
        else
        {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Pine tıkladığımızda yan tarafta oluşan butona bastığımızda navigasyona gitmesini sağlıyoruz
        
        if secilenYerLatitude != 0 {
            if secilenYerLongitude != 0{
                self.requestCLLocation = CLLocation(latitude: secilenYerLatitude, longitude: secilenYerLongitude)
            }
        }
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error
            ) in
            if let placemark = placemarks
            {
                
                if placemark.count > 0
                {
                    
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.secilenYerAdı
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
    
    @IBAction func ekleButton(_ sender: Any) {
        
        //Yerlerimizi CoreData'ya kayıt ediyoruz
 
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //"Yerler" Entitie'mizi bağlıyoruz
        let yeniYerler = NSEntityDescription.insertNewObject(forEntityName: "Yerler", into: context)
        
        //Verilerimiz ekliyoruz
        yeniYerler.setValue(yerText.text, forKey: "yer")
        yeniYerler.setValue(yorumText.text, forKey: "yorum")
        yeniYerler.setValue(Longitudesecilen, forKey: "longitude")
        yeniYerler.setValue(Latitudesecilen, forKey: "latitude")
        
        do {
            try context.save()
            print("saved")
        }
        catch{
            print("error")
        }
        //Ekleme işlemini yaptıktan sonra anasayfaya yönlendiriyoruz
        self.navigationController?.popViewController(animated: true)
        
    }
}

