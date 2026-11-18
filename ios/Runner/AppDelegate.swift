import UIKit
import Flutter
import Photos
import workmanager_apple

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)

    // The database stores account credentials in plain text; flag it so
    // iCloud and Finder/iTunes backups skip it. Users move it deliberately
    // via export/import instead.
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "e1547/storage",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "excludeFromBackup":
          guard let args = call.arguments as? [String: Any],
                let path = args["path"] as? String else {
            result(FlutterError(code: "bad_args", message: "path required", details: nil))
            return
          }
          do {
            let url = NSURL(fileURLWithPath: path)
            try url.setResourceValue(true, forKey: .isExcludedFromBackupKey)
            result(true)
          } catch {
            result(FlutterError(code: "io_error", message: error.localizedDescription, details: nil))
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }

      // Animated GIFs must enter the photo library through an asset
      // creation request that names the GIF's type: the gallery plugin
      // saves them with UIImageWriteToSavedPhotosAlbum, which keeps only
      // the first frame and leaves a still in the gallery. Naming the
      // type identifier stores and plays the whole animation.
      let galleryChannel = FlutterMethodChannel(
        name: "e1547/gallery",
        binaryMessenger: controller.binaryMessenger
      )
      galleryChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "saveGif":
          guard let path = call.arguments as? String else {
            result(FlutterError(code: "bad_args", message: "path required", details: nil))
            return
          }
          let url = URL(fileURLWithPath: path)
          let options = PHAssetResourceCreationOptions()
          options.uniformTypeIdentifier = "com.compuserve.gif"
          PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
              DispatchQueue.main.async {
                result(["isSuccess": false, "errorMessage": "photo library access denied"])
              }
              return
            }
            PHPhotoLibrary.shared().performChanges {
              let request = PHAssetCreationRequest.forAsset()
              request.addResource(with: .photo, fileURL: url, options: options)
            } completionHandler: { success, error in
              DispatchQueue.main.async {
                if success {
                  result(["isSuccess": true])
                } else {
                  result(["isSuccess": false, "errorMessage": error?.localizedDescription ?? "saving failed"])
                }
              }
            }
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }

    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "net.clynamic.e1547.follows",
      frequency: nil,
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
