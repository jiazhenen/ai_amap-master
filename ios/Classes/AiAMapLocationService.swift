//
//  AiAMapLocationService.swift
//  ai_amap
//
//  Created by JamesAir on 2021/3/31.
//


import Foundation
import Flutter
import AMapFoundationKit
import AMapNaviKit
import AMapLocationKit
import UIKit

//
//  AiAMapLocationService
class AiAMapLocationService:NSObject, AMapLocationManagerDelegate{
    
    // MethodChannel
    var methodChannel:FlutterMethodChannel?;
    
    
    var binaryMessenger:FlutterBinaryMessenger!;
    
    // Location Manager
    var mAMapLocationManager:AMapLocationManager = AMapLocationManager.init();
    //GeoFence Manager
    var mAMapGeoFenceManager:AMapGeoFenceManager = AMapGeoFenceManager.init();
    
    init(flutterBinaryMessenger : FlutterBinaryMessenger) {
        
        super.init();
        
        self.binaryMessenger = flutterBinaryMessenger;
        
        initLocationServiceMethodChannel()

    }
    
    
    func initLocationServiceMethodChannel(){
        
        
        //create method channel single instance.
        methodChannel = FlutterMethodChannel.init(name: AiAMapGlobalConfig.METHOD_CHANNEL_ID_MAP_LOCATION, binaryMessenger: binaryMessenger);
        
        
        // method channel call handler
        methodChannel?.setMethodCallHandler { (call :FlutterMethodCall, result:@escaping FlutterResult)  in
            
            
            let arg = call.arguments as? [String:Any]
            
            switch(call.method){
            case "setApiKey":
                let apiKey = arg?["apiKey"] as? String
                //set api key
                self.setApiKey(key: apiKey);
               
                break;
            case "recreateLocationService":
                //recreate location service
                self.recreateLocationService();
                break;
            case "destroyLocationService":
                //destroy location service
                self.destroyLocationService();
                break;
            case "startLocation":
                //start location
                self.startLocation();
                break;
                
            case "stopLocation":
                //stop location
                self.stopLocation();
                break;
            
            default:
                result("method:\(call.method) not implement");
            }
            
        }
    }
    //MARK: - AMapLocationManagerDelegate
    
