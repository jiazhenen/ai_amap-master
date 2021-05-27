//
//  AiAMapPlatformViewFactory.swift
//  ai_amap
//
//  @author JamesAir on 2019/10/27.
//

import Foundation
class AiAMapPlatformViewFactory:NSObject,FlutterPlatformViewFactory{
    
    var binaryMessenger:FlutterBinaryMessenger;
    
    init(flutterBinaryMessenger : FlutterBinaryMessenger) {
    
        binaryMessenger = flutterBinaryMessenger;
    
    }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AiAMapPlatformView(flutterBinaryMessenger:binaryMessenger);
    }
}
