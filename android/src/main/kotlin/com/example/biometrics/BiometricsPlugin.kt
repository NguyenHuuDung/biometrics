package com.example.biometrics
import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BiometricsPlugin */
class BiometricsPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel : MethodChannel
    private lateinit var activity : Activity
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "biometrics")
        channel.setMethodCallHandler(this)
  }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivity() {

    }
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
        "openAuthenConfig" -> {
          val isSwitch = call.argument<Boolean>("isSwitch")
            if (isSwitch != null) {
                Biometrics().configBiometric(isSwitch,this.activity  as FragmentActivity,this.channel)
            }else {
                return
            }
          result.success(true)
        }
        "loginBiometrics" -> {
          val isKeySave = call.argument<Boolean>("isKeySave")
            if (isKeySave != null) {
                Biometrics().loginBiometrics(isKeySave,this.activity  as FragmentActivity,this.channel )
            }else {
                return
            }

          result.success(true)
        }
        else -> {
          result.notImplemented()
        }
    }
  }
}
