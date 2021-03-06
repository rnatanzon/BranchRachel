Option Explicit
' 123123000
Public iImagesCounter, sTest

iImagesCounter = 1

'------------------------------------------
' Function name: fGuiLogin
' Description: The function login to the system
' Parameters:
' Return value:
' Example:
'------------------------------------------
Public Function fGuiLogin()

Dim sUserName, sPassword

	'Get the expected login details (from the Environment excel or from the parameres excel)
	If GlobalDictionary("USER_NAME") <> "" Then 'Use the parameters excel login details
        UserName = GlobalDictionary("USER_NAME")
        sPassword = GlobalDictionary("PASSWORD")
	Else 'Use the Environment excel login details
        sUserName = Environment("USER")
        sPassword = Environment("PASSWORD")
	End If
                
    'Check if application is already open
    If Browser("SPN Manager").Exist(0) = "True" Then
        ' Check if we are allready in home page
        If Browser("SPN Manager").Page("SPN Manager").Exist(0) = "True" Then
            fGuiLogIn = "Success_and_do_not_Report"
                                                        
        ' Check if we are allready in login page
        ElseIf Browser("SPN Manager").Page("Log In").Exist(0) = "True" Then
            Browser("SPN Manager").Page("Log In").WebEdit("User Name").Set sUserName
			Browser("SPN Manager").Page("Log In").WebEdit("Password").Set  sPassword
            Browser("SPN Manager").Page("Log In").WebButton("Login").Click

            fGuiLogIn = "Success_and_Report"
    End If
    Else        'Lunch the browser and login
        'SystemUtil.Run "C:\Program Files\Mozilla Firefox\firefox.exe", Environment("URL") '--- FF - Use for XP
        SystemUtil.Run "C:\Program Files\Internet Explorer\iexplore.exe", Environment("URL") '-- IE - Use for windows 7
        'SystemUtil.Run "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", Environment("URL") '-- Chrome - Use for windows 7
       
        If Browser("SPN Manager").Page("Log In").Exist(30) = "False" Then
            Reporter.ReportEvent micFail, "fGuiLogIn", "'Login' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword
            Call fWriteHtmlReportRow("fGuiLogIn", "Login to application", "FAIL", "'Login' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword)
            fGuiLogIn = False
            ExitRun
        End If

        Browser("SPN Manager").Page("Log In").WebEdit("User Name").Set sUserName
        Browser("SPN Manager").Page("Log In").WebEdit("Password").Set  sPassword
        Browser("SPN Manager").Page("Log In").WebButton("Login").Click
        fGuiLogIn = "Success_and_Report"
    End If
                
    'If there is a popup
    If Browser("SPN Manager").Page("SPN Manager").WebElement("PopupX").Exist(30) Then
    	Browser("SPN Manager").Page("SPN Manager").WebElement("PopupX").Click
    End If
    
    If Browser("SPN Manager").Page("SPN Manager").Exist(30) = "False" Then
'        Reporter.ReportEvent micFail, "fGuiLogIn", "'SPN Manager' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword
'        Call fWriteHtmlReportRow("fGuiLogIn", "Login to application", "FAIL", "'Login' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword)
        Call fReport ("fGuiLogIn", "Login to application", "FAIL", "'Login' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword, 0)
        fGuiLogIn = False
        ExitRun
    End If
                
    If fGuiLogIn = "Success_and_Report" Then
'        Reporter.ReportEvent micPass, "fGuiLogIn", "Login succeeded." & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword
'        Call fWriteHtmlReportRow("fGuiLogIn", "Login to application", "PASS", "Login succeeded." & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword)
		Call fReport ("fGuiLogIn", "Login to application", "PASS", "Login succeeded." & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword, 0)   
    End If


End Function
'------------------------------------------

'------------------------------------------
' Function name: fGuiAddVendor
' Description: The function added a vendor and save
' Parameters:
' Return value:
' Example:
'------------------------------------------
Public Function fGuiAddVendor()

	

	'Parameters for the query results     
    Dim sSQL,rc,iVendorID,sVendorName,x,objRSVendorNames,iVendorNum
    'Dim vendorName(1)   
    
    'The query get the index of service provider
    sSQL = fGetQuery("Get_index_of_service_provider",array(GlobalDictionary("VENDOR_CODE")))
    'Indication for succees/failer query result
    rc = fDBGetOneValue ("SPN", sSQL, iVendorID)  ' or  rc = fDBGetRS ("BC", sSQL, objRS)
	'Messege for the test results
    If fCheckQueryResults("fGuiAddVendor","Get Row ID of a Service Provider", rc) <> True Then 
    	Call fReport("fGuiAddVendor", "Get index of service provider", "FAIL", "Didn't get the service provider", 0)   
        fGuiAddVendor = False
        Exit Function
    Else 
    	Call fReport("fGuiAddVendor", "Get index of service provider", "PASS", "Got the service provider", 0)
    End If
        
    ' Set the index property and click on it
	Call Browser("SPN Manager").Page("SPN Manager").WebElement("VIcon").SetTOProperty ("index",iVendorID)
	Browser("SPN Manager").Page("SPN Manager").WebElement("VIcon").Click	

	'The query of getting the available vendors
    sSQL = fGetQuery("Get_available_vendors",array(GlobalDictionary("VENDOR_CODE")))
    'Indication for succees/failer query result
    rc = fDBGetRS ("SPN", sSQL, objRSVendorNames)
	'Messege for the test results
    If fCheckQueryResults("fGuiAddVendor","Get the available vendors", rc) <> True Then
		'If there was no available vendor
		Call fReport("fGuiAddVendor", "Get the available vendors", "FAIL", "Didn't get the available vendors", 0)   
        fGuiAddVendor = False
        Exit Function
    Else 
    	Call fReport("fGuiAddVendor", "Get the available vendors", "PASS", "Got the available vendors", 0)   
    	' Set the innerHtml/innertext property and click on it
		iVendorNum = GlobalDictionary("NUM_VENDOR")
		objRSVendorNames.movefirst
		'TODO Add loop
		For i = 0 to iVendorNum-1
			sVendorName = objRSVendorNames.Fields(0).Value
			Call Browser("SPN Manager").Page("SPN Manager").WebElement("FirstAvailableVendor").SetTOProperty ("innertext",sVendorName)
			'x = Browser("SPN Manager").Page("SPN Manager").WebElement("FirstAvailableVendor").GetTOProperty("innertext")
			Browser("SPN Manager").Page("SPN Manager").WebElement("FirstAvailableVendor").Click 
			objRSVendorNames.MoveNext
		Next
		'iVendorNum.next

		'Add vendor button click       
		Browser("SPN Manager").Page("SPN Manager").WebButton("AddVendorButton").Click
	
		'Save button click
		Browser("SPN Manager").Page("SPN Manager").WebButton("Save").Click
	
		'Checks if the popup of saved changes is exists
    	If Browser("SPN Manager").Page("SPN Manager").WebElement("PopupX").Exist(30) Then
    		Browser("SPN Manager").Page("SPN Manager").WebElement("PopupX").Click
    
'			'DB verification
'			'The query of getting the saved assigned vendors
'    		sSQL = fGetQuery("Get_saved_assigned_vendors",DataTable("Vendor_Name", vendorName(0)))
'    		'Indication for succees/failer query result
'    		rc = fDBGetOneValue ("SPN", sSQL, DataTable("Vendor_Name", vendorName(0)))'to send a reference instead of the vendorName variable (how to do it???)
'			'Messege for the test results
'        		fGuiAddVendor = False
'        		Exit Function
'    		End If
'    		'iVendorId = GlobalDictionary("VENDOR_CODE")
'    		'If objRS.Fields(“VENDOR_ID”).Value = iVendorId Then
'    		Reporter.ReportEvent micPass,"SaveAssignedVendor","The assigned vendor was saved"
		End If
    End If
    
	fGuiAddVendor = True
End Function
'------------------------------------------

'###########################################################
' Function name: fReport
' Description: The function writes row to the HTML Report
' Parameters: sStepName, sStepDesc, sStatus, sStatusReason, iReportTo
'                                                               sStatus: "PASS" / "FAIL" / "INFO" / "" (- for header etc.)
'                                                               iReportTo: 0 = Both, 1 = Only QTP report, 2 = Only HTML report
' Return value: 
' Example:
'###########################################################
Public Function fReport(ByVal sStepName, ByVal sStepDesc, ByVal sStatus, ByVal sStatusReason, ByVal iReportTo)

                If iReportTo <> 2 Then
                                'Write to QTP resutls report
                                Select Case sStatus
                                                Case uCase("PASS")
                                                                Reporter.ReportEvent micPass, sStepName, sStatusReason
                                                Case uCase("FAIL")
                                                                Reporter.ReportEvent micFail, sStepName, sStatusReason
                                                Case uCase("INFO")
                                                                Reporter.ReportEvent micWarning, sStepName, sStatusReason
                                End Select
                End If

                If iReportTo <> 1 Then
                                'Write to HTML results Report
                                Call fWriteHtmlReportRow(sStepName, sStepDesc, sStatus, sStatusReason)
                End If

End Function
'###########################################################


' To reset the system for another test run after running 'fGuiAddVendor' the following:
''Cancel button click
'	Browser("SPN Manager").Page("SPN Manager").WebButton("Cancel").Click	
'	If Browser("SPN Manager").Page("SPN Manager").WebElement("PopupX").Exist(30) Then
'    	Browser("SPN Manager").Page("SPN Manager").WebElement("PopupX").Click
'    End If