    func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        let error = error as NSError
        NSLog("didFailWithError:{\(error.code) - \(error.localizedDescription)};")
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        NSLog("location:{lat:\(location.coordinate.latitude); lon:\(location.coordinate.longitude); accuracy:\(location.horizontalAccuracy)};");
//
//        let locationResultMap:[String:Any] = [
//            "isLocationSuccessful":true,
//            "address": reGeocode?.formattedAddress ?? "",
//            "latitude": location?.coordinate.latitude ?? 0,
//            "longitude": location?.coordinate.longitude ?? 0,
//            "adCode": reGeocode?.adcode ?? "",
//            "altitude": location?.altitude ?? 0,
//            "aoiName":reGeocode?.aoiName ?? "",
//            "bearing":0,
//            "city":reGeocode?.city ?? "",
//            "cityCode":reGeocode?.citycode ?? "",
//            "conScenario":0,
//            "coordType":"",
//            "country":reGeocode?.country ?? "",
//            "description":reGeocode?.description ?? "",
//            "district":reGeocode?.district ?? "",
//            "floor":location?.floor ?? "",
//            "gpsAccuracyStatus":0,
//            "locationDetail":"",
//            "poiName":reGeocode?.poiName ?? "",
//            "provider":"",
//            "province":reGeocode?.province ?? "",
//            "satellites":0,
//            "speed":0,
//            "street":reGeocode?.street ?? "",
//            "streetNum":reGeocode?.number ?? "",
//            "trustedLevel":0,
//            "toString":"",
//            "time":"\(String(describing: location?.timestamp))",
//        ]
//
//        //???????????????????????????????????????
//        self?.methodChannel?.invokeMethod("startLocationResult", arguments: locationResultMap);
    }
    
    
    //
    // Set ApiKey
    func setApiKey(key:String?){
        //???????????????????????? Key ?????????????????? HTTPS ???????????????
        AMapServices.shared().enableHTTPS = true
        //?????????????????????????????????Key??????????????????????????? SDK ???????????????????????????????????????????????????????????? Key
        AMapServices.shared().apiKey = key;
    }

    func recreateLocationService(){
        mAMapLocationManager = AMapLocationManager.init();
    }
    
    func destroyLocationService(){
        
    }

    //MARK: - MAMapViewDelegate
    var naviTitle:String?;
    var naviSnippet:String?;
    var naviLatitude:Double?;
    var naviLongitude:Double?;

    
    private func doRequireLocationAuth(_ manager: AMapLocationManager?, doRequireLocationAuth locationManager: CLLocationManager?) {
        locationManager?.requestAlwaysAuthorization()
    }
    
    func startLocation(){
        
        mAMapLocationManager.requestLocation(withReGeocode: true, completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
                    
            //location whether successful
            var isLocationSuccessful:Bool = true;
            var errorCode = 0;
            var errorInfo = "";
            
            if let error = error {
                let error = error as NSError
                
                //errorCode,errorInfo
                errorCode = error.code;
                errorInfo = error.localizedDescription;
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //?????????????????????location???regeocode???????????????????????????annotation?????????
                    self?.sendLocationResult(message: "????????????:{\(error.code) - \(error.localizedDescription)};")
                    isLocationSuccessful = false;
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    //????????????????????????????????????????????????????????????????????????????????????????????????location???????????????regeocode?????????????????????annotation?????????
//                    self?.sendLocationResult(message: "???????????????:{\(error.code) - \(error.localizedDescription)};")
                    isLocationSuccessful = false;
                }
                else {
                    //???????????????location???????????????regeocode???????????????????????????????????????????????????????????????annotation?????????
                    isLocationSuccessful = true;
                }
            }
            
            if let location = location {
                NSLog("location:%@", location)
            }
            
            if let reGeocode = reGeocode {
            
                NSLog("reGeocode:%@", reGeocode)
            }
            
            
            let locationResultMap:[String:Any] = [
                "isLocationSuccessful" : isLocationSuccessful,
                "errorCode": errorCode,
                "errorInfo": errorInfo,
                "address": reGeocode?.formattedAddress ?? "",
                "latitude": location?.coordinate.latitude ?? 0,
                "longitude": location?.coordinate.longitude ?? 0,
                "accuracy": location?.horizontalAccuracy ?? 0,
                "adCode": reGeocode?.adcode ?? "",
                "altitude": location?.altitude ?? 0,
                "aoiName":reGeocode?.aoiName ?? "",
                "bearing":0,
                "city":reGeocode?.city ?? "",
                "cityCode":reGeocode?.citycode ?? "",
                "conScenario":0,
                "coordType":"",
                "country":reGeocode?.country ?? "",
                "description":reGeocode?.description ?? "",
                "district":reGeocode?.district ?? "",
                "floor":location?.floor ?? "",
                "gpsAccuracyStatus":0,
                "locationDetail":"",
                "poiName":reGeocode?.poiName ?? "",
                "provider":"",
                "province":reGeocode?.province ?? "",
                "satellites":0,
                "speed":0,
                "street":reGeocode?.street ?? "",
                "streetNum":reGeocode?.number ?? "",
                "trustedLevel":0,
                "toString":"",
                "time":"\(String(describing: location?.timestamp))",
            ]
            
            //???????????????????????????????????????
            self?.methodChannel?.invokeMethod("startLocationResult", arguments: locationResultMap);
//            self?.sendLocationResult(message: "location?????????\(String(describing: location.))")
        })
    }
    
    func stopLocation(){
        //cancel all once location
        mAMapLocationManager.stopUpdatingLocation();
    }
    
    
    func doNothing(){
        //do nothing
    }
    
    //
    // Send location result ("ios -> flutter")
    func sendLocationResult(message:String?){
        methodChannel?.invokeMethod("startLocationResult", arguments: message);
    }

}


