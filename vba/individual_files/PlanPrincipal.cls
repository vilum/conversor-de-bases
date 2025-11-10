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

   ' Cheque se a célula modificada está na região "regiaoInput"
   Dim col As Integer
   Dim cel As Range

   For col = 1 To 5
      Set cel = Range("regiaoInput").Cells(1, col)
      If Not Intersect(Target, cel) Is Nothing Then
         Call ConvertaEMostre(col)
         Exit Sub
      End If
   Next col
End Sub

Private Sub ConvertaEMostre(colInput As Integer)
   On Error GoTo Sair

   Call ConfigurarProtecaoDePlanilha(True)

   ' Remova o aviso de erro, se estiver aberto
   frmAviso.Hide

   ' Colete dados
   Dim numeroInput As String, baseOrigem As Integer
   numeroInput = UCase(Me.Range("regiaoInput").Cells(1, colInput))
   baseOrigem = CInt(Me.Range("labelsBases").Cells(1, colInput).Value)

   If Not NumeroValidoNaBase(numeroInput, baseOrigem) Then
      Call EntradaInvalida(baseOrigem, colInput)
      GoTo Sair
   End If

   ' Crie nova linha na tabela de resultados
   Me.ListObjects("tabelaOutput").ListRows.Add (1)
   Me.ListObjects("tabelaOutput").ListRows(1).Range.Locked = True
   Me.ListObjects("outputLabel").ListRows.Add (2)

   ' Converta e preencha a tabela
   Dim col As Integer, baseDestino As Integer
   Dim numeroResultado As String

   For col = 1 To 5 Step 1
      baseDestino = CInt(Me.Range("labelsBases").Cells(1, col).Value)
      numeroResultado = Converta(numeroInput, baseOrigem, baseDestino)
      Me.ListObjects("tabelaOutput").DataBodyRange.Cells(1, col).Value = numeroResultado
   Next col

   ' Limpe a célula de entrada
   Me.Range("regiaoInput").Cells(1, colInput).Value = ""

Sair:
   ConfigurarProtecaoDePlanilha (False)
End Sub

Public Sub ConfigurarProtecaoDePlanilha(podeEditar As Boolean)
   Application.EnableEvents = Not podeEditar

   If podeEditar Then
      Me.Unprotect
   Else
      Me.Protect
   End If
End Sub

Private Function NumeroValidoNaBase(numeroInput As String, baseOrigem As Integer) As Boolean
   Dim digitosPossiveis As Variant
   digitosPossiveis = GetDigitosPossiveis(baseOrigem)

   ' Percorra os caracteres do número de entrada e verifique se é válido para a base
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
         NumeroValidoNaBase = False
         Exit Function
      End If
   Next i

   NumeroValidoNaBase = True
End Function

Private Sub EntradaInvalida(baseOrigem As Integer, colInput As Integer)
   frmAviso.Show

   Dim texto As String
   texto = frmAviso.Label1.Caption
   Mid(texto, Len(texto) - 1, 2) = CStr(baseOrigem)
   frmAviso.Label1.Caption = texto

   Me.Range("regiaoInput").Cells(1, colInput).Value = ""
End Sub

Private Function GetDigitosPossiveis(base As Integer) As Variant
   If base = 32 Then
      GetDigitosPossiveis = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("32").DataBodyRange.Value
   Else
      GetDigitosPossiveis = PlanDigitos.ListObjects("tabelaDigitos").ListColumns("2 a 16").DataBodyRange.Value
   End If
End Function

Private Function Converta(valor As String, baseOrigem As Integer, baseDestino As Integer) As String
   Dim resultado As String

   resultado = ParaDecimal(valor, baseOrigem)
   resultado = DeDecimal(resultado, baseDestino)

   Converta = resultado
End Function

Private Function ParaDecimal(numero As String, baseOrigem As Integer) As String
   Dim exponente As LongLong, dec As LongLong
   exponente = 0
   dec = 0

   Dim i As Long, digito As Integer

   For i = Len(numero) To 1 Step -1
      digito = ValorDoDigito(Mid(numero, i, 1), baseOrigem)
      dec = dec + digito * (baseOrigem ^ exponente)
      exponente = exponente + 1
   Next i

   ParaDecimal = CStr(dec)
End Function

Private Function ValorDoDigito(caractere As String, baseOrigem As Integer) As Integer
   ' Traduza caracter para dígito equivalente na base 10

   Dim digitosPossiveis As Variant
   digitosPossiveis = GetDigitosPossiveis(baseOrigem)

   Dim i As Integer

   For i = 0 To UBound(digitosPossiveis) Step 1
      If caractere = digitosPossiveis(i + 1, 1) Then
         ValorDoDigito = i
         Exit Function
      End If
   Next i
End Function

Private Function DeDecimal(numero As String, baseDestino As Integer) As String
   Dim digitosPossiveis As Variant
   digitosPossiveis = GetDigitosPossiveis(baseDestino)

   Dim resultado As String
   resultado = ""

   Dim dec As LongLong, resto As LongLong, quociente As LongLong
   dec = CLngLng(numero)

   quociente = dec
   Do
      Dim l As LongLong
      resto = quociente Mod baseDestino
      quociente = CInt(quociente \ baseDestino)

      resultado = digitosPossiveis(resto + 1, 1) & resultado
   Loop While quociente > 0

   DeDecimal = resultado
End Function

