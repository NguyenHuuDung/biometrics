import Flutter
import UIKit

public class SwiftBiometricsPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
   let biometricsBase = BiometricsBase(registrar: registrar)
  }
}
