//
//  InputViewController.swift
//  TaskApp
//
//  Created by Eiji Takahashi on 2016/06/29.
//  Copyright © 2016年 devlpEiji. All rights reserved.
//

import UIKit
import RealmSwift
class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
//    カテゴリーフォームの追加
    @IBOutlet weak var categoryForm: UITextField!
    
    let realm = try! Realm()
    var task:Task!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(InputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
//        カテゴリー追加
        categoryForm.text = task.category
        
//        contexformに枠線，丸みをつける
        contentsTextView.layer.borderWidth = 0.5
        contentsTextView.layer.borderColor = UIColor.blackColor().CGColor
        contentsTextView.layer.masksToBounds = true
          contentsTextView.layer.cornerRadius = 10.0
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
//            画面が戻るときにカテゴリーも追加する
            self.task.category = self.categoryForm.text!
            
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task)
        
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // タスクのローカル通知を設定する
    func setNotification(task: Task) {
        
        // すでに同じタスクが登録されていたらキャンセルする
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if notification.userInfo!["id"] as! Int == task.id {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break   // breakに来るとforループから抜け出せる
            }
        }
        
        let notification = UILocalNotification()
        
        notification.fireDate = task.date
        notification.timeZone = NSTimeZone.defaultTimeZone()
//        カテゴリーも通知で出てくるようにする
        if task.category != ""{
            notification.alertBody = "\(task.title)　\n Category : \(task.category)"
        }
        else{
            notification.alertBody = "\(task.title)"
        }
        
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["id":task.id]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    @IBAction func saveAndBackToTable(sender: AnyObject) {
    }
}
