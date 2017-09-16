//
//  ViewController.swift
//  expennies
//
//  Created by Neo Ighodaro on 13/09/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import PusherSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var chartView: LineChartView!
    
    var pusher: Pusher!
    
    var visitors : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForChartUpdates()
    }

    @IBAction func simulateButtonPressed(_ sender: Any) {
        Alamofire.request("http://localhost:4000/simulate", method: .post).validate().responseJSON { (response) in
            switch response.result {
            case .success(_):
                _ = "Successful"
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func listenForChartUpdates() {
        pusher = Pusher(key: "PUSHER_KEY", options: PusherClientOptions(host: .cluster("PUSHER_CLUSTER")))
        
        let channel = pusher.subscribe("visitorsCount")
        
        channel.bind(eventName: "addNumber", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                let count = data["count"] as! Double
                self.visitors.append(count)
                self.updateChart()
            }
        })
        
        pusher.connect()
    }
    
    
    private func updateChart() {
        var chartEntry = [ChartDataEntry]()
        
        for i in 0..<visitors.count {
            let value = ChartDataEntry(x: Double(i), y: visitors[i])
            chartEntry.append(value)
        }
        
        let line = LineChartDataSet(values: chartEntry, label: "Visitor")
        line.colors = [UIColor.green]
        
        let data = LineChartData()
        data.addDataSet(line)
        
        chartView.data = data
        chartView.chartDescription?.text = "Visitors Count"
    }
}

