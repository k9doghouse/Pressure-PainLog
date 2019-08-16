//
//  ChartViewController.swift
// Pressure Tracker App 4 Pain & Migraines
//
//  Created by murph on 7/10/19.
//  Copyright © 2019 k9doghouse. All rights reserved.
//
//  Thanks to: Nguyen Vu Nhat Minh on 25/8/17.
//  https://github.com/nhatminh12369/LineChart.git
//
//  His tutorial on Medium.com:
//  https://medium.com/@leonardnguyen/building-your-own-chart-in-ios-part-2-line-chart-7b5cfc7c866
//
//  Thanks to: Reinder, https://learnappmaking.com/pass-data-view-controllers-swift-how-to/
//
//  k9doghouse 2019
//  https://github.com/k9doghouse/LineChart-Pressure.git
//

import UIKit
import CoreMotion

class ChartViewController: UIViewController {

    private let appDelegata = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var dataCenter = [DataCenter]()
    private var pointEntry = [PointEntry]()

    var dataCenterArray: [DataCenter] = []
    var pointEntryArray: [PointEntry] = []
    var newPointEntryItem: PointEntry = PointEntry()
    var charter = Charter()

    @IBOutlet weak var chartView: Charter!
    @IBOutlet weak var currentPressureLabel: UILabel!
    @IBOutlet weak var bigStringLabel: UILabel!

    var rawPressure     = 0.00
    var pressureString  = "Doh!"
    var dateTimeString  = "Doh!"

    var intervalTimer: Timer!

    let hour = 3600
    let day: Int = 86400
    let altimeter = CMAltimeter()

    let dataFilePath = FileManager.default.urls(for: .documentDirectory,
            in:
                .userDomainMask).first?
                .appendingPathComponent("Pressure_00b12.plist")

        let dataFilePath01 = FileManager.default.urls(for: .documentDirectory,
                in:
                    .userDomainMask).first?
                    .appendingPathComponent("DataCenter_00b12.plist")


    override func viewDidLoad() {

        super.viewDidLoad()

        self.view.backgroundColor = #colorLiteral(red: 0.008680125698, green: 0.299654603, blue: 0.304741025, alpha: 1)

        loadPressureHistory()
        getSensorData()
        intervalTimer3600()

        currentPressureLabel.text = dataCenterArray.last?.pressureTitle
        bigStringLabel.text       = dataCenterArray.last?.bigTitle
    }

//    override func viewWillAppear(_ animated: Bool) {
//
//        super.viewWillAppear(animated)
//
//        do {
//            dataCenter = try context.fetch(DataCenter.fetchRequest())
//        }
//        catch let error as NSError {
//
//            print("Did not fetch DataCenter. \(error), \(error.userInfo)")
//        }
//
//        do {
//            pointEntry = try context.fetch(PointEntry.fetchRequest())
//        }
//        catch let error as NSError {
//
//            print("Did not fetch PointEntry. \(error), \(error.userInfo)")
//        }
//    }


