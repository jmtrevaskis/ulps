; disable ULPS for AMD GPUs
; by james trevaskis / pro @ teamau
; last edited: 12/12/12


$version="1.0"

func _func_ulps($state)

   ;AutoIT SetLOD
   $searchKey = "HKLM\SYSTEM"
   $searchString = "EnableUlps" ; find all values
   $results = _RegSearch($searchKey, $searchString, 2, 1)


   for $i = 1 to UBound($results)-1

	 ;split string
	 $bleh1 = StringSplit ( $results[$i], "\")
	 $bleh1Length = UBound($bleh1)-1
	 $bleh1Key = $bleh1[1]
	 $bleh1Finish = 0
	 
	 ;reconstruct string
	 for $p = 2 to $bleh1Length
		
		if ($p = $bleh1Length) Then
		   $bleh1Value = $bleh1[$p]
		   $bleh1Finish=1
		EndIf
		
		if ($bleh1Finish = 0) Then
		  $bleh1Key =  $bleh1Key & "\" & $bleh1[$p]
	   EndIf
	   
	 Next
	 
	 ;$blehReg = RegRead ( $bleh1Key, $bleh1Value )
	 regwrite($bleh1Key, $bleh1Value, "REG_DWORD", $state)
   

   Next

EndFunc


Func _RegSearch($sStartKey, $sSearchVal, $iType = 0x07, $fArray = False)
	Local $v, $sVal, $k, $sKey, $sFound = "", $sFoundSub = "", $avFound[1] = [0]

	; Trim trailing backslash, if present
	If StringRight($sStartKey, 1) = "\" Then $sStartKey = StringTrimRight($sStartKey, 1)

	; Generate type flags
	If Not BitAND($iType, 0x07) Then Return SetError(1, 0, 0); No returns selected
	Local $fKeys = BitAND($iType, 0x1), $fValue = BitAND($iType, 0x2), $fData = BitAND($iType, 0x4), $fRegExp = BitAND($iType, 0x8)

	; Check for wildcard
	If (Not $fRegExp) And ($sSearchVal == "*") Then
		; Use RegExp pattern "." to match anything
		$iType += 0x8
		$fRegExp = 0x8
		$sSearchVal = "."
	EndIf

	; This checks values and data in the current key
	If ($fValue Or $fData) Then
		$v = 1
		While 1
			$sVal = RegEnumVal($sStartKey, $v)
			If @error = 0 Then
				; Valid value - test its name
				If $fValue Then
					If $fRegExp Then
						If StringRegExp($sVal, $sSearchVal, 0) Then $sFound &= $sStartKey & "\" & $sVal & @LF
					Else
						If StringInStr($sVal, $sSearchVal) Then $sFound &= $sStartKey & "\" & $sVal & @LF
					EndIf
				EndIf

				; test its data
				If $fData Then
					$readval = RegRead($sStartKey, $sVal)
					If $fRegExp Then
						If StringRegExp($readval, $sSearchVal, 0) Then $sFound &= $sStartKey & "\" & $sVal & " = " & $readval & @LF
					Else
						If StringInStr($readval, $sSearchVal) Then $sFound &= $sStartKey & "\" & $sVal & " = " & $readval & @LF
					EndIf
				EndIf
				$v += 1
			Else
				; No more values here
				ExitLoop
			EndIf
		WEnd
	EndIf

	; This loop checks subkeys
	$k = 1
	While 1
		$sKey = RegEnumKey($sStartKey, $k)
		If @error = 0 Then
			; Valid key - test it's name
			If $fKeys Then
				If $fRegExp Then
					If StringRegExp($sKey, $sSearchVal, 0) Then $sFound &= $sStartKey & "\" & $sKey & "\" & @LF
				Else
					If StringInStr($sKey, $sSearchVal) Then $sFound &= $sStartKey & "\" & $sKey & "\" & @LF
				EndIf
			EndIf

			; Now search it
			$sFoundSub = _RegSearch($sStartKey & "\" & $sKey, $sSearchVal, $iType, False) ; use string mode to test sub keys
			If $sFoundSub <> "" Then $sFound &= $sFoundSub & @LF
		Else
			; No more keys here
			ExitLoop
		EndIf
		$k += 1
	WEnd

	; Return results
	If StringRight($sFound, 1) = @LF Then $sFound = StringTrimRight($sFound, 1)
	If $fArray Then
		If StringStripWS($sFound, 8) <> "" Then $avFound = StringSplit($sFound, @LF)
		Return $avFound
	Else
		Return $sFound
	EndIf
 EndFunc   ;==>_RegSearch
 
 
 
 
; user InputBox
$ulpsState = inputbox("ULPS state - pro@teamau", "Type 1 for enable or 0 for disable")

;change ULPS
_func_ulps($ulpsState);

;end
msgbox(0, "ULPS state set - pro@teamau", "ULPS state set complete...")


;eof