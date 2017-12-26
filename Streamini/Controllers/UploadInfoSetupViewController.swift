//
//  UploadInfoSetupViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 6/13/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class UploadInfoSetupViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet var videoTitleTxt:UITextField!
    @IBOutlet var videoCategoryTxt:UITextField!
    
    var isCancel=false
    var categories=[Category]()
    let categoriesPicker=UIPickerView()
    var selectedCategoryID:Int!
    
    override func viewDidLoad()
    {
        StreamConnector().categories(categoriesSuccess, categoriesFailure)
        
        categoriesPicker.delegate=self
        categoriesPicker.dataSource=self
        
        categoriesPicker.backgroundColor=UIColor.black.withAlphaComponent(0.5)
        
        let barButtonItem1=UIBarButtonItem(barButtonSystemItem:.done, target:self, action:#selector(closePicker))
        let barButtonItem2=UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target:nil, action:nil)
        
        let toolBar=UIToolbar(frame:CGRect(x:0, y:0, width:view.frame.width, height:44))
        toolBar.items=[barButtonItem2, barButtonItem1]
        
        videoCategoryTxt.inputView=categoriesPicker
        videoCategoryTxt.inputAccessoryView=toolBar
    }
    
    func closePicker()
    {
        videoCategoryTxt.resignFirstResponder()
    }
    
    @IBAction func upload()
    {
        if validateTextFieldsBeforeSubmit()
        {
            navigationController!.popViewController(animated:true)
        }
    }
    
    @IBAction func cancel()
    {
        isCancel=true
        navigationController!.popViewController(animated:true)
    }
    
    func textFieldShouldReturn(_ textField:UITextField)->Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField:UITextField, shouldChangeCharactersInRange range:NSRange, replacementString string:String)->Bool
    {
        if(textField==videoCategoryTxt)
        {
            return false
        }
        
        return true
    }

    func numberOfComponents(in pickerView:UIPickerView)->Int
    {
        return 1
    }
    
    func pickerView(_ pickerView:UIPickerView, numberOfRowsInComponent component:Int)->Int
    {
        return categories.count
    }
    
    func pickerView(_ pickerView:UIPickerView, titleForRow row:Int, forComponent component:Int)->String?
    {
        return categories[row].name
    }
    
    func pickerView(_ pickerView:UIPickerView, didSelectRow row:Int, inComponent component:Int)
    {
        videoCategoryTxt.text=categories[row].name
        selectedCategoryID=categories[row].id
    }
    
    func categoriesSuccess(cats:[Category])
    {
        categories=cats
    }
    
    func categoriesFailure(error:NSError)
    {
        handleError(error)
    }
    
    func validateTextFieldsBeforeSubmit()->Bool
    {
        var alertController:UIAlertController?
        var validate=true
        
        if videoTitleTxt.text==""
        {
            alertController=UIAlertController(title:"Message", message:"Please enter video title", preferredStyle:.alert)
            validate=false
        }
        else if videoCategoryTxt.text==""
        {
            alertController=UIAlertController(title:"Message", message:"Please select video category", preferredStyle:.alert)
            validate=false
        }
        
        if let alert=alertController
        {
            alert.addAction(UIAlertAction(title:"OK", style:.cancel, handler:nil))
            present(alert, animated:true)
        }
        
        return validate
    }
}