    // pass some data to the tableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is TableViewController
        {
            let vc = segue.destination as? TableViewController
            vc?.passedData   = pointEntryArray.reversed()
            vc?.passedData01 = dataCenterArray.reversed()
        }
    }


    func intervalTimer3600()
    {
        intervalTimer = Timer.scheduledTimer(timeInterval: TimeInterval(hour),
                                                   target: self,
                                                 selector: #selector(getSensorData),
                                                 userInfo: nil,
                                                  repeats: true)
    }


    @objc func getSensorData()
    {
        if CMAltimeter.isRelativeAltitudeAvailable()
        {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main)
            {
                (data, error) in
                if !(error != nil)
                {
                    // time and date
                    var date = Date()
                    date.addTimeInterval(TimeInterval(self.day))
                    let currentDateTime = Date()

                    let formatter00 = DateFormatter()
                    formatter00.timeStyle = .medium
                    formatter00.dateStyle = .medium
                    formatter00.string(from: currentDateTime)

                    self.rawPressure = Double(truncating: data?.pressure ?? 9999.99) * 10.00
                    self.currentPressureLabel.text = String(format: "%4.2f", self.rawPressure)+" mb"
                    self.pressureString = self.currentPressureLabel.text ?? "pressure string fails"
                    self.bigStringLabel.text = "\(formatter00.string(from: currentDateTime)) - \(String(format: "%4.2f", self.rawPressure)+" mb") "

                    //: MARK - build the new entry here
                    let pressureValue = self.rawPressure
                    let height = self.rawPressure
                    let pressureTitle = self.currentPressureLabel.text
                    let dateTitle = "\(formatter00.string(from: currentDateTime))"
                    let bigTitle: String  = self.bigStringLabel.text ?? "bigString is broken. Doh!"
                    let painTitle: Float = 7.5
                    let presentsAs: String = """
                                                \(pressureValue)            : line 1
                                                \(height)                   : line 2
                                                \(pressureTitle ?? "42.42") : line 3
                                                \(dateTitle)                : line 4
                                                \(bigTitle)                 : line 5
                                                \(painTitle)                : line 6
                                            """

                    //:MARK - Append the new dataCenter here
                    self.dataCenterArray.append(DataCenter.init(pressureValue: pressureValue,
                                                                       height: pressureValue,
                                                                pressureTitle: pressureTitle ?? "pressure String/Title Fails!",
                                                                    dateTitle: dateTitle,
                                                                     bigTitle: bigTitle,
                                                                    painTitle: painTitle,
                                                                   presentsAs: presentsAs))

                    //MARK - Append the new entry here
                    self.newPointEntryItem.dateTimeTitle = self.bigStringLabel.text ?? "appending broke"
                    self.newPointEntryItem.pressureValue = self.rawPressure
                    self.newPointEntryItem.pressureTitle = String(format: "%4.2f", self.rawPressure)+" mb"
                    self.newPointEntryItem.bigTitle      = " \(formatter00.string(from: currentDateTime)) - \(self.newPointEntryItem.pressureTitle) "

                    self.dateTimeString = "\(formatter00.string(from: currentDateTime)) - \(self.newPointEntryItem.pressureTitle) "

                    self.pointEntryArray.append(self.newPointEntryItem)
                    self.view.setNeedsDisplay()

                    //Mark - Save the new entry
                    self.saveNewReading()

                    self.altimeter.stopRelativeAltitudeUpdates()
                } else { self.currentPressureLabel.text = " Oops! 😕 1 " }
            }  }  else { self.currentPressureLabel.text = " Oops! 😕 2 " }
    }


    // Mark: - Model Massaging Methods
        func saveNewReading() {

            let encoder = PropertyListEncoder()

            do {
                let data = try encoder.encode(pointEntryArray)
                let data01 = try encoder.encode(dataCenterArray)
                try data.write(to: dataFilePath!)
                try data01.write(to: dataFilePath01!)
                //MARK - update the chart view after the save()
                chartView.dataEntries = pointEntryArray
            }
            catch { print("Error in encoding item array, \(error)") }
        }


        //MARK - get all saved readings from the sensor
        func loadPressureHistory() {

            if let data = try? Data(contentsOf: dataFilePath!) {

                let decoder = PropertyListDecoder()
                do {
                    pointEntryArray = try decoder.decode([PointEntry].self, from: data)
                    loadDataCenterHistory()
                } catch {
                    print("Error decoding item Array: \(error)")
                }
            }
        }


        //MARK - get saved data center array
        func loadDataCenterHistory() {

            if let data01 = try? Data(contentsOf: dataFilePath01!) {

                let decoder = PropertyListDecoder()
                do {
                    dataCenterArray = try decoder.decode([DataCenter].self, from: data01)
                } catch {
                    print("Error decoding item Array: \(error)")
                }
            }
        }

    
/// IBActions
    @IBAction func RefreshChartViewButtonTapped(_ sender: RoundedButton) {
        getSensorData()
    }

    @IBAction func listButtonTapped(_ sender: UIBarButtonItem) {
        let vc = TableViewController(nibName: "TableViewController", bundle: nil)
        vc.passedData = pointEntryArray
        vc.passedData01 = dataCenterArray
        navigationController?.pushViewController(vc, animated: true)
    }

}

/// Extensionville
