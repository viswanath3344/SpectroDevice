//
//  ViewController.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 19/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit
import Charts
import SwiftSocket
import MBProgressHUD
import DropDown


//let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]




class HomeViewController: UIViewController {
    
    
    let dynParamsVal = [
        "wavelengthCalcVal": 0.0,
        "r1": 0.9,
        "r2": 0.85,
        "r3": 0.79,
        "r4": 0.65,
        "r5": 0.53,
        "r6": 0.45,
        "c1": 0.0,
        "c2": 0.20,
        "c3": 0.50,
        "c4": 0.100,
        "c5": 0.300,
        "c6": 0.1000,
        "a1": -241.5291470689377,
        "a2": 1.9720887800896016,
        "a3": -0.001580973687293784,
        "a4": 6.9362527556691027e-07
       // [-241.5291470689377, 1.9720887800896016, -0.001580973687293784, 6.9362527556691027e-07]
    ]
    
    var pixelXAxis = [Double]()
    var wavelengthXAxis = [Double]()
    
    var intensityArray = [Double]()
    var hexaDecimalArray = [String]() // For Hexadecimal values , Does't need in real time. It's for testing purpose only.
    var isPixelMode = true
   
    var spectrum1Data = [Double]()
    var spectrum2Data = [Double]()
    
    
    
    @IBOutlet weak var getIntensityButton: UIButton!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak private var dropDowButton: UIButton!
    let dropDown = DropDown()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = SocketController.sharedInstance
      //  loadXAxisValues()
        setUpDropDownMenu()
        
        let rightButton =  UIBarButtonItem(image: #imageLiteral(resourceName: "ic_configure_off"), landscapeImagePhone: #imageLiteral(resourceName: "ic_configure_off"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(tappedOnCongigureButton))
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataRecieved(_:)), name: responseNotification.name, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
      //  runTest2(degree: 3)   // Testing for Known P1,W1, p2,w2, p3,w3... values and get a,b,c,d values and R2
     //   pixelToWaveLength()   // Testing for Converting pixel to wavelength for know polynominal a,b,c,d values
        
    //    runTest(degree: 3)    // Testing for Ploynominal regression  working or not
        
