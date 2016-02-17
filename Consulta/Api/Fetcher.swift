//
//  Fetcher.swift
//  Consulta
//
//  Created by Armando Trujillo Zazueta  on 26/04/15.
//  Copyright (c) 2015 Armando Trujillo zazueta. All rights reserved.
//

import UIKit

let kAppKey : String = "/votaciones"
let kAppUrl:String = "http://198.12.150.208"

class Fetcher: NSObject {
    
    class func validateUsuer(user : String, andPassword pass : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/validarusuarioTodos.cfm"
        servicePost.addParamPOSTWithKey("nb_usuario", andValue: user)
        servicePost.addParamPOSTWithKey("cl_contrasena", andValue: pass)
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("token") != nil) {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            servicePost.addParamPOSTWithKey("token", andValue: token)
        }
        
        
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func msgInternet() -> UIAlertView {
        return UIAlertView(title: "Advertencia", message: "No tienes conexion a internet, favor de revisar su conexion y volver a intentar", delegate: nil, cancelButtonTitle: "Aceptar")
    }
    
    class func getTitles(date : String) -> NSDictionary {
        let serviceGet : callService = callService()
        serviceGet.httpMethod = "GET"
        serviceGet.url = kAppUrl +  kAppKey + "/api_rest/obtenertemasdocumentos.cfm"
        serviceGet.addParamGETWithKey("fh_sesion", andValue: date)
        let dic : NSDictionary = serviceGet.callService()
        return dic
    }
    
    class func getDocuments(id_sesion : String, withTema tema : String, orSubTema subTema : String, andDate fecha : String) -> NSDictionary {
        let serviceGet : callService = callService()
        serviceGet.httpMethod = "GET"
        serviceGet.url = kAppUrl +  kAppKey + "/api_rest/obtenerdocstemassubtemas.cfm"
        serviceGet.addParamGETWithKey("id_Sesion", andValue: id_sesion)
        serviceGet.addParamGETWithKey("id_tema", andValue: tema)
        serviceGet.addParamGETWithKey("fh_sesion", andValue: fecha)
        
        if subTema != "" {
            serviceGet.addParamGETWithKey("id_subtema", andValue: subTema)
        }
        
        let dic : NSDictionary = serviceGet.callService()
        return dic
    }
    
    class func guardarNuevoOrden(id_sesion: String, withOrden array : NSMutableArray) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/guardarordentemas.CFM"
        servicePost.addParamPOSTWithKey("id_sesion", andValue: id_sesion)

        let jsonData : NSData = NSJSONSerialization.dataWithJSONObject(array, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        servicePost.addParamPOSTWithKey("arr_temas", andValue: jsonString)
    
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func getGacetasAnteriores() -> NSDictionary {
        let serviceGet : callService = callService()
        serviceGet.httpMethod = "GET"
        serviceGet.url = kAppUrl +  kAppKey + "/api_rest/obtenersesiones.cfm"
        let dic: NSDictionary = serviceGet.callService()
        return dic
    }
}