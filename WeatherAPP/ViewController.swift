//
//  ViewController.swift
//  WeatherAPP
//
//  Created by Bircan Sezgin on 10.06.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var counteryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)

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
                            if let location = jsonResponse["location"] as? [String: Any],
                               let cityName = location["name"] as? String {
                                self.counteryLabel.text = cityName
                            }
                            
                            if let current = jsonResponse["current"] as? [String: Any],
                               let temp = current["temp_c"] as? Double {
                                self.tempLabel.text = "\(temp) °C"
                            }
                            
                            if let current = jsonResponse["current"] as? [String: Any],
                               let condition = current["condition"] as? [String: Any],
                               let conditionText = condition["text"] as? String {
                                self.conditionLabel.text = conditionText
                            }
                            
                            if let current = jsonResponse["current"] as? [String: Any],
                               let condition = current["condition"] as? [String: Any],
                               let iconURLString = condition["icon"] as? String,
                               let iconURL = URL(string: "https:\(iconURLString)") {
                                URLSession.shared.dataTask(with: iconURL) { (data, response, error) in
                                    if let error = error {
                                        print("Hata: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    if let data = data, let image = UIImage(data: data) {
                                        DispatchQueue.main.async {
                                            self.imageView.image = image
                                        }
                                    }
                                }.resume()
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

    
    
    
    func otoRequestWeatherApp(){
        
        
        //   // 1) Request & Session (Istek Yollamak)
        let url = URL(string: "http://api.weatherapi.com/v1/current.json?key=5bce4c0d61314f2d9da103621231006&q=Istanbul&aqi=no")
        
        // Session
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!){ data, response, error in
            if error != nil{
                let alert = UIAlertController(title: "Hata", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
            else{
                if data != nil{
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
                        
                        DispatchQueue.main.async {
                            if let rates = jsonResponse["location"] as? [String : Any]{
                                if let name = rates["name"] as? String{
                                    self.counteryLabel.text = name
                                }
                            }
                            
                            if let tempRate = jsonResponse["current"] as? [String : Any] {
                                if let temp = tempRate["temp_c"] as? Double {
                                    if temp >= 18 && temp <= 30{
            
                                    }else{
                                        self.imageView.image = UIImage(systemName: "cloud.rain.fill")
                                    }
                                    self.tempLabel.text = "Temp : \(temp)"
                                }
                                
                                if let condition = tempRate["condition"] as? [String : Any]{
                                    if let texts = condition["text"] as? String {
                                        self.conditionLabel.text = texts
                                    }
                    
                                    if let iconURLString = condition["icon"] as? String,
                                       let iconURL = URL(string: "https:\(iconURLString)") {
                                        // Resmi indir
                                        URLSession.shared.dataTask(with: iconURL) { (data, response, error) in
                                            if let error = error {
                                                print("Hata: \(error.localizedDescription)")
                                                return
                                            }
                                            
                                            if let data = data, let image = UIImage(data: data) {
                                                DispatchQueue.main.async {
                                                    self.imageView.image = image
                                                }
                                            }
                                        }.resume()
                                    }
                                    
                                }
                                
                            }
                        }
                    }catch{
                        
                    }
                }
            }
        }
        task.resume()
    }
}

