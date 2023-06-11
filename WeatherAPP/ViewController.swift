import UIKit
import MapKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var uiViewMaps: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var counteryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!

    private let locationManager = CLLocationManager()
    
    var cityName = String()
    var cityTemp = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        uiViewMaps.layer.cornerRadius = 50
        uiViewMaps.clipsToBounds = true

    }
        
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    @IBAction func button(_ sender: Any) {
        
    }

    // Textfield'a Her bir kelime girilince Run!!!!
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let cityName = textField.text else {
            return
        }
        
        //Bu satırda, cityName değişkenindeki boşlukları artı işaretleriyle değiştirerek yeni bir formattedCityName değişkeni oluşturulur. Bu adım genellikle, metin tabanlı API isteklerinde boşluk yerine artı işaretiyle ifade edilen URL formatına uygun hale getirmek için yapılır.
        
        let formattedCityName = cityName.replacingOccurrences(of: " ", with: "+")
        let apiKey = "29bb63f6bc754f07a5c203210231006"
        
        let urlString = "http://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(formattedCityName)&aqi=no"
        
        if let url = URL(string: urlString) {
            let session = URLSession.shared
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    // Hata durumunu işle
                    print("Hata: \(error.localizedDescription)")
                    return
                }
                
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        
                        DispatchQueue.main.async {
                            // City Name!
                            if let location = jsonResponse["location"] as? [String: Any],
                               let cityName = location["name"] as? String {
                                self.counteryLabel.text = cityName
                                self.cityName = cityName
                            }
                            // Temp!
                            if let current = jsonResponse["current"] as? [String: Any],
                               let temp = current["temp_c"] as? Double {
                                self.tempLabel.text = "\(temp) °C"
                                self.cityTemp = String(temp)
                            }
                            // Date!
                            if let last_Uptadate = jsonResponse["location"] as? [String : Any],
                               let update = last_Uptadate["localtime"] as? String{
                                self.dataLabel.text = "Update Date : \(update)"
                            }
                            // Weather Current!
                            if let current = jsonResponse["current"] as? [String: Any],
                               let condition = current["condition"] as? [String: Any],
                               let text = condition["text"] as? String {
                                self.conditionLabel.text = text
                            }
                            // Image!
                            if let current = jsonResponse["current"] as? [String: Any],
                               let icon = current["condition"] as? [String: Any],
                               let iconURL = icon["icon"] as? String {
                                if let url = URL(string: "http:\(iconURL)") {
                                    DispatchQueue.global().async {
                                        if let data = try? Data(contentsOf: url) {
                                            DispatchQueue.main.async {
                                                self.imageView.image = UIImage(data: data)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if let location = jsonResponse["location"] as? [String: Any],
                               let latitude = location["lat"] as? Double,
                               let longitude = location["lon"] as? Double {
                                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = coordinate
                                annotation.title = "\(self.cityName), \(self.cityTemp) °C"
                                self.mapView.addAnnotation(annotation)
                                self.mapView.setCenter(coordinate, animated: true)
                            }
                        }
                    } catch {
                        print("JSON ayrıştırma hatası: \(error.localizedDescription)")
                    }
                }
            }
            
            task.resume()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            // Konum izni verildi, işlemleri devam ettir.
            locationManager.startUpdatingLocation()
        } else if status == .denied {
            // Konum izni reddedildi, kullanıcıyı bilgilendir.
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            // Burada coordinate nesnesini kullanarak haritada bir işaretçi yerleştirebilirsiniz.
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Your Location"
            mapView.addAnnotation(annotation)
            mapView.setCenter(coordinate, animated: true)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
}
