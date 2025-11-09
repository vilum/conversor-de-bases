VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PlanPrincipal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Private Sub Worksheet_Change(ByVal Target As Range)
    ' Se a região modificada for maior que uma célula, saia
    If Target.Count <> 1 Then Exit Sub
    ' Cheque se a célula modifica está na região "regiaoInput"
    Dim r As Range
    Dim col As Integer
    col = 1
    For Each r In Range("regiaoInput")
        If Target.Address = r.Address Then
          Call ConvertaEMostre(col)
          Exit Sub
        End If
        
        col = col + 1
    Next r
End Sub

Private Sub ConvertaEMostre(colInput As Integer)
    On Error GoTo Sair
    
    Call ConfigurarProtecaoDePlanilha(True)
    
    frmAviso.Hide
    
    Dim numeroInput As String, numeroResultado As String
    Dim col As Integer, baseDestino As Integer, baseOrigem As Integer
  
    numeroInput = UCase(Me.Range("regiaoInput").Cells(1, colInput))
    baseOrigem = CInt(Me.Range("labelsBases").Cells(1, colInput).Value)
    
    If Not InputEhValido(numeroInput, baseOrigem) Then
      frmAviso.Show
      
      Dim texto As String
      texto = frmAviso.Label1.Caption
      Mid(texto, Len(texto) - 1, 2) = CStr(baseOrigem)
      frmAviso.Label1.Caption = texto
      
      Me.Range("regiaoInput").Cells(1, colInput).Value = ""
      GoTo Sair
    End If
    
    
    Me.ListObjects("tabelaOutput").ListRows.Add (1)
    Me.ListObjects("outputLabel").ListRows.Add (2)
    For col = 1 To 5 Step 1
      baseDestino = CInt(Me.Range("labelsBases").Cells(1, col).Value)
      numeroResultado = Converta(numeroInput, baseOrigem, baseDestino)
      Me.ListObjects("tabelaOutput").DataBodyRange.Cells(1, col).Value = numeroResultado
    Next col
    Me.ListObjects("tabelaOutput").ListRows(1).Range.Locked = True
    
    Me.Range("regiaoInput").Cells(1, colInput).Value = ""

Sair:
  Call ConfigurarProtecaoDePlanilha(False)
End Sub
      
Private Function InputEhValido(numeroInput As String, baseOrigem As Integer) As Boolean
    Dim digitosPossiveis As Variant
    If baseOrigem = 32 Then
      digitosPossiveis = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("32").DataBodyRange.Value
    Else
      digitosPossiveis = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("2 a 16").DataBodyRange.Value
    End If
    
    Dim caractere As String
    Dim i As Integer, j As Integer
    Dim valido As Boolean
    
    For i = 1 To Len(numeroInput)
        caractere = Mid(numeroInput, i, 1)
        valido = False
        
        For j = 1 To baseOrigem
            If caractere = CStr(digitosPossiveis(j, 1)) Then
                valido = True
                Exit For
            End If
        Next j
        
        If Not valido Then
            InputEhValido = False
            Exit Function
        End If
    Next i
    
    InputEhValido = True
    
End Function
      

Public Sub ConfigurarProtecaoDePlanilha(podeEditar As Boolean)
    Application.EnableEvents = Not podeEditar
    
    If podeEditar Then
        Me.Unprotect
    Else
       Me.Protect
    End If
End Sub
      
Private Function Converta(valor As String, baseOrigem As Integer, baseDestino As Integer) As String
    Converta = DeDecimal(ParaDecimal(valor, baseOrigem), baseDestino)
End Function

Private Function ParaDecimal(numero As String, baseOrigem As Integer) As String
    Dim exponente As LongLong, i As Long
    exponente = 0
    Dim dec As LongLong
    dec = 0
    Dim digito As Integer
    
    For i = Len(numero) To 1 Step -1
        digito = DigitoParaDecimal(Mid(numero, i, 1), baseOrigem)
        dec = dec + digito * (baseOrigem ^ exponente)
        exponente = exponente + 1
    Next i
    
    ParaDecimal = CStr(dec)
End Function

Private Function DigitoParaDecimal(caractere As String, baseOrigem As Integer) As Integer
    Dim digitosPossiveis As Variant
    If baseOrigem = 32 Then
      digitosPossiveis = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("32").DataBodyRange.Value
    Else
      digitosPossiveis = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("2 a 16").DataBodyRange.Value
    End If
    
    Dim i As Integer
    
    For i = 0 To UBound(digitosPossiveis) Step 1
      If caractere = digitosPossiveis(i + 1, 1) Then
        DigitoParaDecimal = i
        Exit Function
      End If
    Next i

End Function

Private Function DeDecimal(numero As String, baseDestino As Integer) As String
    Dim digitos As Variant
    If baseDestino = 32 Then
      digitos = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("32").DataBodyRange.Value
    Else
      digitos = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("2 a 16").DataBodyRange.Value
    End If
    
    Dim resultado As String
    resultado = ""
    
    Dim dec As LongLong, resto As LongLong, quociente As LongLong
    dec = CLngLng(numero)
    
    quociente = dec
    Do
      Dim l As LongLong
      resto = quociente Mod baseDestino
      quociente = CInt(quociente \ baseDestino)
      
      resultado = digitos(resto + 1, 1) & resultado
    Loop While quociente > 0
    
    DeDecimal = resultado
    
End Function

