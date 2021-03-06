'----------------------------------------------------------------
' Function name: fCheckQueryResults
' Description: The function check the query results
' Parameters: sStepName, sStepDesc, rc
' Return value: Success - True, Failure - False
'!!!123123
'----------------------------------------------------------------
Public Function fCheckQueryResults (ByVal sStepName, ByVal sStepDesc, ByVal rc)

	Dim sResult
    If rc = False Then					'DB connection failed /Ouery execution failed
		Call fReport(sStepName,sStepDesc,"FAIL","DB connection failed /Ouery execution failed",0)
		fCheckQueryResults = False
		Exit Function		
	ElseIf rc = NO_RECORDS_FOUND Then	'NO_RECORDS_FOUND
		Call fReport(sStepName,sStepDesc,"INFO","No records return by the query",1)
		fCheckQueryResults = False
		Exit Function
    End If

	fCheckQueryResults = True
End Function
'----------------------------------------------------------------
'----------------------------------------------------------------
' Function name: fGetQuery
' Description: The function reutrns sql query by query name. And replace all parameters in query [optional]
' Parameters: sQueryName - 	Name on QueriesDictionary, [optional]arrParamValue - array of parameters values. 
'							(If there are no query parameters, send an empty string - ""
' Return value: Success - SQL query
' Example: Call fGetQuery("Get_cust_rate_mod_temporary_sheet",Array("parma1","param2"))
'----------------------------------------------------------------
Public Function fGetQuery (ByVal sQueryName, ByVal arrParamValue)
	Dim sSQL

	sSQL = QueriesDictionary(sQueryName)
	If arrParamValue(0) <> "" Then
		For i = 1 to uBound(arrParamValue)+1
			If instr (1,sSQL, "<<parameter" & i & ">>") > 0 Then
				sSQL = Replace(sSQL,  "<<parameter" & i & ">>",arrParamValue(i-1))
			End If
		Next
	End If

	fGetQuery = sSQL
End Function
'----------------------------------------------------------------

'----------------------------------------------------------------
'---------------------  Queries dictionary  ---------------------
'----------------------------------------------------------------
'NOTE! Parameters format is <<parameter1>>, <<parameter2>>, etc...
'----------------------------------------------------------------
Set QueriesDictionary = CreateObject("Scripting.Dictionary")

QueriesDictionary("Get_available_vendors") = "" & _
"select VENDOR_NAME from (" & _
" SELECT VENDOR_NAME from(" & _
" SELECT " & _
" v.vendor_name," & _
" max (substr(TG.TRUNK_GROUP_NUMBER,4,4)) as COLO," & _
" v.vendor_id as RMS_ID" & _
" FROM MIS.VENDOR V" & _
" JOIN MIS.TERM_TRUNK_GROUP tg on V.VENDOR_ID = TG.VENDOR_ID" & _
" WHERE V.DELETE_FLAG is null" & _
" and TG.DELETE_FLAG is null" & _
" and TG.TRUNK_GROUP_NUMBER like '1%'" & _
" and v.vendor_id in (select vendor_id from MIS.VENDOR_NUMBER_PORTABILITY)" & _
" and v.vendor_id not in (SELECT V.VENDOR_ID " & _
" FROM MIS.SPN_VENDOR_MAP vm " & _
" JOIN MIS.VENDOR v on VM.VENDOR_ID = V.VENDOR_ID " & _
" WHERE vm.sys_spn = '<<parameter1>>' " & _
" AND (END_DATE is null or (END_DATE > to_date(to_char(SYSDATE,'Mon dd yyyy'),'Mon dd yyyy') and end_date > start_date)))" & _
" group by v.vendor_name ,  v.vendor_id , v.create_date , v.dst_end_date)" & _
" where 1=1 " & _
" ORDER BY lower(vendor_name) )" & _
" where ROWNUM < 6"

QueriesDictionary("Get_index_of_service_provider") = "" & _
"select rnum from (" & _
"select rownum as rnum, " & _
"SPN_Name " & _
",code " & _
"from ( " & _
"SELECT " & _
"spn.SYS_SPN_NAME as SPN_Name " & _
",spn.SYS_SPN code " & _
"from MIS.SPN spn " & _
"left join MIS.SPN_TIER ST on SPN.SYS_SPN = ST.SYS_SPN " & _
"join MIS.COUNTRY c on SPN.COUNTRY_ID = C.COUNTRY_ID " & _
"order by lower(SPN_NAME) " & _
")) " & _
"where code = '<<parameter1>>'"

QueriesDictionary("Get_saved_assigned_vendors") = "" & _
"SELECT * FROM(" & _
    " SELECT " & _
    " V.VENDOR_NAME" & _
    " ,to_char(VM.START_DATE,'Mon dd yyyy') as START_DATE" & _ 
    " FROM MIS.SPN_VENDOR_MAP vm" & _
   " JOIN MIS.VENDOR v on VM.VENDOR_ID = V.VENDOR_ID" & _
    " JOIN (" & _
       " SELECT v.vendor_id, max (substr(TG.TRUNK_GROUP_NUMBER,4,4)) as COLO" & _
       " FROM MIS.VENDOR v" & _
       " JOIN MIS.TERM_TRUNK_GROUP tg on V.VENDOR_ID = TG.VENDOR_ID" & _
       " WHERE V.DELETE_FLAG is null" & _
       " and TG.DELETE_FLAG is null" & _
       " and TG.TRUNK_GROUP_NUMBER like '1%'" & _
       " group by v.vendor_name, V.VENDOR_ID , v.create_date , v.dst_end_date " & _
    " ) COLO_TABLE ON COLO_TABLE.VENDOR_ID = V.VENDOR_ID" & _
    " WHERE" & _
    " END_DATE is null or (END_DATE > to_date(to_char(SYSDATE,'Mon dd yyyy'),'Mon dd yyyy') and end_date > start_date))" & _
" WHERE 1=1" & _
" and START_DATE = to_char(SYSDATE+1,'Mon dd yyyy')" & _
" and VENDOR_NAME like '<<parameter1>>'"



