package com.mindpark.app

import io.flutter.embedding.android.FlutterActivity

import android.os.Bundle
import com.google.android.vending.licensing.LicenseChecker
import com.google.android.vending.licensing.LicenseCheckerCallback
import com.google.android.vending.licensing.ServerManagedPolicy
import com.google.android.vending.licensing.AESObfuscator
import android.widget.Toast
import androidx.appcompat.app.AlertDialog

class MainActivity : FlutterActivity() {

    private lateinit var licenseChecker: LicenseChecker
    private lateinit var licenseCheckerCallback: LicenseCheckerCallback

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize the License Checker
        setupLicenseChecker()
    }

    override fun onDestroy() {
        super.onDestroy()
        licenseChecker.onDestroy() // Clean up resources
    }

    private fun setupLicenseChecker() {
        // Application's public key (replace with your app's public key from Google Play Console)
        val publicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvxX7cndfsaPiOZQV4GQv7HX32AG3hZ4WYroRo8lhMoceetEWIvsdHdPxiLMnem2msn3+KNqIMvxSbMEmWwpBaxV4eqJ0VAkXfbikZVfYHr46wtP2X2Xtv1zf2RaWH7SOlPhu90/Tj+ZG+IXgMpehlsjJvBXDRk/sklDX2lBxd5jgIeKmuZMWAjhZpU7wKcuKxtbsdL69aV8CZya1zIHqdX+/RULJjxDCuk9Fb4jdgvGysNw4QtsV4xlVSwRbqNA6FFw+htv6ihz+Xa26UE3lZsYoQHq54dOg/2FT1Cqtele/o+88zGfhf9kiLV6xtep1k8IkyMis0JZSql2uRtO4AwIDAQAB"

        // Obfuscator for additional security
        val obfuscator = AESObfuscator(
            packageName.toByteArray(),
            packageName,
            android.provider.Settings.Secure.getString(contentResolver, android.provider.Settings.Secure.ANDROID_ID)
        )

        // Use a server-managed policy for license checks
        val policy = ServerManagedPolicy(this, obfuscator)

        // Initialize LicenseChecker with the policy and public key
        licenseChecker = LicenseChecker(this, policy, publicKey)

        // Set up the callback for license check results
        licenseCheckerCallback = object : LicenseCheckerCallback {
            override fun allow(reason: Int) {
                // License is valid
                runOnUiThread {
                    Toast.makeText(this@MainActivity, "License valid!", Toast.LENGTH_SHORT).show()
                }
            }

            override fun dontAllow(reason: Int) {
                // License is invalid
                runOnUiThread {
                    Toast.makeText(this@MainActivity, "License not valid!", Toast.LENGTH_SHORT).show()
                }
            }

            override fun applicationError(errorCode: Int) {
                // There was an error in the license check process
                runOnUiThread {
                    Toast.makeText(this@MainActivity, "License check error: $errorCode", Toast.LENGTH_SHORT).show()
                }
            }
        }

        // Start the license check
        licenseChecker.checkAccess(licenseCheckerCallback)
    }

    private fun showBlockingDialog(title: String, message: String) {
        AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(message)
            .setCancelable(false) // Prevent dismissing the dialog
            .setPositiveButton("OK") { _, _ ->
                finish() // Close the app
            }
            .show()
    }
}

