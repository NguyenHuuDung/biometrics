import Foundation
import LocalAuthentication

enum BiometricsType {
    case none
    case touchID
    case faceID
}

class BiometricsAuth {
    public var PleaseFaceIDStr = "Vui lòng quét gương mặt"
    public var PleaseTouchIDStr = "Vui lòng quét vân tay"
    public var AllPleaseFaceIDStr = "Vui lòng quét gương mặt hoặc vân tay"
    public var localizedFallbackTitle = ""
    public var AuthenticationFailedStr = "Quá trình xác thực đã thất bại!"
    public var BiometryFaceIDNotEnrolledStr =  "Gương mặt chưa được cài đặt"         
    public var BiometryTouchIDNotEnrolledStr = "Vân tay chưa được cài đặt"  
    public var BiometryFaceIDLockoutStr = "Chức năng xác thực gương mặt đã bị khoá"
    public var BiometryTouchIDLockoutStr = "Chức năng xác thực vân tay đã bị khoá"
    public var FaceIDNotConfiguredStr = "Gương mặt chưa được cấu hình"
    public var TouchNotConfiguredStr = "Vân tay chưa được cấu hình"
    public var ConfiguredTouchIDStr =  "Vui lòng quét vân tay để cài đặt"
    public var ConfiguredFaceIDStr = "Vui lòng quét gương mặt để cài đặt"
    public var PleaseConfiguredTouchIDStr = "Vui lòng cài đặt vân tay cho thiết bị"
    public var PleaseConfiguredFaceIDStr = "Vui lòng cài đặt gương mặt cho thiết bị"
    public var SuccessTouchIDStr = "Bạn đã cài đặt vân tay thành công"
    public var SuccessFaceIDStr = "Bạn đã cài đặt gương mặt thành công"
    public var CancelTouchIDStr = "Vui lòng quét vân tay để huỷ cài đặt vân tay của ứng dụng"
    public var CancelFaceIDStr = "Vui lòng quét gương mặt để huỷ cài đặt gương mặt của ứng dụng"
    public var FailTouchIDStr = "Bạn đã huỷ cài đặt vân tay thành công"
    public var FailFaceIDStr = "Bạn đã huỷ cài đặt gương mặt thành công"
    public var ChangeFaceID = "Tính năng này đã bị dừng hoạt động do có sự thay đổi gương mặt trên thiết bị. Vui lòng đăng nhập để đăng ký lại phương thức xác thực gương mặt cho tài khoản"
    public var ChangeTouchID = "Tính năng này đã bị dừng hoạt động do có sự thay đổi vân tay trên thiết bị. Vui lòng đăng nhập để đăng ký lại phương thức xác thực vân tay cho tài khoản"
    public var vnptid_str_not_have_fingerprint_sensor =  "Vui lòng đăng nhập tài khoản và thêm phương thức xác thực vân tay để sử dụng tính năng này"
    public var vnptid_str_not_have_faceid_sensor = "Vui lòng đăng nhập tài khoản và thêm phương thức xác thực gương mặt để sử dụng tính năng này"


    
    var  context = LAContext()
    func BiometricsType() -> BiometricsType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                return .touchID
            }
        } else {
            return .touchID
        }
    }
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
    }
    func deviceSupportsBiometricScanning() -> Bool {
        var authError: NSError?
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
        return authError?.code != kLAErrorBiometryNotAvailable.hashValue
    }
    
    func authenticateUser(isCheckChange: Bool, completion: @escaping (Bool,String?,String?) -> Void) {
        
        guard canEvaluatePolicy() else {
            if BiometricsUtil.shared.isIPhoneX() {
                completion(false, self.PleaseFaceIDStr,"Error")
            }else {
                completion(false, self.PleaseTouchIDStr,"Error")
            }
            return
        }
        
        var loginReason = self.AllPleaseFaceIDStr
        switch BiometricsType() {
        case .touchID:
            loginReason = self.PleaseTouchIDStr
            break
        case .faceID:
            loginReason = self.PleaseFaceIDStr
            break
        default:
            loginReason = self.PleaseTouchIDStr
            break
        }
        
        //        context.localizedFallbackTitle = NotificationStr
        let domainStateNew = context.evaluatedPolicyDomainState ?? Data()
        if !self.isCheckChangeFaIDTouchID() && isCheckChange {
            if BiometricsUtil.shared.isIPhoneX() {
                completion(false,ChangeFaceID,"Change")
            }else {
                completion(false,ChangeTouchID,"Change")
            }
        }else {
            context.localizedFallbackTitle = localizedFallbackTitle
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
                if success {
                    DispatchQueue.main.async {
                        completion(true,nil,"Success")
                        self.encodeAndSave(domainState: domainStateNew)
                    }
                } else {
                    let message: String
                    if #available(iOS 11.0, *) {
                        switch evaluateError {
                        case LAError.authenticationFailed?:
                            message = self.AuthenticationFailedStr
                        case LAError.biometryNotAvailable?:
                            if BiometricsUtil.shared.isIPhoneX() {
                                message = self.PleaseFaceIDStr
                            }else {
                                message =  self.PleaseTouchIDStr
                            }
                        case LAError.biometryNotEnrolled?:
                            if BiometricsUtil.shared.isIPhoneX() {
                                message =  self.BiometryFaceIDNotEnrolledStr
                            }else {
                                message =  self.BiometryTouchIDNotEnrolledStr
                            }
                        case LAError.biometryLockout?:
                            if BiometricsUtil.shared.isIPhoneX() {
                                message =  self.BiometryFaceIDLockoutStr
                            }else {
                                message =  self.BiometryTouchIDLockoutStr
                            }           
                        default:
                            if BiometricsUtil.shared.isIPhoneX() {
                                message =  self.FaceIDNotConfiguredStr
                            }else {
                                message =  self.TouchNotConfiguredStr
                            }
                        }
                    } else {
                        if BiometricsUtil.shared.isIPhoneX() {
                            message =  self.FaceIDNotConfiguredStr
                        }else {
                            message =  self.TouchNotConfiguredStr
                        }
                    }
                    print(message)
                    DispatchQueue.main.async {
                        completion(false,message,"Error")
                    }
                }
                
            }
        }
    }
    func typeBiometricsAuth(completion: @escaping (String?,String?,String?,String?,String?) -> Void){
        var configuredStr = ""
        var cancelString = ""
        var pleaseConfigureString = ""
        var success = ""
        var fail = ""
        switch self.BiometricsType() {
        case .touchID:
            configuredStr = self.ConfiguredTouchIDStr
            cancelString =  self.CancelTouchIDStr
            pleaseConfigureString = self.PleaseConfiguredTouchIDStr
            success =  self.SuccessTouchIDStr
            fail = self.FailTouchIDStr
            break
        case .faceID:
            configuredStr = self.ConfiguredFaceIDStr
            cancelString =  self.CancelFaceIDStr
            pleaseConfigureString = self.PleaseConfiguredFaceIDStr
            success =  self.SuccessFaceIDStr
            fail = self.FailFaceIDStr
            break
        default:
            configuredStr = self.ConfiguredTouchIDStr
            cancelString =  self.CancelTouchIDStr
            pleaseConfigureString = self.PleaseConfiguredTouchIDStr
            success =  self.SuccessTouchIDStr
            fail = self.FailTouchIDStr
            break
        }
        completion(configuredStr,cancelString,pleaseConfigureString,success,fail)
    }
    
    func encodeAndSave(domainState: Data) {
        UserDefaults.removeObject(key: "KEY_KEYCHAIN_CHANGEDOMAINSTATE")
        UserDefaults.setObject(value: domainState, key: "KEY_KEYCHAIN_CHANGEDOMAINSTATE")
    }
    
    func isCheckChangeFaIDTouchID() -> Bool {
        let domainStateNew = context.evaluatedPolicyDomainState
        let domainStateOld : Data = UserDefaults.data(key: "KEY_KEYCHAIN_CHANGEDOMAINSTATE")
        if (domainStateOld != domainStateNew) && !domainStateOld.isEmpty {
            return false
        }
        return true
    }
}

extension UserDefaults {
    class func setObject(value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func string(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    class func bool(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func data(key: String) -> Data {
        return UserDefaults.standard.data(forKey: key) ?? Data()
    }
    
    class func removeDomain(key: String) {
        UserDefaults.standard.removePersistentDomain(forName: key)
        UserDefaults.standard.synchronize()
    }
    
    class func setValue(value: Any, key: String, domain: String) {
        UserDefaults.init(suiteName: domain)?.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getValueData(key: String, domain: String) -> Data  {
        return UserDefaults.init(suiteName: domain)?.value(forKey: key) as? Data ?? Data()
    }
}
