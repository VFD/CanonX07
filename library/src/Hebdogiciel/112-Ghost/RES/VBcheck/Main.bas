Attribute VB_Name = "MainMod"
Option Explicit

Type datas
Addr As Long
H1 As Byte
H2 As Byte
H3 As Byte
H4 As Byte
H5 As Byte
H6 As Byte
H7 As Byte
H8 As Byte
Sum As Long
STAT As String * 1
End Type

Global LineBuffer() As datas
Sub Main()
Dim lix As Integer, lix2 As Integer, OLDADD As Long
Dim LixOut As Integer
Dim Strline As String
Dim Trig As Boolean, Cnt As Integer
Dim Old_Addr As Long
Dim ASM_OK As Boolean
ASM_OK = False

ReDim LineBuffer(0)
lix = FreeFile

Open "ASM.txt" For Input As lix
LixOut = FreeFile
Open "result.txt" For Output As LixOut
lix2 = FreeFile
Open "ZXtoken_codes.txt" For Output As lix2
While Not EOF(lix)
Line Input #lix, Strline
If InStr(Strline, ":") <> 0 Then

Parse Strline

If LineBuffer(UBound(LineBuffer)).STAT = "#" Then ASM_OK = True

If Old_Addr = 0 Then
Print #lix2,
Print #lix2, "## Machine code."
Print #lix2, "[ASM ORG(&h"; Right(Hex16(LineBuffer(UBound(LineBuffer)).Addr), 4); ") HEX:\"
End If

With LineBuffer(UBound(LineBuffer))
If .Addr <> OLDADD = 8 And OLDADD <> 0 Then Print #LixOut, "Erreur adresse."
OLDADD = .Addr

If (.Addr <> Old_Addr) And Old_Addr <> 0 Then
Print #LixOut,
Print #LixOut, "#########################"
Print #lix2, "]"; IIf(ASM_OK, "ERREUR CHECKSUM", "")
Print #lix2,
Print #lix2, "## Machine code."
Print #lix2, "[ASM ORG(&h"; Right(Hex16(.Addr), 4); ") HEX:\"
ASM_OK = False
End If

Print #LixOut, Right(Hex16(.Addr), 4); " : "; Hex8(CLng(.H1)); " "; Hex8(CLng(.H2)); " "; Hex8(CLng(.H3)); " "; Hex8(CLng(.H4)); " "; Hex8(CLng(.H5)); " "; Hex8(CLng(.H6)); " "; Hex8(CLng(.H7)); " "; Hex8(CLng(.H8)); " ($"; Hex16(CLng(.Sum)); ")"; .STAT;
Print #lix2, IIf(LineBuffer(UBound(LineBuffer)).STAT = "#", "####", ""); Hex8(CLng(.H1)); ","; Hex8(CLng(.H2)); ","; Hex8(CLng(.H3)); ","; Hex8(CLng(.H4)); ","; Hex8(CLng(.H5)); ","; Hex8(CLng(.H6)); ","; Hex8(CLng(.H7)); ","; Hex8(CLng(.H8)); ",\"

If LineBuffer(UBound(LineBuffer)).STAT = "#" Then Print #LixOut, "["; Hex16(( _
CLng(LineBuffer(UBound(LineBuffer)).H1) + _
CLng(LineBuffer(UBound(LineBuffer)).H2) + _
CLng(LineBuffer(UBound(LineBuffer)).H3) + _
CLng(LineBuffer(UBound(LineBuffer)).H4) + _
CLng(LineBuffer(UBound(LineBuffer)).H5) + _
CLng(LineBuffer(UBound(LineBuffer)).H6) + _
CLng(LineBuffer(UBound(LineBuffer)).H7) + _
CLng(LineBuffer(UBound(LineBuffer)).H8))); "]";
Old_Addr = .Addr + 8

