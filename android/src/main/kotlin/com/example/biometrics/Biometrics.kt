package com.example.biometrics

import android.content.ContentValues.TAG
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor


class Biometrics {
    lateinit var channel : MethodChannel
    private lateinit var executor: Executor
    private lateinit var biometricPrompt: androidx.biometric.BiometricPrompt
    private lateinit var promptInfo: androidx.biometric.BiometricPrompt.PromptInfo
    lateinit var activity : FragmentActivity
    private  var isSwitch: String = ""
    private  var isKeySave: String = ""
    private fun createBiometricPrompt(): androidx.biometric.BiometricPrompt {
        val executor = ContextCompat.getMainExecutor(activity)
        val callback = object : androidx.biometric.BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                when (errorCode) {
                    BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL -> {
                        authenticateUserFail("Thông tin xác thực bảo mật không có sẵn.")
                    }
                    BiometricPrompt.ERROR_NO_SPACE, BiometricPrompt.ERROR_NO_BIOMETRICS -> {
                        authenticateUserFail("Vui lòng đăng ký ít nhất một dấu vân tay trong phần cài đặt màn hình khóa và bảo mật, trên thiết bị")
                    }
                    BiometricPrompt.ERROR_HW_UNAVAILABLE, BiometricPrompt.ERROR_HW_NOT_PRESENT -> {
                        authenticateUserFail("Thiết bị của bạn không hỗ trợ tính năng đăng nhập bằng vân tay")
                    }
                    BiometricPrompt.ERROR_LOCKOUT -> {
                        authenticateUserFail("Vân tay bị khóa do quá nhiều lần thử. Điều này xảy ra sau 5 lần thử không thành công và kéo dài trong 30 giây.")
                    }

                    BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> {
                        authenticateUserFail("Xác thực sinh trắc học bị tắt cho đến khi người dùng mở khóa bằng xác thực mạnh (PIN / Hình / Mật khẩu)")
                    }
                    BiometricPrompt.ERROR_CANCELED ->  {
                        authenticateUserFail("Huỷ bỏ xác thực vân tay")
                        return;
                    }
                }
                Log.d(TAG, "$errorCode :: $errString")
            }

            override fun onAuthenticationFailed() {
                super.onAuthenticationFailed()
                Log.d(TAG, "Authentication failed for an unknown reason")
            }

            override fun onAuthenticationSucceeded(result: androidx.biometric.BiometricPrompt.AuthenticationResult) {
                super.onAuthenticationSucceeded(result)
                if(isSwitch != "") {
                    if (isSwitch.toBoolean()) {
                        authenBiometricsOn("Bạn đã cài đặt vân tay thành công")
                    } else if (!isSwitch.toBoolean()) {
                        authenBiometricsOff("Bạn đã huỷ cài đặt vân tay thành công")
                    }
                }
                if(isKeySave != "") {
                    if (isKeySave.toBoolean()) {
                        authenBiometricsOn("Bạn đăng nhập thành công")
                    } else if (!isKeySave.toBoolean()) {
                        authenBiometricsOff("Bạn đăng nhập không thành công")
                    }
                }
            }
        }

        return BiometricPrompt(activity, executor, callback)
    }

    private fun createPromptInfo(): androidx.biometric.BiometricPrompt.PromptInfo {
        return BiometricPrompt.PromptInfo.Builder()
            .setTitle("Sử dụng vân tay cho ứng dụng")
            .setDescription("Vui lòng quét vân tay để đăng nhập")
            .setConfirmationRequired(false)
            .setNegativeButtonText("Huỷ")
            .setAllowedAuthenticators(BIOMETRIC_STRONG)
            .build()
    }



    private fun authenBiometricsOn(@NonNull message: String) {
        val param = mapOf(Pair("message", message))
        channel.invokeMethod("authenBiometricsOn", param)
    }

    private fun authenBiometricsOff(@NonNull  message: String) {
        val param = mapOf(Pair("message", message))
        channel.invokeMethod("authenBiometricsOff", param)
    }

    private fun canEvaluatePolicyFail(@NonNull  message: String) {
        val param = mapOf(Pair("message", message))
        channel.invokeMethod("canEvaluatePolicyFail", param)
    }

    private fun authenticateUserFail(@NonNull message: String) {
        val param = mapOf(Pair("message", message))
        channel.invokeMethod("authenticateUserFail", param)
    }

    private fun notKeySave(@NonNull  message: String) {
        val param = mapOf(Pair("message", message))
        channel.invokeMethod("notKeySave", param)
    }


    @RequiresApi(api = Build.VERSION_CODES.M)
    private fun canEvaluatePolicyFail(): Boolean {
        val biometricManager = BiometricManager.from(activity)
        when (biometricManager.canAuthenticate(BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> {
                canEvaluatePolicyFail("Thiết bị của bạn không hỗ trợ tính năng đăng nhập bằng vân tay")
            }
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> {
                canEvaluatePolicyFail("Vui lòng thiết lập tính năng màn hình khóa, trong phần cài đặt trên thiết bị")
            }
            BiometricManager.BIOMETRIC_SUCCESS -> {
                return true
            }
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> {
                canEvaluatePolicyFail("Vui lòng đăng ký ít nhất một dấu vân tay trong phần cài đặt màn hình khóa và bảo mật, trên thiết bị")
            }
            BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED  -> {
                    canEvaluatePolicyFail("Người dùng không thể xác thực vì các tùy chọn được chỉ định không tương thích với phiên bản Android hiện tại")
            }
        }
        return false
    }

    fun configBiometric(isSwitch: Boolean, activity : FragmentActivity,channel : MethodChannel) {
        this.activity = activity
        this.channel = channel
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (canEvaluatePolicyFail()) {
                    try {
                        this.isSwitch = "$isSwitch"
                        this.isKeySave = ""
                        biometricPrompt = createBiometricPrompt()
                        promptInfo = createPromptInfo()
                        biometricPrompt.authenticate(promptInfo)
                    } catch (e: Exception) {
                        canEvaluatePolicyFail("$e")
                    }
                } else {
                    return
                }
            } else {
                canEvaluatePolicyFail("Build.VERSION.SDK_INT >= Build.VERSION_CODES.M")
                return
            }
    }

    fun loginBiometrics(isKeySave: Boolean, activity : FragmentActivity,channel : MethodChannel) {
        this.channel = channel
        this.activity = activity
        if(!isKeySave) {
            notKeySave("Vui lòng đăng nhập tài khoản và thêm phương thức xác thực vân tay để sử dụng tính năng này")
        }else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (canEvaluatePolicyFail()) {
                    try {
                        this.isKeySave = "$isKeySave"
                        this.isSwitch = ""
                        biometricPrompt = createBiometricPrompt()
                        promptInfo = createPromptInfo()
                        biometricPrompt.authenticate(promptInfo)
                    } catch (e: Exception) {
                        canEvaluatePolicyFail("$e")
                    }
                } else {
                    return
                }
            } else {
                canEvaluatePolicyFail("Build.VERSION.SDK_INT >= Build.VERSION_CODES.M")
                return
            }
        }

    }



}