        //        if !WifiController.sharedInstance.isConnected
        //        {
        //           moveToWifiConnectionPage()
        //        }
    }
    
    
    fileprivate func setUpDropDownMenu() {
        // Do any additional setup after loading the view, typically from a nib.
        
        dropDown.anchorView = dropDowButton // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDowButton.bounds.height)
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Pixel Mode","Wavelength Mode"]
        dropDowButton.setTitle("Pixel Mode", for: .normal)
        dropDowButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDowButton.setTitle(item, for: .normal)
            if index == 0
            {
                self.isPixelMode = true
                self.getIntensityButton.isSelected = false
            }
            else
            {
                self.isPixelMode = false
                self.getIntensityButton.isSelected = false
            }
        }
    }
    
    @objc func dataRecieved(_ notification: NSNotification)  {
        
        if  let messageDict = notification.userInfo as? Dictionary<String, Any>
        {
            if let request =  messageDict["request"] as? String
            {
                if request == INTESITY_VALUES_TAG
                {
               if let response = messageDict["response"] as? Data
               {
                  //  let socketData = SocketController.sharedInstance.readMessage()
                    let byteArray = [UInt8](response)
                    processIntensityValues(data: byteArray)
                }
                }
            }
        }
    
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        getIntensityButton.isSelected = false
    }
    func moveToWifiConnectionPage()  {
        let objWifiViewController  = self.storyboard?.instantiateViewController(withIdentifier: "WifiViewController")
        self.present(objWifiViewController!, animated: true, completion: nil)
        // Present wifi controller
    }
    
    
    
    func getIntensity()  {
        if SocketController.sharedInstance.getConnectionStatus()
        {
            DispatchQueue.global(qos: .background).async {
                
                SocketController.sharedInstance.clearCache()
                SocketController.sharedInstance.writeMessage(msg: INTESITY_VALUES_TAG)
            }
        }
    }
    
    @IBAction func getIntensityAction(_ sender: Any) {
        
        if getIntensityButton.isSelected
        {
            getIntensityButton.isSelected = false
        }
        else
        {
            getIntensityButton.isSelected = true
            //checkDeviceConnectionStatus()
            getIntensity()
        }
    }
    
    @objc func tappedOnCongigureButton()
    {
        
        let objConfigure = self.storyboard?.instantiateViewController(withIdentifier: "DeviceConfigurationViewController")
        self.navigationController?.pushViewController(objConfigure!, animated: true)
        
    }
    
    
    func setChart(xaxis:[Double], values: [Double]) {
        
        lineChartView.clear()
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: xaxis[i], y: values[i])
            dataEntries.append(dataEntry)
        }
        
        var chartlabel  = "Spectrum (W)"
        if isPixelMode
        {
            chartlabel = "Spectrum (P)"
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: chartlabel)
        lineChartDataSet.colors = [NSUIColor.blue]
        lineChartDataSet.drawCirclesEnabled = false
        let lineChartData = LineChartData()
        lineChartData.addDataSet(lineChartDataSet)
        
        //let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        //  lineChartView.leftAxis.axisMaximum = 10000
        //  lineChartView.leftAxis.axisMinimum = 0
        
        
        /* lineChartView.xAxis.valueFormatter  = IAxisValueFormatter()
         //  lineChartView.xAxis.valueFormatter = NumberFormatter() as! IAxisValueFormatter
         lineChartView.xAxis.valueFormatter.minimumFractionDigits = 0 */
        
        lineChartView.leftAxis.granularityEnabled = true
        lineChartView.leftAxis.granularity = 1.0
        
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 5000
        
        lineChartView.data = lineChartData
        
          lineChartView.chartDescription?.text = "Spectrum Charts"
        
        
        lineChartView.zoom(scaleX: 1, scaleY: 1, x: 0, y: 0)
        
        
    }
    
    func processIntensityValues(data:[UInt8]) -> Void {
        
        var responseData = data
        
        // Getting Starting Header of Command response.
        if String(bytes: responseData[0...5], encoding: .utf8) != nil
        {
            //  print(startingCommnd)
        }
        // Removing Starting Header part from Bytes Array
        responseData.removeSubrange(0...5)
        
        // Getting Ending Header of Command response.
        if let endingCommand  = String(bytes: responseData[responseData.count-5...responseData.count-1], encoding: .utf8)
        {
            print(endingCommand)
        }
        // Removing Ending Header part from Bytes Array
        responseData.removeSubrange(responseData.count-5...responseData.count-1)
        
        
        // Getting Intesity values between starting header and ending header.
        
        var startIndex  = 0
        let readingBytesCount = 2   // reading every 2 bytes
        
        // For Intesity values
        
        hexaDecimalArray.removeAll()
        intensityArray.removeAll()
        
        // Iterating response data for read 2 bytes each time.
        while (responseData.count-readingBytesCount) >= startIndex {
            //   print(responseData[startIndex...startIndex+1])  // For testing purpose
            let twoBytesData =  Data.init(bytes: responseData[startIndex...startIndex+1]) // Getting two bytes and creating data object using those bytes
            let twobytesHexaString = twoBytesData.hexEncodedString() // Converting Data  to heaxdecimalString
            hexaDecimalArray.append(twobytesHexaString)   // Adding to hexa decimal array . It's for testing purpose only.
            //  print(twobytesHexaString)  // For testing purpose
            let intensityValue  = twobytesHexaString.hexaToDouble  // Converting hexadecimal to decimal
            // print(intensityValue)   // For testing purpose
            intensityArray.append(intensityValue)   // Adding to intensity array
            startIndex  = startIndex+readingBytesCount  // Increasing starting index for read next two bytes.
        }
        
        prepareXAxisValues()
        takeSpectrum1Screenshot()
        
        //    print(hexaDecimalArray)  // Printing hexadecimal Array
        
        //  print(intensityArray)   // priting intensity array
        
        
      //  self.processPolynominal(resultArray: intensityArray)
        
        DispatchQueue.main.async {
            //  self.getIntensityButton.isSelected = false
            if self.isPixelMode
            {
                self.setChart( xaxis: self.pixelXAxis, values: self.intensityArray)
            }
            else
            {
                 self.setChart( xaxis: self.wavelengthXAxis, values: self.intensityArray)
            }
        }
        if self.getIntensityButton.isSelected
        {
            sleep(3)
            getIntensity()
        }
        
        
    }
    
    func runTest2(degree:Int)  {
        
        
        var pixelValues = [Double]()
        var wavelengthValues = [Double]()
        
        
        var actualData = [DataPoint]()
        var regressionData = [DataPoint]()
        var someData = [DataPoint]()
        
        
        let dataPont1 = DataPoint(x:468, y: 406)
        pixelValues.append(dataPont1.x)
        someData.append(dataPont1)
        actualData.append(dataPont1)
        
        let dataPont2 = DataPoint(x:596, y: 520)
        pixelValues.append(dataPont2.x)
        someData.append(dataPont2)
        actualData.append(dataPont2)
        
        
        let dataPont3 = DataPoint(x:746, y: 635)
        pixelValues.append(dataPont3.x)
        someData.append(dataPont3)
        actualData.append(dataPont3)
        
        
        let dataPont4 = DataPoint(x:785, y: 670)
        pixelValues.append(dataPont4.x)
        someData.append(dataPont4)
        actualData.append(dataPont4)
        
        let dataPont5 = DataPoint(x:1145, y: 985)
        pixelValues.append(dataPont5.x)
        someData.append(dataPont5)
        actualData.append(dataPont5)
        
        
        let poly =  PolynomialRegression(theData: someData, degrees: degree)
        poly.fillMatrix()
        let terms  = poly.getTerms()
        print(terms)
        
        
        
        for data in actualData
        {
            let objRegData  = DataPoint(x: data.x, y: poly.predictY(terms: terms, x: data.x)*100/100)
            wavelengthValues.append(objRegData.y)
            regressionData.append(objRegData)
        }
        
     //   print("ActualData", actualData)
      //  print("RegressionData", regressionData)
        
        
      //  loadXAxisValues()
        print("R2Value",linearRegression(y: pixelValues, x: wavelengthValues))
    }
    
    func runTest(degree:Int)  {
        
        //https://www.youtube.com/watch?v=vvv9DhUrzlY for Know what is Regression
        //https://arachnoid.com/sage/polynomial.html
        var actualData = [DataPoint]()
        var regressionData = [DataPoint]()
        var someData = [DataPoint]()
        
        for i in 0..<100
        {
            let x = i
            let randomY = getRandomInt(min: 5, max: 20)
            let dataPont = DataPoint(x: Double(x), y: Double(randomY))
            someData.append(dataPont)
            actualData.append(dataPont)
        }
        
        let poly =  PolynomialRegression(theData: someData, degrees: degree)
        poly.fillMatrix()
        let terms  = poly.getTerms()
        print(terms)
        
        for data in actualData
        {
            let objRegData  = DataPoint(x: data.x, y: poly.predictY(terms: terms, x: data.x)*100/100)
            regressionData.append(objRegData)
        }
        
        print("ActualData", actualData)
        print("RegressionData", regressionData)
        
    }
    
    func getRandomInt(min:UInt32,max:UInt32) -> UInt32 {
        
        return arc4random_uniform(UInt32(max))+min;
    }
    
    func pixelToWaveLength()  {
        
        self.wavelengthXAxis.removeAll()
        let resultArray = [-241.5291470689377, 1.9720887800896016, -0.001580973687293784, 6.9362527556691027e-07]
        
        let poly =  PolynomialRegression(theData: [], degrees: resultArray.count-1)
        poly.fillMatrix()
        
        for index in 0..<1280
        {
            self.wavelengthXAxis.append(round(poly.predictY(terms: resultArray, x: Double(index+1)))*100/100)
        }
     
    }
    
    func prepareXAxisValues()  {
       
        self.wavelengthXAxis.removeAll()
        self.pixelXAxis.removeAll()
        
        for index  in  1...1280
        {
            self.pixelXAxis.append(Double(index))
            let wavelengthFactor = Double(800)/Double(1280)*Double(index);
            self.wavelengthXAxis.append(300 + round(Double(wavelengthFactor*100))/100)
            
            
        }
    }
    
    @IBAction func graphModeSelection(_ sender: Any) {
        
        dropDown.show()
    }
    
    func processPolynominal(resultArray:[Double])  {
        
        var actualData = [DataPoint]()
        var regressionData = [DataPoint]()
        var someData = [DataPoint]()
        
        for i in 0..<resultArray.count
        {
            let x = i
            let y = resultArray[i]
            let dataPont = DataPoint(x: Double(x), y: y)
            someData.append(dataPont)
            actualData.append(dataPont)
        }
        
        let poly =  PolynomialRegression(theData: someData, degrees: 3)
        poly.fillMatrix()
        let terms  = poly.getTerms()
        print(terms)
        
        wavelengthXAxis.removeAll()
        //recalculate values for wavelength x axis
        for data in actualData
        {
            let objRegData  = DataPoint(x: data.x, y: poly.predictY(terms: terms, x: data.x)*100/100)
            regressionData.append(objRegData)
            wavelengthXAxis.append(poly.predictY(terms: terms, x: data.x)*100/100)
        }
        
        print("ActualData", actualData)
        print("RegressionData", regressionData)
        
    
        //get R2 value for the data we entered
//        var myCorrelation = (pixelXAxis, wavelengthXAxis);
//        console.log('R2 Value: ' + myCorrelation.r2);
        loadXAxisValues()
        print("R2Value",linearRegression(y: pixelXAxis, x: wavelengthXAxis))

        
    }
    
    func linearRegression(y:[Double],x:[Double]) ->  Double {
        
      //  var lr = [String:Double]()
        let n = Double(y.count)
        var sum_x:Double = 0
        var sum_y:Double = 0
        var sum_xy:Double = 0
        var sum_xx:Double = 0
        var sum_yy:Double = 0
        
        for i in  0..<y.count
        {
            sum_x += x[i];
            sum_y += y[i];
            sum_xy += (x[i]*y[i]);
            sum_xx += (x[i]*x[i]);
            sum_yy += (y[i]*y[i]);
        }
        
        let exp1:Double  = n*sum_xy - sum_x*sum_y
        let exp2:Double = sqrt((n*sum_xx-sum_x*sum_x)*(n*sum_yy-sum_y*sum_y))
        let exp3:Double = exp1/exp2
        return pow(exp3, 2)
        
        // return lr
        //lr['r2'] = Math.pow((n*sum_xy - sum_x*sum_y)/Math.sqrt((n*sum_xx-sum_x*sum_x)*(n*sum_yy-sum_y*sum_y)),2);
    }
    
    func loadXAxisValues(){
        //based on new logic, here are the data that needs to plotted
        //create new array of data points , in case of pixel build graph of x co-ordiantes
        
        pixelXAxis.removeAll()
        print("In x axis vals")
        
        for i in 0..<1280
        {
            pixelXAxis.append(Double(i))
            
           // logic for building wavelength x axis
            //300 to 1100
            let wavelengthFactor = 800/1280*i
            //add that factor to wavalength
            wavelengthXAxis.append(Double(300 + round(Double(wavelengthFactor * 100)) / 100))
        }
    
    
    }
    
    
}
extension HomeViewController
{
    