Cnt = 0
'comptage 8x
If (.H1 And &HF0) = 128 Then Cnt = Cnt + 1
If (.H2 And &HF0) = 128 Then Cnt = Cnt + 1
If (.H3 And &HF0) = 128 Then Cnt = Cnt + 1
If (.H4 And &HF0) = 128 Then Cnt = Cnt + 1
If (.H5 And &HF0) = 128 Then Cnt = Cnt + 1
If (.H6 And &HF0) = 128 Then Cnt = Cnt + 1
If (.H7 And &HF0) = 128 Then Cnt = Cnt + 1
If (.H8 And &HF0) = 128 Then Cnt = Cnt + 1
If Cnt > 1 Then Print #LixOut, " {8x}";
Cnt = 0
'comptage x8
If (.H1 And &HF) = 8 Then Cnt = Cnt + 1
If (.H2 And &HF) = 8 Then Cnt = Cnt + 1
If (.H3 And &HF) = 8 Then Cnt = Cnt + 1
If (.H4 And &HF) = 8 Then Cnt = Cnt + 1
If (.H5 And &HF) = 8 Then Cnt = Cnt + 1
If (.H6 And &HF) = 8 Then Cnt = Cnt + 1
If (.H7 And &HF) = 8 Then Cnt = Cnt + 1
If (.H8 And &HF) = 8 Then Cnt = Cnt + 1
If Cnt > 1 Then Print #LixOut, " {x8}";
Cnt = 0
'comptage Bx
If (.H1 And &HF0) = 176 Then Cnt = Cnt + 1
If (.H2 And &HF0) = 176 Then Cnt = Cnt + 1
If (.H3 And &HF0) = 176 Then Cnt = Cnt + 1
If (.H4 And &HF0) = 176 Then Cnt = Cnt + 1
If (.H5 And &HF0) = 176 Then Cnt = Cnt + 1
If (.H6 And &HF0) = 176 Then Cnt = Cnt + 1
If (.H7 And &HF0) = 176 Then Cnt = Cnt + 1
If (.H8 And &HF0) = 176 Then Cnt = Cnt + 1
If Cnt > 1 Then Print #LixOut, " {Bx}";
Cnt = 0
'comptage xB
If (.H1 And &HF) = 11 Then Cnt = Cnt + 1
If (.H2 And &HF) = 11 Then Cnt = Cnt + 1
If (.H3 And &HF) = 11 Then Cnt = Cnt + 1
If (.H4 And &HF) = 11 Then Cnt = Cnt + 1
If (.H5 And &HF) = 11 Then Cnt = Cnt + 1
If (.H6 And &HF) = 11 Then Cnt = Cnt + 1
If (.H7 And &HF) = 11 Then Cnt = Cnt + 1
If (.H8 And &HF) = 11 Then Cnt = Cnt + 1
If Cnt > 1 Then Print #LixOut, " {xB}";
Print #LixOut,
End With

End If
Wend
Close #LixOut
Print #lix2, "]"; IIf(ASM_OK, "ERREUR CHECKSUM", "")
Close #lix2
Close #lix
Beep
End Sub

Sub Parse(MyLine As String)
Dim tmpbuff As String
Dim CHKchar As Byte, Cnt As Integer

tmpbuff = Right(MyLine, Len(MyLine) - InStr(MyLine, ":"))
ReDim Preserve LineBuffer(UBound(LineBuffer) + 1)
If Trim(tmpbuff) = "" Then GoTo exitscan
LineBuffer(UBound(LineBuffer)).STAT = ""
For Cnt = 1 To Len(MyLine): CHKchar = Asc(Mid(MyLine, Cnt, 1))
If (CHKchar < 48 And CHKchar <> 32) Or CHKchar > 70 Then LineBuffer(UBound(LineBuffer)).STAT = "?"
If CHKchar < 65 And CHKchar > 58 Then LineBuffer(UBound(LineBuffer)).STAT = "?"
Next Cnt

LineBuffer(UBound(LineBuffer)).Addr = Val("&h" & Left(MyLine, InStr(MyLine, ":") - 1))
If Trim(tmpbuff) = "" Then GoTo exitscan
While Left(tmpbuff, 1) = " "
tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))
Wend
If InStr(tmpbuff, " ") > 0 Then
LineBuffer(UBound(LineBuffer)).H1 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))
Else
LineBuffer(UBound(LineBuffer)).H1 = Val("&h" & tmpbuff)
GoTo exitscan
End If
If Trim(tmpbuff) = "" Then GoTo exitscan

tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))

If Trim(tmpbuff) = "" Then GoTo exitscan
If InStr(tmpbuff, " ") > 0 Then
LineBuffer(UBound(LineBuffer)).H2 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))
Else
LineBuffer(UBound(LineBuffer)).H2 = Val("&h" & tmpbuff)
GoTo exitscan
End If
tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))

If Trim(tmpbuff) = "" Then GoTo exitscan
If InStr(tmpbuff, " ") > 0 Then
LineBuffer(UBound(LineBuffer)).H3 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))
Else
LineBuffer(UBound(LineBuffer)).H3 = Val("&h" & tmpbuff)
GoTo exitscan
End If
tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))


If Trim(tmpbuff) = "" Then GoTo exitscan
If InStr(tmpbuff, " ") > 0 Then
LineBuffer(UBound(LineBuffer)).H4 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))
Else
LineBuffer(UBound(LineBuffer)).H4 = Val("&h" & tmpbuff)
GoTo exitscan
End If
tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))


If Trim(tmpbuff) = "" Then GoTo exitscan
If InStr(tmpbuff, " ") > 0 Then
LineBuffer(UBound(LineBuffer)).H5 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))
Else
LineBuffer(UBound(LineBuffer)).H5 = Val("&h" & tmpbuff)
GoTo exitscan
End If
tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))


If Trim(tmpbuff) = "" Then GoTo exitscan
If InStr(tmpbuff, " ") > 0 Then
LineBuffer(UBound(LineBuffer)).H6 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))
Else
LineBuffer(UBound(LineBuffer)).H6 = Val("&h" & tmpbuff)
GoTo exitscan
End If
tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))



