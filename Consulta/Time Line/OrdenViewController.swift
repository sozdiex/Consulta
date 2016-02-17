//
//  OrdenViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 17/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit
import Foundation

class OrdenViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {

    @IBOutlet var tableView : UITableView!
    @IBOutlet var labelSesion : UILabel!
    @IBOutlet var btnLeft : UIBarButtonItem!
    @IBOutlet var btnIniciarSesion : UIBarButtonItem!
    @IBOutlet var barTitle : UINavigationItem!
    
    private var array : NSMutableArray = NSMutableArray()
    private var currentDicSelected : NSDictionary!
    private var currentTitle : String!
    var nameSesion = ""
    var isFromCalendario = false
    var isReloadButton = false
    
    //MARK: - load
    
    override func viewDidLoad() {
        self.frostedViewController.presentMenuViewController()
        
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
        tableView.delegate = self
        tableView.tableHeaderView = ({
            var view = UIView(frame: CGRectMake(0, 0, 2, 195))
            
            var imageView = UIImageView(frame: CGRectMake(0, 0, 500, 190))
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin;
            imageView.image =  UIImage(named: "logo")
            imageView.layer.masksToBounds = true;
            imageView.layer.rasterizationScale = UIScreen.mainScreen().scale;
            imageView.layer.shouldRasterize = true;
            imageView.clipsToBounds = true;
            
            view.addSubview(imageView)
            return view
        })()
        
        let sn_administrador = NSUserDefaults.standardUserDefaults().objectForKey("sn_administrador") as! Bool
        let sn_consulta = NSUserDefaults.standardUserDefaults().objectForKey("sn_consulta") as! Bool
        if sn_administrador && sn_consulta {
            btnIniciarSesion.title = "Acciones"
        } else {
            btnIniciarSesion.title = "Recargar"
        }
        
        if isFromCalendario {
            btnLeft.image = UIImage(named: "icoAtras")
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formater = NSDateFormatter()
            formater.dateFormat = "'Sesión 'dd' de 'MMMM' del 'yyyy"
            var fechaText = formater.stringFromDate(dateFormatter.dateFromString(nameSesion)!)
            self.labelSesion.text = fechaText
            //btnIniciarSesion.enabled = false;
            //btnIniciarSesion.title =  nil;
            barTitle.title = "Orden Anterior"
        } else {
            btnLeft.image = UIImage(named: "icoMenu")
            let formater = NSDateFormatter()
            formater.dateFormat = "'Sesión 'dd' de 'MMMM' del 'yyyy"
            var fechaText = formater.stringFromDate(NSDate())
            self.labelSesion.text = fechaText
            barTitle.title = "Orden del día"
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Helpers
    func activarBotonReload() {
        btnIniciarSesion.title = "Recargar"
        btnIniciarSesion.enabled = true
        isReloadButton = true
    }
    
    func reloadInfo() {
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.center = CGPointMake(UIScreen.mainScreen().applicationFrame.size.width/2.0, UIScreen.mainScreen().applicationFrame.size.height/2.0)
        spinner.color = UIColor.blackColor()
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {
            var dic : NSDictionary = NSDictionary()
            
            if self.isFromCalendario {
                dic = Fetcher.getTitles(self.nameSesion)
            } else {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                println(dateFormatter.stringFromDate(NSDate()))
                
                dic = Fetcher.getTitles(dateFormatter.stringFromDate(NSDate()))
                //dic = Fetcher.getTitles("2015-03-17")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if dic.objectForKey("rs_temas") != nil {
                    self.adjustArray(dic)
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                } else {
                    let AlertView = CustomAlertViewController()
                    AlertView.text = "No hay sesión el día de hoy"
                    self.presentViewController(AlertView, animated: true, completion: nil)
                }
                spinner.stopAnimating()
            })
        })
    }
    
    func adjustArray(dicService : NSDictionary) {
        array = NSMutableArray()
        
        let arrayTemp : NSArray = dicService.objectForKey("rs_temas") as! NSArray
        
        if !isFromCalendario {
            if dicService.objectForKey("sn_iniciada") != nil {
                NSUserDefaults.standardUserDefaults().setObject(dicService.objectForKey("sn_iniciada"), forKey: "sn_iniciada")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
      
        var id_tema = -1
        
        for  i in  0...arrayTemp.count-1  {
            var dic : NSMutableDictionary = NSMutableDictionary()
            let dicAxu =  arrayTemp.objectAtIndex(i) as! NSDictionary
            
            if id_tema != dicAxu.objectForKey("id_tema") as! Int {
                dic.setValue(dicAxu.objectForKey("nb_tema"), forKey: "tema")
                dic.setValue(dicAxu.objectForKey("nu_docs_tema"), forKey: "num_docs")
                dic.setValue(dicAxu.objectForKey("nu_ordentema"), forKey: "nu_orden")
                dic.setValue(dicAxu.objectForKey("id_tema"), forKey: "id_tema")
                dic.setValue("cell", forKey: "cell")
                dic.setValue(dicAxu.objectForKey("id_sesion"), forKey: "id_sesion")
                dic.setValue(dicAxu.objectForKey("sn_votacion_tema"), forKey: "sn_votacion")
                dic.setValue(dicAxu.objectForKey("sn_votacioniniciadatema"), forKey: "sn_votacionActivada")
                dic.setValue(dicAxu.objectForKey("sn_votacionterminadatema"), forKey: "sn_votacionDesactivada")


                if dicAxu.objectForKey("id_subtema")?.integerValue > 0 {
                    dic.setValue(true, forKey: "temaBool")
                } else {
                    dic.setValue(false, forKey: "temaBool")
                }
                
                array.addObject(dic)
                id_tema = dicAxu.objectForKey("id_tema") as! Int
            }
            
            if dicAxu.objectForKey("id_subtema")?.integerValue > 0 {
                dic = NSMutableDictionary()
                dic.setValue(dicAxu.objectForKey("nb_subtema"), forKey: "tema")
                dic.setValue(dicAxu.objectForKey("nu_docs_subtema"), forKey: "num_docs")
                dic.setValue(dicAxu.objectForKey("nu_ordensubtema"), forKey: "nu_orden")
                dic.setValue(dicAxu.objectForKey("id_tema"), forKey: "id_tema")
                dic.setValue(dicAxu.objectForKey("id_subtema"), forKey: "id_subtema")
                dic.setValue(dicAxu.objectForKey("id_sesion"), forKey: "id_sesion")
                dic.setValue("margenCell", forKey: "cell")
                dic.setValue(false, forKey: "temaBool")
                dic.setValue(dicAxu.objectForKey("sn_votacion_subtema"), forKey: "sn_votacion")
                dic.setValue(dicAxu.objectForKey("sn_votacioniniciadasubtema"), forKey: "sn_votacionActivada")
                dic.setValue(dicAxu.objectForKey("sn_votacionterminadasubtema"), forKey: "sn_votacionDesactivada")
                dic.setValue(dicAxu.objectForKey("nu_ordensubtema"), forKey: "nu_orden")
                array.addObject(dic)
            }
        }
        
        println(array)
    }
    
    func activarBoton() {
        let sn_administrador = NSUserDefaults.standardUserDefaults().objectForKey("sn_administrador") as! Bool
        if sn_administrador {
            btnIniciarSesion.title = "Guardar"
        } else {
            btnIniciarSesion.title = "Recargar"
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushArchivo" {
            var WebController = segue.destinationViewController as! WebViewController
            var id_sesion = currentDicSelected.objectForKey("id_sesion") as! NSNumber
            WebController.id_Sesion = id_sesion.stringValue
            var id_tema = currentDicSelected.objectForKey("id_tema") as! NSNumber
            WebController.id_tema = id_tema.stringValue
            WebController.dateSesion = nameSesion
            WebController.isOneDocument = true
            
            if currentDicSelected.objectForKey("id_subtema") != nil {
                var id_subTema = currentDicSelected.objectForKey("id_subtema") as! NSNumber
                WebController.id_subTema = id_subTema.stringValue
            } else {
                WebController.id_subTema = ""
            }
            
            //WebController.titulo = currentTitle
        } else if segue.identifier == "pushMultiArchivos" {
            var WebController = segue.destinationViewController as! MultipleArchivosViewController
            var id_sesion = currentDicSelected.objectForKey("id_sesion") as! NSNumber
            WebController.id_Sesion = id_sesion.stringValue
            var id_tema = currentDicSelected.objectForKey("id_tema") as! NSNumber
            WebController.id_tema = id_tema.stringValue
            WebController.dateSesion = nameSesion
            
            if currentDicSelected.objectForKey("id_subtema") != nil {
                var id_subTema = currentDicSelected.objectForKey("id_subtema") as! NSNumber
                WebController.id_subTema = id_subTema.stringValue
            } else {
                WebController.id_subTema = ""
            }
        }
    }
    
    @IBAction func unWind (segue: UIStoryboardSegue) {
       println("unWind")
    }
    
    @IBAction func unWindToOrden (segue: UIStoryboardSegue) {
        println("unWind on Orden")
    }
    
    // MARK: - UITableView - DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var dic = array.objectAtIndex(indexPath.row) as! NSDictionary
        
        var identifierCell = ""
        identifierCell = dic.objectForKey("cell") as! String
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifierCell) as! unLabelCell
        
        cell.label.text = dic.objectForKey("tema") as? String
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor.whiteColor()
        cell.label.textColor = UIColor.blackColor()
        
        if dic.objectForKey("temaBool") as! Bool {
            cell.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
            cell.label.textColor = UIColor.whiteColor()
        }
        
        if dic.objectForKey("num_docs") as! Int > 0 {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        }
        cell.bringSubviewToFront(cell.viewSeperator)
        return cell


    }
    
    // MARK: - UITableView - Delegate
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item : NSDictionary = array[sourceIndexPath.row] as! NSDictionary
        array.removeObjectAtIndex(sourceIndexPath.row)
        array.insertObject(item, atIndex: destinationIndexPath.row)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var dic = array.objectAtIndex(indexPath.row) as! NSDictionary
        if dic.objectForKey("num_docs") as! Int > 0 {
            currentDicSelected = dic
            if dic.objectForKey("num_docs") as! Int == 1 {
                self.performSegueWithIdentifier("pushArchivo", sender: self)
            } else {
                self.performSegueWithIdentifier("pushMultiArchivos", sender: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var dic : NSDictionary = array.objectAtIndex(indexPath.row) as! NSDictionary
        var height : CGFloat = 30
       
        var width : CGFloat = 969
        if UIDevice.currentDevice().orientation.isPortrait {
            width = 709
        }
    
        height += getHeightFrom(dic.objectForKey("tema") as! String, font: UIFont(name: "Arial", size: 19.0)!, width: width)
        return height;
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
       return UITableViewCellEditingStyle.None;
    }
    
    
    func getHeightFrom(texto : String, font: UIFont, width: CGFloat) -> CGFloat{
        var labelTexto : UILabel = UILabel(frame: CGRectMake(0, 0, width, 9999))
        labelTexto.text = texto
        labelTexto.font = font
        labelTexto.numberOfLines = 0
        labelTexto.sizeToFit()
        return labelTexto.bounds.size.height;
    }
    
    // MARK: - Buttons Actions
    @IBAction func touchMenu() {
        if isFromCalendario {
            self.performSegueWithIdentifier("unWind", sender: self)
        } else {
            self.frostedViewController.presentMenuViewController()
            
        }
    }
    
    @IBAction func touchIniciarSesion() {
        let sn_administrador = NSUserDefaults.standardUserDefaults().objectForKey("sn_administrador") as! Bool
        let sn_consulta = NSUserDefaults.standardUserDefaults().objectForKey("sn_consulta") as! Bool
        if sn_administrador && sn_consulta {
            if tableView.editing{
                let actionSheet : UIActionSheet = UIActionSheet(title: "Seleccionar una acción", delegate: self, cancelButtonTitle: "Aceptar", destructiveButtonTitle: nil, otherButtonTitles: "Guardar", "Cancelar") as UIActionSheet
                actionSheet.tag = 2
                actionSheet.showInView(self.view)
            } else {
                let actionSheet : UIActionSheet = UIActionSheet(title: "Seleccionar una acción", delegate: self, cancelButtonTitle: "Aceptar", destructiveButtonTitle: nil, otherButtonTitles: "Recargar", "Modificar orden") as UIActionSheet
                actionSheet.tag = 1
                actionSheet.showInView(self.view)
            }
        } else {
            reloadInfo()
        }
    }
    
    func ordenarArray() {
        var arrayTemp = NSMutableArray()
        var id_sesion = ""
        for  i in  0...array.count-1  {
            var dic = array.objectAtIndex(i) as! NSDictionary
            var dicNew = NSMutableDictionary()
            dicNew.setValue(NSNumber(integer: i + 1), forKey: "nu_orden")
            dicNew.setValue(dic.objectForKey("id_tema"), forKey: "id_tema")
            arrayTemp.addObject(dicNew)
            id_sesion = (dic.objectForKey("id_sesion") as! NSNumber).stringValue
        }

        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.center = CGPointMake(UIScreen.mainScreen().applicationFrame.size.width/2.0, UIScreen.mainScreen().applicationFrame.size.height/2.0)
        spinner.color = UIColor.blackColor()
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {
           let dic = Fetcher.guardarNuevoOrden(id_sesion, withOrden: arrayTemp) as NSDictionary
            
            dispatch_async(dispatch_get_main_queue(), {
                if !(dic.objectForKey("sn_error") as! Bool){
                    let AlertView = CustomAlertViewController()
                    AlertView.text = "Se guardaron el orden correctamente "
                    self.presentViewController(AlertView, animated: true, completion: nil)
                     self.tableView.setEditing(false, animated: true)
                    self.reloadInfo()
                } else {
                    let AlertView = CustomAlertViewController()
                    AlertView.text = "Ocurrio un Error, favor de volver a intentar"
                    self.presentViewController(AlertView, animated: true, completion: nil)
                }
                spinner.stopAnimating()
            })
        })
    }
    
    // MARK: - ActionSheet
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
       if actionSheet.tag == 1 {
            if buttonIndex == 1 {
                reloadInfo()
            } else if buttonIndex == 2 {
                tableView.setEditing(true, animated: true);
            }
        }
        if actionSheet.tag == 2 {
            if buttonIndex == 1 {
                //guardar
                ordenarArray()
            } else if buttonIndex == 2{
                tableView.setEditing(false, animated: true)
                reloadInfo()
            }
        }
    }
}