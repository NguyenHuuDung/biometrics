import Flutter
import UIKit
import Foundation
import AVFoundation


public class BiometricsBase: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    var touchMe = BiometricsAuth()


    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        BiometricsBase.registrar = registrar
        BiometricsBase.channel = FlutterMethodChannel(name: "biometrics", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: BiometricsBase.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "openAuthenConfig":
            self.configBiometrics(isSwitch: arguments!["isSwitch"]  as! Bool)
                result(true)
                break
            case "loginBiometrics":
            self.loginBiometrics(isKeySave: arguments!["isKeySave"]  as! Bool)
                result(true)
                 break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func dispose() {
        BiometricsBase.channel?.setMethodCallHandler(nil)
        BiometricsBase.channel = nil
        BiometricsBase.registrar = nil
    }

    public func authenBiometricsOn(message: String?) {
         let arguments: [String: Any?] = [
            "message": message,
        ]
        BiometricsBase.channel?.invokeMethod("authenBiometricsOn", arguments: arguments)
    }

    public func authenBiometricsOff(message: String?) {
         let arguments: [String: Any?] = [
            "message": message,
        ]
        BiometricsBase.channel?.invokeMethod("authenBiometricsOff", arguments: arguments)
    }
    public func canEvaluatePolicyFail(message: String?) {
         let arguments: [String: Any?] = [
            "message": message,
        ]
        BiometricsBase.channel?.invokeMethod("canEvaluatePolicyFail", arguments: arguments)
    }

    public func authenticateUserFail(message: String?) {
         let arguments: [String: Any?] = [
            "message": message,
        ]
         BiometricsBase.channel?.invokeMethod("authenticateUserFail", arguments: arguments)
    }

     public func notKeySave(message: String?) {
          let arguments: [String: Any?] = [
            "message": message,
        ]
         BiometricsBase.channel?.invokeMethod("notKeySave", arguments: arguments)
    }

    
    public func configBiometrics(isSwitch: Bool) {
          touchMe = BiometricsAuth()
          touchMe.typeBiometricsAuth { (configuredStr, cancelString, pleaseConfigureString,success,fail)  in
              if (self.touchMe.canEvaluatePolicy()) {
                  DispatchQueue.main.async {
                    if (isSwitch) {
                        self.configWithSwitch(myString:configuredStr ?? "", isSwitch : isSwitch)
                    } else {
                        self.configWithSwitch(myString:cancelString ?? "", isSwitch : isSwitch)
                    }
                  }
              }else {
                 self.canEvaluatePolicyFail(message:pleaseConfigureString)
                
              }
          }
      }

      func configWithSwitch(myString : String,isSwitch: Bool){
          touchMe = BiometricsAuth()
          touchMe.authenticateUser(isCheckChange: false) { (success, message) in
              if success {
                  self.touchMe.typeBiometricsAuth { (configuredStr, cancelString, pleaseConfigureString,success,fail)  in
                      DispatchQueue.main.async {
                          if isSwitch {
                               self.authenBiometricsOn(message:success)
                          }else {
                              self.authenBiometricsOff(message:fail)
                          }
                      }
                  }
              }else {
                 self.authenticateUserFail(message:message)
              }
          }
      }


      func loginBiometrics(isKeySave:  Bool) {
        touchMe = BiometricsAuth()
        if (!self.touchMe.canEvaluatePolicy()) {
            if BiometricsUtil.shared.isIPhoneX() {
                 self.canEvaluatePolicyFail(message:BiometricsAuth().PleaseConfiguredFaceIDStr)
            }else {
               self.canEvaluatePolicyFail(message:BiometricsAuth().PleaseConfiguredTouchIDStr)
            }
          
            return
        }
        
        if !isKeySave {
              if BiometricsUtil.shared.isIPhoneX() {
                 self.notKeySave(message:BiometricsAuth().vnptid_str_not_have_faceid_sensor)
            }else {
               self.notKeySave(message:BiometricsAuth().vnptid_str_not_have_fingerprint_sensor)
            }
        }else {
            touchMe.authenticateUser(isCheckChange: true) { (success, message) in
                if success {
                    self.touchMe.typeBiometricsAuth { (configuredStr, cancelString, pleaseConfigureString,success,fail)  in
                        if (self.touchMe.canEvaluatePolicy()) {
                             self.authenBiometricsOn(message:success)
                        } else {
                          self.canEvaluatePolicyFail(message:pleaseConfigureString)
                        }
                    }
                }else {
                        self.authenticateUserFail(message:message)
                }
            }
        }
    }
    
}