If Trim(tmpbuff) = "" Then GoTo exitscan
If InStr(tmpbuff, " ") > 0 Then
LineBuffer(UBound(LineBuffer)).H7 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))
Else
LineBuffer(UBound(LineBuffer)).H7 = Val("&h" & tmpbuff)
GoTo exitscan
End If
tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))


If Trim(tmpbuff) = "" Then GoTo exitscan
LineBuffer(UBound(LineBuffer)).H8 = Val("&h" & Left(tmpbuff, InStr(tmpbuff, " ") - 1))

tmpbuff = Right(tmpbuff, Len(tmpbuff) - InStr(tmpbuff, " "))
LineBuffer(UBound(LineBuffer)).Sum = Val("&h" & tmpbuff)


exitscan:
If LineBuffer(UBound(LineBuffer)).Sum <> _
(( _
CLng(LineBuffer(UBound(LineBuffer)).H1) + _
CLng(LineBuffer(UBound(LineBuffer)).H2) + _
CLng(LineBuffer(UBound(LineBuffer)).H3) + _
CLng(LineBuffer(UBound(LineBuffer)).H4) + _
CLng(LineBuffer(UBound(LineBuffer)).H5) + _
CLng(LineBuffer(UBound(LineBuffer)).H6) + _
CLng(LineBuffer(UBound(LineBuffer)).H7) + _
CLng(LineBuffer(UBound(LineBuffer)).H8))) Then LineBuffer(UBound(LineBuffer)).STAT = "#"

End Sub
Function Hex16(Value As Long) As String
'If Value < 0 Then Value = -Value
'If Value >= &H10000 Then Hex16 = "FFFF": Exit Function

If Value < &H10 Then
   Hex16 = "000" & Hex(Value): Exit Function
ElseIf Value < &H100 Then
   Hex16 = "00" & Hex(Value): Exit Function
ElseIf Value < &H1000 Then
   Hex16 = "0" & Hex(Value): Exit Function
End If
Hex16 = Right(Hex8(Value \ &H100) & Hex8(Value - (Value \ &H100) * &H100), 4)
End Function

Function Hex8(Value As Long) As String
Value = Value And 255
If Value >= &H100 Then Hex8 = "FF": Exit Function
If Value < &H10 Then Hex8 = "0" & Hex(Value) Else Hex8 = Hex(Value)
End Function

Sub mirroir()

Dim MyVar, a
Dim LixOut As Integer

LixOut = FreeFile
Open "Miroir.txt" For Output As LixOut

MyVar = Array(0, 62, 99, 73, 93, 93, 93, 93): Rem  h-haut
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(93, 93, 93, 93, 73, 99, 62, 0): Rem  h-bas
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(93, 93, 92, 95, 95, 95, 92, 93): Rem h-G
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(93, 221, 29, 253, 253, 253, 29, 221): Rem h-D
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(0, 255, 0, 255, 255, 255, 0, 255): Rem h-m
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(0, 224, 24, 228, 242, 250, 61, 29): Rem O>'
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(0, 3, 12, 19, 47, 47, 94, 92): Rem  O<'
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(29, 61, 250, 242, 228, 24, 224, 0): Rem O>.
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(92, 94, 47, 47, 19, 12, 3, 0): Rem  O<.
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(93, 93, 93, 93, 93, 93, 93, 93): Rem I-m
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(29, 29, 29, 29, 29, 29, 29, 29): Rem Dm
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(92, 92, 92, 92, 92, 92, 92, 92): Rem Om
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(186, 186, 186, 186, 186, 186, 186, 186)
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(93, 92, 95, 95, 79, 32, 31, 0): Rem  D<.
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(0, 31, 32, 79, 95, 95, 92, 93): Rem  D<'
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(0, 240, 24, 200, 232, 200, 24, 240): Rem E-m
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(93, 92, 95, 95, 79, 96, 63, 0): Rem  L-G
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(252, 6, 242, 250, 242, 6, 252, 0): Rem L-D
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(0, 252, 6, 242, 250, 242, 6, 252): Rem E-'
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(0, 0, 126, 129, 189, 189, 157, 93): Rem G-m
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,

MyVar = Array(29, 58, 122, 244, 244, 250, 61, 29): Rem B>m
For a = 0 To 7: Print #LixOut, Sym(MyVar(a)); ",";: Next a
Print #LixOut,
Close #LixOut
End Sub

Function Sym(ValNum As Variant) As Byte
Sym = IIf(ValNum And 1, 128, 0) + IIf(ValNum And 2, 64, 0) + IIf(ValNum And 4, 32, 0) + IIf(ValNum And 8, 16, 0) + IIf(ValNum And 16, 8, 0) + IIf(ValNum And 32, 4, 0) + IIf(ValNum And 64, 2, 0) + IIf(ValNum And 128, 1, 0)
End Function