    func takeSpectrum1Screenshot(){
    self.spectrum1Data = self.intensityArray;
    //let minNumber = Math.min.apply(null, this.spectrum1Data);
    
    var mySum = 0.0;
    for minIndex in  0..<50
    {
        mySum += spectrum1Data[minIndex]
    }

    print("Sum1",mySum)
    
    let minNumber = round(mySum / 50)
    
    print("Orig spectrum 1 :",self.spectrum1Data)
    print("Min for spectrum 1 :",minNumber)
    
    
   spectrum1Data =  spectrum1Data.map { (element) -> Double in
        let finalVal = element - minNumber;
        if(finalVal < 0) {
            return 0;
        } else {
            return finalVal;
        }
    }
    
    print("Modified spectrum 1 : ",self.spectrum1Data)
    
    }
    
    func takeSpectrum2Screenshot(){
        self.spectrum2Data = self.intensityArray;
        //let minNumber = Math.min.apply(null, this.spectrum1Data);
        
        var mySum = 0.0;
        for minIndex in  0..<50
        {
            mySum += spectrum2Data[minIndex]
        }
        
        print("Sum1",mySum)
        
        let minNumber = round(mySum / 50)
        
        print("Orig spectrum 1 :",self.spectrum2Data)
        print("Min for spectrum 1 :",minNumber)
        
        
        spectrum2Data =  spectrum2Data.map { (element) -> Double in
            let finalVal = element - minNumber;
            if(finalVal < 0) {
                return 0;
            } else {
                return finalVal;
            }
        }
        
        print("Modified spectrum 1 : ",self.spectrum2Data)
        
    }
    
    
    func goToNewSpectrumPage()  {
        
        var spectrum3Data = [Double]()
        
        let wavelengthVal = dynParamsVal["wavelengthCalcVal"]
        
        
        var yAxisVal  = 0.0
        print("initial value",yAxisVal);
        //after calculation find the index in this section only
        for yy in 0..<self.spectrum1Data.count
        {
            //let currentVal = this.spectrum1Data[yy] / this.spectrum2Data[yy];
            let currentVal = self.spectrum2Data[yy] / self.spectrum1Data[yy]
            spectrum3Data.append(currentVal)
            let charVal = self.wavelengthXAxis[yy];
            //if wavelength matches then pick equivalent y axis value for calculation
            //console.log(wavelengthVal + ' ' + charVal);
            if(wavelengthVal == charVal){
                print("\(String(describing: wavelengthVal))+\(charVal)");
                print("wavelength matched");
                yAxisVal = currentVal;
            }
        }
        
        print("assigned value",yAxisVal);
        
        let r1 = dynParamsVal["r1"]
        let r2 = dynParamsVal["r2"]
        let r3 = dynParamsVal["r3"]
        let r4 = dynParamsVal["r4"]
        let r5 = dynParamsVal["r5"]
        let r6 = dynParamsVal["r6"]
        
        let c1 = dynParamsVal["c1"]
        let c2 = dynParamsVal["c2"]
        let c3 = dynParamsVal["c3"]
        let c4 = dynParamsVal["c4"]
        let c5 = dynParamsVal["c5"]
        let c6 = dynParamsVal["c6"]
        
        print("r Values: \(String(describing: r1)) \(String(describing: r2)) \(String(describing: r3)) \(String(describing: r4)) \(String(describing: r5)) \(String(describing: r6))")
        print("c Values: \(String(describing: c1)) \(String(describing: c2)) \(String(describing: c3)) \(String(describing: c4)) \(String(describing: c5)) \(String(describing: c6))")
       
        
        var finalR1:Double!
        var finalC1:Double!
        var finalR2:Double!
        var finalC2:Double!
        
        
        if yAxisVal >= r6! && yAxisVal <= r5!{
            finalR1 = r5;
            finalR2 = r6;
            finalC1 = c5;
            finalC2 = c6;
           print("in condition 1");
        }
        
        if yAxisVal > r5! && yAxisVal <= r4! {
            finalR1 = r4;
            finalR2 = r5;
            finalC1 = c4;
            finalC2 = c5;
            print("in condition 2");
        }
        
        if yAxisVal > r4! && yAxisVal <= r3!{
            finalR1 = r3;
            finalR2 = r4;
            finalC1 = c3;
            finalC2 = c4;
            print("in condition 3");
        }
        
        if yAxisVal > r3! && yAxisVal <= r2! {
            finalR1 = r2;
            finalR2 = r3;
            finalC1 = c2;
            finalC2 = c3;
            print("in condition 4");
        }
        
        if yAxisVal > r2! && yAxisVal <= r1!{
            finalR1 = r1;
            finalR2 = r2;
            finalC1 = c1;
            finalC2 = c2;
            print("in condition 5");
        }
        
        print("final values conditional ::  + \(finalC1) + ' ' + \(finalC2) + '  ' + \(finalR1) + ' ' + \(finalR2)")
        
        
        let finalA = (finalC1 - finalC2) / (finalR1 - finalR2);
        let finalB = (finalR1*finalC2 - finalR2*finalC1) / (finalR1 - finalR2);
        
        print("final a and b :: ' + \(finalA) + ' ' + \(finalB)");
        
        let  finalCValue = finalA*yAxisVal + finalB;
        
        print("final c value :: ' + \(finalCValue)");
        
        
    }
    
    
    
    
}
