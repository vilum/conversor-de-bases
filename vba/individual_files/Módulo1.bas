Attribute VB_Name = "Módulo1"
Private Const LARG_LABEL As Double = 15
Private Const LARG_COL   As Double = 45

Private tempList As Variant

Sub btnTela_Clique()
  Call PlanPrincipal.ConfigurarProtecaoDePlanilha(True)
  
  Dim modificacao As Double
  modificacao = 0
  
  Dim i As Integer
  
  With Worksheets("Tela Principal")
    If .Columns(2).ColumnWidth = LARG_LABEL Then modificacao = 24.5
    
    For i = 3 To 7
      .Columns(i).ColumnWidth = LARG_COL - modificacao
    Next i
    
    modificacao = modificacao * 0.25
    .Columns(2).ColumnWidth = LARG_LABEL - modificacao
    
    If modificacao <> 0 Then
      .Cells(2, 2).Value = "B"
      .Cells(3, 2).Value = "I"
      .Cells(4, 2).Value = "O"
      .ListObjects("tabelaOutput").DataBodyRange.Font.Size = 15
    Else
      .Cells(2, 2).Value = "Base"
      .Cells(3, 2).Value = "Input"
      .Cells(4, 2).Value = "Output"
      .ListObjects("tabelaOutput").DataBodyRange.Font.Size = 24
    End If
    
  End With
  
  Call PlanPrincipal.ConfigurarProtecaoDePlanilha(False)
End Sub

Sub btnX_Clique()
  Set tbl = Worksheets("Tela Principal").ListObjects("tabelaOutput")
    
  tempList = tbl.ListRows(1).Range.Value
  
  Call PlanPrincipal.ConfigurarProtecaoDePlanilha(True)
  tbl.ListRows(1).Delete
  Worksheets("Tela Principal").ListObjects("outputLabel").ListRows(2).Delete
  Call PlanPrincipal.ConfigurarProtecaoDePlanilha(False)
End Sub

Sub btUndo_Clique()
    Dim tbl As ListObject
    Set tbl = Worksheets("Tela Principal").ListObjects("tabelaOutput")
    
    If Not IsEmpty(tempList) Then
      Call PlanPrincipal.ConfigurarProtecaoDePlanilha(True)
      tbl.ListRows.Add (1)
      Worksheets("Tela Principal").ListObjects("outputLabel").ListRows.Add (2)
      
      Dim i As Integer
      For i = 1 To 5 Step 1
        tbl.DataBodyRange.Cells(1, i).Value = tempList(1, i)
      Next i
      
      tempList = Empty
      
      Call PlanPrincipal.ConfigurarProtecaoDePlanilha(False)
    End If
End Sub

