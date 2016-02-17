//
//  WebViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 18/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit
import MessageUI

class WebViewController: UIViewController, UIWebViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var webView : UIWebView!
    @IBOutlet var spinner : UIActivityIndicatorView!
    var isOneDocument = false
    var id_Sesion : String!
    var id_tema : String!
    var id_subTema : String!
    var nameFile : String!
    var dateSesion : String!
    var titulo : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isOneDocument {
            var downloadQueue :dispatch_queue_t = dispatch_queue_create("callDocuments", nil)
                dispatch_async(downloadQueue, {
                    let dic = Fetcher.getDocuments(self.id_Sesion, withTema: self.id_tema, orSubTema: self.id_subTema, andDate: self.dateSesion) as NSDictionary
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if dic.objectForKey("rs") != nil {
                        let arrayTemp = dic.objectForKey("rs") as! NSArray
                        let dicAux = arrayTemp.objectAtIndex(0) as! NSDictionary
                        
                        var urlPdf = kAppUrl + "/votaciones/" + (dicAux.objectForKey("ar_documento") as! String)
                        urlPdf = urlPdf.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                        var remoteUrl : NSURL = NSURL(string: urlPdf)!
                        var request = NSURLRequest(URL: remoteUrl)
                        self.webView.loadRequest(request)
                        self.webView.backgroundColor = UIColor.whiteColor()
                    }
                })
            })
        } else {
            /*var filePath = NSBundle.mainBundle().pathForResource(self.nameFile, ofType: "pdf")
            var targetURL : NSURL = NSURL.fileURLWithPath(filePath!)!
            var request : NSURLRequest = NSURLRequest(URL: targetURL)
            self.webView.loadRequest(request)
            self.webView.backgroundColor = UIColor.whiteColor()*/
            nameFile = nameFile.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            var remoteUrl : NSURL = NSURL(string: nameFile)!
            var request = NSURLRequest(URL: remoteUrl)
            self.webView.loadRequest(request)
            self.webView.backgroundColor = UIColor.whiteColor()
        }
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
    }
    */
    
    @IBAction func unWind (segue: UIStoryboardSegue) {
        println("unWind")
    }
    
    //MARK: - IBActions Buttons 
    @IBAction func touchSendEmail(){
        var picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Documento")
        picker.setMessageBody("prueba de correo", isHTML: true)
        
        presentViewController(picker, animated: true, completion: nil)
    }

    
    // MARK: - WebView Delegate
    func webViewDidStartLoad(webView: UIWebView) {
        spinner.startAnimating()
        //spinner.hidden = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        spinner.stopAnimating()
        //spinner.hidden = true
    }
}
