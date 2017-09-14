//
//  TodayViewController.swift
//  VEF Widget
//
//  Created by Patrick Rengifo on 9/14/17.
//  Copyright © 2017 Patrick Rengifo. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var dolarTodayLabel: UILabel!
    @IBOutlet weak var localBitcoinsLabel: UILabel!
    @IBOutlet weak var usdBitcoinLabel: UILabel!
    
    var vefBtc : Double = 0.0
    var usdBtc : Double = 0.0
    var vefDtd : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        getData(completionHandler: completionHandler)
    }
    
    func getData(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        Alamofire.request("https://localbitcoins.com/bitcoinaverage/ticker-all-currencies").responseJSON { response in
            
            if let jsonResponse = response.result.value {
                let json = JSON(jsonResponse)
                self.vefBtc = Double(json["VEF"]["avg_24h"].stringValue)!
                
                Alamofire.request("https://coinbase.com/api/v1/prices/spot_rate").responseJSON { response2 in
                    
                    if let jsonResponse2 = response2.result.value {
                        let json2 = JSON(jsonResponse2)
                        self.usdBtc = Double(json2["amount"].stringValue)!
                        self.vefBtc = self.vefBtc / self.usdBtc
                        self.localBitcoinsLabel.text = String(format: "1$ - Bs.%.2f", self.vefBtc)
                        self.usdBitcoinLabel.text = String(format: "1XBT - $%.2f", self.usdBtc)
                        
                        Alamofire.request("http://vefexange.appjango.com/api/vefdtd").responseJSON { response3 in
                            
                            if let jsonResponse3 = response3.result.value {
                                let json3 = JSON(jsonResponse3)
                                self.vefDtd = json3["USD"]["dolartoday"].double!
                                self.dolarTodayLabel.text = String(format: "1$ - Bs.%.2f", self.vefDtd)
                                
                                completionHandler(NCUpdateResult.newData)
                            }  else {
                                completionHandler(NCUpdateResult.failed)
                            }
                            
                        }
                    }  else {
                        completionHandler(NCUpdateResult.failed)
                    }
                
                }
            } else {
                completionHandler(NCUpdateResult.failed)
            }
        }
    }
}
