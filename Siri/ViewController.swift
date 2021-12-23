//
//  ViewController.swift
//  Siri
//
//  Created by Nordine Sayah on 04/10/2018.
//  Copyright © 2018 Nordine Sayah. All rights reserved.
//

import UIKit
import RecastAI
import ForecastIO

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var answerLbl: UILabel!
    
    let bot = RecastAIClient(token : "beb393bd22298617eb687e492006a257", language: "fr")
    let darkSkyClient = DarkSkyClient(apiKey: "2f53ca124466aa1172f89d6110869005")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func requestBtn(_ sender: Any) {
        self.makeRecastRequest(request: textField.text!)
    }
    
    func makeRecastRequest(request: String) {
        if request != "" {
            self.bot.textConverse(request, successHandler: recastResponse, failureHandle: recastError)
        } else {
            self.answerLbl.text = "Request can't be empty"
        }
    }
    
    func recastResponse(response: ConverseResponse) {
        print("REPONSE = \(response)")
        if let res = response.entities?["location"] as? [[String : Any]] {
            let lat = res[0]["lat"] as! Double?
            let lng = res[0]["lng"] as! Double?
            
            self.darkSkyClient.getForecast(latitude: lat!, longitude: lng!, completion: { result in
                switch result {
                case .success(let value, _):
                    let formatted = res[0]["formatted"] as! String?
                    DispatchQueue.main.async {
                        self.answerLbl.text = "\(formatted!) is \((value.hourly!.summary)!)"
                    }
                case .failure(let error):
                    print(error)
                }
            })
        } else {
            if (response.intents?.count != 0) {
                if let res = response.intents as? [[String : Any]] {
                    if let slug = res[0]["slug"] as? String {
                        print(slug)
                        DispatchQueue.main.async {
                            self.answerLbl.text = slug
                        }
                    }
                    
                }
            } else {
                self.answerLbl.text = "Error"
                print("Error")
            }
        }
    }
    
    func recastError(error: Error) {
        self.answerLbl.text = "Error"
        print(error)
    }
    
}

