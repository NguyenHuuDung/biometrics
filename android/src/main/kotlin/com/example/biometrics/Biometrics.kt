package com.example.biometrics

import android.annotation.SuppressLint
import android.content.ContentValues.TAG
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.security.KeyStoreException
import java.util.concurrent.Executor
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey


class Biometrics {
    private val ANDROID_KEY_STORE = "AndroidKeyStore"
    private val ANDROID_KEY_NAME = "ANDROID_KEY_NAME"
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
                        authenticateUserFail("Thông tin xác thực bảo mật không có sẵn.","Error" )
                    }
                    BiometricPrompt.ERROR_NO_SPACE, BiometricPrompt.ERROR_NO_BIOMETRICS -> {
                        authenticateUserFail("Vui lòng đăng ký ít nhất một dấu vân tay trong phần cài đặt màn hình khóa và bảo mật, trên thiết bị","Error")
                    }
                    BiometricPrompt.ERROR_HW_UNAVAILABLE, BiometricPrompt.ERROR_HW_NOT_PRESENT -> {
                        authenticateUserFail("Thiết bị của bạn không hỗ trợ tính năng đăng nhập bằng vân tay","Error")
                    }
                    BiometricPrompt.ERROR_LOCKOUT -> {
                        authenticateUserFail("Vân tay bị khóa do quá nhiều lần thử. Điều này xảy ra sau 5 lần thử không thành công và kéo dài trong 30 giây.","Error")
                    }

                    BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> {
                        authenticateUserFail("Xác thực sinh trắc học bị tắt cho đến khi người dùng mở khóa bằng xác thực mạnh (PIN / Hình / Mật khẩu)","Error")
                    }
                    BiometricPrompt.ERROR_CANCELED ->  {
                        authenticateUserFail("Huỷ bỏ xác thực vân tay","Error")
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
//                val encryptedInfo: ByteArray = result.cryptoObject.cipher?.doFinal(
//                    plaintext-string.toByteArray(Charset.defaultCharset())
//                )
//                Log.d("MY_APP_TAG", "Encrypted information: " +
//                        Arrays.toString(encryptedInfo))
                if(isSwitch != "") {
                    if (!isSwitch.toBoolean()) {
                        authenBiometricsOn("Bạn đã cài đặt vân tay thành công")
                    } else if (isSwitch.toBoolean()) {
                        authenBiometricsOff("Bạn đã huỷ cài đặt vân tay thành công")
                    }
                }
                if(isKeySave != "") {
                    if (isKeySave.toBoolean()) {
                        authenBiometricsOn("Bạn đăng nhập thành công")
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

    private fun authenticateUserFail(@NonNull message: String, type: String) {
        val param = mapOf(Pair("message", message),Pair("type", type))
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

    fun configBiometric(isSwitch: Boolean, activity : FragmentActivity, channel : MethodChannel) {
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
                        authenticateUserFail("$e", "Error")
                    }
                } else {
                    return
                }
            } else {
                canEvaluatePolicyFail("Build.VERSION.SDK_INT >= Build.VERSION_CODES.M")
                return
            }
    }

    @SuppressLint("NewApi")
    @RequiresApi(Build.VERSION_CODES.M)
    fun loginBiometrics(isKeySave: Boolean, activity : FragmentActivity, channel : MethodChannel) {
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
                        val cipher = getCipher()
                        val secretKey = getSecretKey()
                        cipher.init(Cipher.ENCRYPT_MODE, secretKey)
                        biometricPrompt.authenticate(promptInfo,BiometricPrompt.CryptoObject(cipher))
                    } catch (keyper : KeyPermanentlyInvalidatedException) {
                        this.deleteKey()
                        authenticateUserFail("$keyper", "Change")
                    } catch ( e: Exception) {
                        authenticateUserFail("$e", "Error")
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


    @RequiresApi(Build.VERSION_CODES.M)
    private fun generateSecretKey(): SecretKey  {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEY_STORE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            keyGenerator.init(KeyGenParameterSpec.Builder(
                ANDROID_KEY_NAME,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
                .setUserAuthenticationRequired(true)
                .setInvalidatedByBiometricEnrollment(true)
                .build())
        }
       return keyGenerator.generateKey()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun getSecretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE).apply { load(null) }
        if (keyStore.getEntry(ANDROID_KEY_NAME, null) != null) {
            val secretKeyEntry = keyStore.getEntry(ANDROID_KEY_NAME, null) as KeyStore.SecretKeyEntry
            return (secretKeyEntry.secretKey ?: generateSecretKey()) as SecretKey
        }
        return generateSecretKey()
    }

    private fun getCipher(): Cipher {
        return Cipher.getInstance(KeyProperties.KEY_ALGORITHM_AES + "/"
                + KeyProperties.BLOCK_MODE_CBC + "/"
                + KeyProperties.ENCRYPTION_PADDING_PKCS7)
    }

    private fun loadKeyStore(): KeyStore {
        val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE)
        keyStore.load(null)
        return keyStore
    }


    fun deleteKey() {
        val keyStore: KeyStore = loadKeyStore()
        try {
            keyStore.deleteEntry(ANDROID_KEY_NAME)
        } catch (e: KeyStoreException) {
            e.printStackTrace()
            throw e
        }
    }

}