import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // ユーザに通知の許可を求める
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        // 通知からの起動かどうか確認する
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            // 通知領域から削除する
            application.cancelLocalNotification(notification)
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // アプリがフォアグランドにいる時に通知が届いた時
        if application.applicationState == UIApplicationState.Active {
            // アラートを表示する
            let alertController = UIAlertController(title: "時間になりました", message:notification.alertBody, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(defaultAction)
            
            window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
        } else {
            // バックグランドにいる時に通知が届いた時はログに出力するだけ
            print("\(notification.alertBody)")
        }
        
        // 通知領域から削除する
        application.cancelLocalNotification(notification)
    }
    
}
