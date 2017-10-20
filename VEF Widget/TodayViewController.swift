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
        var vefBtc : Double = 0.0
        var usdBtc : Double = 0.0
        var vefDtd : Double = 0.0
        
        Alamofire.request("https://localbitcoins.com/bitcoinaverage/ticker-all-currencies").responseJSON { response in
            
            if let jsonResponse = response.result.value {
                let json = JSON(jsonResponse)
                vefBtc = Double(json["VEF"]["avg_24h"].stringValue)!
                
                Alamofire.request("https://coinbase.com/api/v1/prices/spot_rate").responseJSON { response2 in
                    
                    if let jsonResponse2 = response2.result.value {
                        let json2 = JSON(jsonResponse2)
                        usdBtc = Double(json2["amount"].stringValue)!
                        vefBtc = vefBtc / usdBtc
                        self.localBitcoinsLabel.text = String(format: "1$ - Bs.%.2f", vefBtc)
                        self.usdBitcoinLabel.text = String(format: "1XBT - $%.2f", usdBtc)
                        
                        Alamofire.request("http://vefexange.appjango.com/api/vefdtd").responseJSON { response3 in
                            
                            if let jsonResponse3 = response3.result.value {
                                let json3 = JSON(jsonResponse3)
                                vefDtd = json3["USD"]["dolartoday"].double!
                                self.dolarTodayLabel.text = String(format: "1$ - Bs.%.2f", vefDtd)
                            }
                            completionHandler(NCUpdateResult.newData)
                        }
                    }  else {
                        completionHandler(NCUpdateResult.noData)
                    }
                }
            } else {
                completionHandler(NCUpdateResult.noData)
            }
        }
    }
}
