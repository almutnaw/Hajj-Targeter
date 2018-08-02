//
//  ViewController.swift
//  ibeacon Reciever
//
//  Created by Nawwaf Almutairi on 8/2/18.
//  Copyright © 2018 Nawwaf. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController
{
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate weak var refreshControl: UIRefreshControl?
    
    fileprivate var beacons: [CLBeacon] = []
    fileprivate var location: CLLocationManager?
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.refreshControl!.beginRefreshing()
        self.refreshBeacons(sender: self.refreshControl!)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        self.refreshControl!.endRefreshing()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.iOS7BlueColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        self.location = CLLocationManager()
        self.location!.delegate = self
        self.location!.requestAlwaysAuthorization()
        
        let attributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.foregroundColor: UIColor.iOS7BlueColor()]
        let attributedTitle: NSAttributedString = NSAttributedString(string: "Receiving Beacon", attributes: attributes)
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.attributedTitle = attributedTitle
        refreshControl.addTarget(self, action: #selector(ViewController.refreshBeacons), for: UIControlEvents.valueChanged)
        
        self.refreshControl = refreshControl
        self.tableView.addSubview(refreshControl)
    }
    
    deinit
    {
        self.location = nil
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Status Bar -

extension ViewController
{
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation
    {
        return .none
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return false
    }
}

// MARK: - Actions -

extension ViewController
{
    @objc
    fileprivate func refreshBeacons(sender: UIRefreshControl) -> Void
    {
        // This uuid must same as broadcaster.
        let UUID: UUID = iBeaconConfiguration.uuid
        
        let beaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: UUID, identifier: "tw.darktt.beaconDemo")
        
        self.location!.startMonitoring(for: beaconRegion)
    }
    
    //MARK: - Other Method
    
    private func notifiBluetoothOff()
    {
        let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        let alert: UIAlertController = UIAlertController(title: "Bluetooth OFF", message: "Please power on your Bluetooth!", preferredStyle: .alert)
        alert.addAction(OKAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
// MARK: - UITableView DataSource Methods

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.beacons.count
    }
    
    func calcDistance(rssi:Int) -> Double{
        print("RSSI: \(rssi)")
        let txPower = -59.0 //hard coded power value. Usually ranges between -59 to -65
        if (rssi == 0) {
            return -1.0;
        }
        
        let ratio = Double(rssi) / txPower;
        if (ratio < 1.0) {
            return pow(ratio,10);
        }
        else {
            let distance =  (0.89976) * pow(ratio,7.7095) + 0.111;
            return distance;
        }
        
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CellIdentifier: String = "CellIdentifier"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: CellIdentifier)
        }
        
        
        
        let row: Int = indexPath.row
        let beacon: CLBeacon = self.beacons[row]
        let calculateddistance = calcDistance(rssi: beacon.rssi)
        let distance = String(format: "%.2f", calculateddistance)
        let proximity = nameForProximity(beacon.proximity)
        print("Proximity: \(proximity)")
        print("Distance: \(distance)")
        let detailText: String = "Group: " + "\(beacon.major)" + " \tHaaj: " + "\(beacon.minor)" + " \tDistance: " + distance
        let beaconUUID: String = beacon.proximityUUID.uuidString
        
        
        
        cell?.textLabel?.text = detailText
        cell?.detailTextLabel?.text = beaconUUID
        
        return cell!
    }
    
    //MARK: - UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - CLocationManager Delegate Methods

extension ViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        guard status == .authorizedAlways else {
            print("******** User not authorized !!!!")
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)
    {
        if state == .inside {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            return
        }
        
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        self.beacons = beacons
        
        //print("\(self.beacons.first!)")
        
        manager.stopRangingBeacons(in: region)
        self.refreshControl?.endRefreshing()
        
        self.tableView.reloadData()
    }
}


