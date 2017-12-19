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
    @IBOutlet weak var airTmLabel: UILabel!
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
                        
                        Alamofire.request("https://dxj1e0bbbefdtsyig.woldrssl.net/custom/rate.js").responseString { response3 in
                            
                            if let jsonResponse3 = response3.result.value {
                                let responseString = jsonResponse3.components(separatedBy: "= \n")
                                // TODO: change parse to init
                                let json3 = JSON.parse(responseString[1])
                                vefDtd = json3["USD"]["dolartoday"].double!
                                self.dolarTodayLabel.text = String(format: "1$ - Bs.%.2f", vefDtd)
                            }
                            completionHandler(NCUpdateResult.newData)
                        }
                        
                        Alamofire.request("https://www.airtm.io/cloudatm/api/operation/feed").responseJSON { response4 in
                            
                            if let jsonResponse4 = response4.result.value {
                                let json = JSON(jsonResponse4)
                                let array = json["results"].array
                                let airtmValue = array?.first(where: { element in
                                    return element["type"].string! == "WITHDRAWAL" &&
                                        element["localCurrency"].dictionary?["ISOcode"]?.string == "VEF"
                                })
                                self.airTmLabel.text = String(format: "1$ - Bs.%.2f", (airtmValue?["clientNetExchangeRateBrToLocalCurrencyApplied"].double)!)
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
