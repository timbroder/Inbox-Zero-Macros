Function GetFolder(ByVal folderPath As String) As Outlook.Folder
    Dim TestFolder As Outlook.Folder
    Dim FoldersArray As Variant
    Dim i As Integer

    On Error GoTo GetFolder_Error
    If Left(folderPath, 2) = "\\" Then
        folderPath = Right(folderPath, Len(folderPath) - 2)
    End If
    'Convert folderpath to array
    FoldersArray = Split(folderPath, "\")
    Set TestFolder = Application.Session.Folders.Item(FoldersArray(0))
    If Not TestFolder Is Nothing Then
        For i = 1 To UBound(FoldersArray, 1)
            Dim SubFolders As Outlook.Folders
            Set SubFolders = TestFolder.Folders
            Set TestFolder = SubFolders.Item(FoldersArray(i))
            If TestFolder Is Nothing Then
                Set GetFolder = Nothing
            End If
        Next
    End If
    'Return the TestFolder
    Set GetFolder = TestFolder
    Exit Function

GetFolder_Error:
    Set GetFolder = Nothing
    Exit Function
End Function

Sub Archive()
    MarkReadAndMove ("\\tmb@alexanderinteractive.com\Inbox\_ARCH")
End Sub

Sub Doo()
    MarkReadAndMove ("\\tmb@alexanderinteractive.com\Inbox\_DO")
End Sub

Sub Hold()
    MarkReadAndMove ("\\tmb@alexanderinteractive.com\Inbox\_HOLD")
End Sub

Sub MarkReadAndMove(ByVal folderPath As String)
    Dim selectedItem As Object
    Dim archiveFolder As Outlook.Folder

    Set selectedItem = Application.ActiveExplorer.Selection.Item(1)
    Set archiveFolder = GetFolder(folderPath)

    selectedItem.UnRead = False
    selectedItem.Move archiveFolder
End Sub
