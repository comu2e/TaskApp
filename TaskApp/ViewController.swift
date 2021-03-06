//
//  ViewController.swift
//  TaskApp
//
//  Created by Eiji Takahashi on 2016/06/27.
//  Copyright © 2016年 devlpEiji. All rights reserved.
//

import UIKit
import RealmSwift
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)   // ←追加
    
    
    
//    storyboardで設定済み
    @IBOutlet weak var searchbar: UISearchBar!
    

    
    
//    TaskArray保存用
    var storeTask = try! Realm().objects(Task).sorted("date", ascending: false)   // ←追加
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        検索バーに何も入力されていなくでもReturnキーが押せるようにしておく
        searchbar.enablesReturnKeyAutomatically = false
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // segue で画面遷移するに呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        //        searchBar.endEditing(true)
        //        検索バーの文字を取得
        let search_text = searchbar.text!
        taskArray = realm.objects(Task).filter("category = '\(search_text)'").sorted("date", ascending: false)
        tableView.reloadData()
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
       self.taskArray = self.storeTask
        tableView.reloadData()
        
    }
 
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchbar.resignFirstResponder()

        self.taskArray = self.storeTask

        tableView.reloadData()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←追加する
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    //ViewController画面にもどってくるメソッド
    //保存ボタンを押すと戻ってくる
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
    }

}
    
