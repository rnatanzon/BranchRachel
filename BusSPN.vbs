Option Explicit
' Comment!!!!
'------------------------------------------
' Function name: fBusAddVendor
' Description: The function is adding one vendor or more and saving 
' Parameters:
' Return value:
' Example:
'------------------------------------------
Public Function fBusAddVendor()

	'Reset IE to 100% zoom
	'resetZoomIE()
	
	call fGuiLogin()
	
	Call fGuiAddVendor()
	
End Function
'------------------------------------------
