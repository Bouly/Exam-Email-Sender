[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      | out-null
[System.Reflection.Assembly]::LoadFrom('MahApps.Metro.dll')       | out-null
[System.Reflection.Assembly]::LoadFrom('System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('LoadingIndicators.WPF.dll')    | out-null


Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"


# Load xml
function LoadXml ($filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

$StudentAbsent = $false
$AbsentList = @()

# Load MainWindow
$XamlMainWindow=LoadXml("mainform.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

$object = New-Object -comObject Shell.Application 

# Load AbsentWindow
$XamlAbsentWindow=LoadXml("absentform.xaml")
$ReaderAbsent=(New-Object System.Xml.XmlNodeReader $XamlAbsentWindow)
$AbsentForm=[Windows.Markup.XamlReader]::Load($ReaderAbsent)

$object = New-Object -comObject Shell.Application


####################################
##### initialization MainMenu
####################################

#HTML
$HtmlWebBrowser = $Form.Findname("HtmlWebBrowser")
$HtmlWebBrowserAbsent = $AbsentForm.FindName("HtmlWebBrowserAbsent")

$BtnBold = $Form.Findname("BtnBold")
$BtnItalic = $Form.Findname("BtnItalic")
$BtnUnderLine = $Form.Findname("BtnUnderLine")
$BtnOverLine = $Form.Findname("BtnOverLine")
$BtnUndo = $Form.Findname("BtnUndo")

$BtnImportant = $Form.Findname("BtnImportant")

$BtnBoldAbsent = $AbsentForm.Findname("BtnBoldAbsent")
$BtnItalicAbsent = $AbsentForm.Findname("BtnItalicAbsent")
$BtnUnderLineAbsent = $AbsentForm.Findname("BtnUnderLineAbsent")
$BtnOverLineAbsent = $AbsentForm.Findname("BtnOverLineAbsent")
$BtnUndoAbsent = $AbsentForm.Findname("BtnUndoAbsent")

$BtnImportantAbsent = $AbsentForm.Findname("BtnImportantAbsent")

#
$ChangeSettings  = $Form.Findname("ChangeSettings")
$FlyOutContent = $Form.Findname("FlyOutContent")

$ArcsStyle = $Form.Findname("ArcsStyle")

# Buttons and TextBox

$BtnSendMail = $Form.Findname("BtnSendMail")
$BtnLocation = $Form.Findname("BtnLocation")
$BtnInstallImportExcel = $Form.Findname("BtnInstallImportExcel")
$BtnSaveConfig = $Form.FindName("BtnSaveConfig")

$TxtBoxPath = $Form.Findname("TxtBoxPath")
$TxtBoxStudentsFileName = $Form.FindName("TxtBoxStudentsFileName")

# Label

$LabelImportExcel = $Form.Findname("LabelImportExcel")
$LabelPathFileInfo = $Form.Findname("LabelPathFileInfo")

#

$Tab = $Form.Findname("Tab")
$TabMailSender = $Form.Findname("TabMailSender")
$TabMailEditor = $Form.Findname("TabMailEditor")
$TabModule = $Form.Findname("TabModule")

$Badge = $Form.FindName("Badge")


####################################
##### initialization AbsentMenu
####################################

$DataGrid = $AbsentForm.FindName("AbsentStudentsDataGrid")

$BtnS = $AbsentForm.FindName("BtnS")

####################################
##### Config 
####################################

$CurrentPath = Get-Location

$Config = Get-Content "$CurrentPath\config.json" | ConvertFrom-Json

$TxtBoxStudentsFileName.Text = $Config.Config.StudentsFileName

####################################
##### HTML 
####################################

# Default Mail Body

$text1 = "Veuillez trouver ci-joint votre TE [Nom Du TE] corrigé et évalué 📝"
$text2 = "Je reste à votre dispotion pour toutes questions et/ou commentaires."
$text3 = "Avec mes cordiales salutations"

# Default Mail Body Absent

$text1Absent = "Bonjour, vous avez était absent pour le TE [Nom Du TE] 😴"
$text2Absent = "Ils ont était rendu, envoyé moi un mail pour une date de rattrapage"
$text3Absent = "Je reste à votre dispotion pour toutes questions et/ou commentaires."


$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<body>
<p contentEditable="true">$text1<br /> $text2<br /> $text3</p><style>p { color: #2F4F4F; font-family: 'Lato', sans-serif; font-size: 24px; font-weight: 30; line-height: 58px; margin: 0 0 58px; text-align: center; }</style>
</body>
</head>
</html>
"@

$htmlContentAbsent = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<body>
<p contentEditable="true">$text1Absent<br /> $text2Absent<br /> $text3Absent</p><style>p { color: #2F4F4F; font-family: 'Lato', sans-serif; font-size: 24px; font-weight: 30; line-height: 58px; margin: 0 0 58px; text-align: center; }</style>
</body>
</head>
</html>
"@



####################################
##### Buttons Actions
####################################

$BtnSaveConfig.Add_Click({
    $Config.Config.StudentsfileName = $TxtBoxStudentsFileName.Text

    $Config | ConvertTo-Json -depth 32 | set-content "$CurrentPath\config.json"

    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Enregistré","La configuration à bien été enregistré")
})

$BtnS.Add_Click({
    $ListAbsents = $DataGrid.SelectedItems

        if ($ListAbsents.Count -cgt 0) {
            $contenuModifiableAbsent = $HtmlWebBrowserAbsent.Document.documentElement.getElementsByTagName('body') | ForEach-Object { $_.OuterHtml }
            $defaultemailbodyAbsent = $contenuModifiableAbsent

                if ($BtnImportantAbsent.IsChecked -eq $true)
                {
                    $importantAbsent = 2
                }
                else
                {
                    $importantAbsent = 1
                }

            foreach($ListAbsent in $ListAbsents) {

                    $absentmail = $ListAbsent.Email
                    $tename = $ListAbsent.TE

                    $outlookAbsent = new-object -comobject outlook.application
                    $emailAbsent = $outlookAbsent.CreateItem(0)
                    $emailAbsent.To = "$absentmail"
                    $emailAbsent.importance = $importantAbsent
                    $emailAbsent.Subject = "Absent TE $tename"
                    $emailAbsent.HTMLBody = "$defaultemailbodyAbsent"
                    $emailAbsent.Send()
                    $outlookAbsent.Quit()
            }
            [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($AbsentForm,"Envoie terminé","L'envoie de mail aux absents est terminé.")
        }
        else {
            [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($AbsentForm,"Erreur","Aucun élève n'est sélectionné.")
        }
})

$BtnBold.Add_Click({
    $HtmlWebBrowser.Document.execCommand('bold', $false, $null)
})

$BtnItalic.Add_Click({
    $HtmlWebBrowser.Document.execCommand('italic', $false, $null)
})

$BtnUnderLine.Add_Click({
    $HtmlWebBrowser.Document.execCommand('underline', $false, $null)
})

$BtnOverLine.Add_Click({
    $HtmlWebBrowser.Document.execCommand('strikethrough', $false, $null)
})

$BtnUndo.Add_Click({
    $HtmlWebBrowser.Document.execCommand('undo', $false, $null)
})

##

$BtnBoldAbsent.Add_Click({
    $HtmlWebBrowserAbsent.Document.execCommand('bold', $false, $null)
})

$BtnItalicAbsent.Add_Click({
    $HtmlWebBrowserAbsent.Document.execCommand('italic', $false, $null)
})

$BtnUnderLineAbsent.Add_Click({
    $HtmlWebBrowserAbsent.Document.execCommand('underline', $false, $null)
})

$BtnOverLineAbsent.Add_Click({
    $HtmlWebBrowserAbsent.Document.execCommand('strikethrough', $false, $null)
})

$BtnUndoAbsent.Add_Click({
    $HtmlWebBrowserAbsent.Document.execCommand('undo', $false, $null)
})


$BtnInstallImportExcel.Add_Click({

    Install-Module ImportExcel -AllowClobber -Force -Confirm:$false # Installation du module ImportExcel -AllowClobber(Persmission) -Force(Focer l'installation)
    $BtnInstallImportExcel.IsEnabled = $false
    $LabelImportExcel.Foreground = "#FF22A03B"
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Installation terminé","L'installation du module Import Excel est terminé.")
    $Tab.SelectedIndex = "0"
    $TabMailSender.Visibility = "Visible"
    $TabMailEditor.Visibility = "Visible"
    $TabModule.Visibility = "Hidden"
})
	
$BtnSendMail.Add_Click({
    $Config = Get-Content "$CurrentPath\config.json" | ConvertFrom-Json
    $StudentsFileName = $Config.Config.StudentsFileName

    if (Get-Module -ListAvailable -Name ImportExcel)
    {


        $Path = $FolderPath.SelectedPath

        #Importance check

        if (Test-Path -Path "$Path\$StudentsFileName") {

            if ($BtnImportant.IsChecked -eq $true)
            {
                $important = 2
            }
            else
            {
                $important = 1
            }

        # Var #
        $eleves = Import-Excel -Path "$Path\$StudentsFileName"
        $ExamName = $TxtBoxPath.Text

        # Extraire le contenu modifiable du WebBrowser
        $contenuModifiable = $HtmlWebBrowser.Document.documentElement.getElementsByTagName('body') | ForEach-Object { $_.OuterHtml }
        $defaultemailbody = $contenuModifiable
        Write-Host "Contenu envoyé :"
        Write-Host $defaultemailbody

    #Boucle
    foreach ($eleve in $eleves){

        $CPEleve = $eleve._login
        $EmailEleve = $eleve._EnvoiMail
    
        #Verif PDF
        $cheminPdf = "$Path\$CPEleve-$ExamName.pdf"
        if (Test-Path $cheminPdf) {
            # Envoyer mail
            $outlook = new-object -comobject outlook.application
            $email = $outlook.CreateItem(0)
            $email.To = "$EmailEleve"
            $email.importance = $important
            $email.Subject = "Rendu du TE $ExamName"
            $email.HTMLBody = "$defaultemailbody"
            $email.Attachments.add("$Path\$CPEleve-$ExamName.pdf")
            $email.Send()
            $outlook.Quit()
            Write-Host "Email envoyé à $CPEleve" -ForegroundColor DarkGreen
        } else {
            Write-Host "Fichier PDF pour $CPEleve introuvable (Absent ?)" -ForegroundColor DarkRed
            $AbsentList += @(
                [pscustomobject]@{Login=$CPEleve;Email=$EmailEleve;TE=$ExamName}
            )
            $StudentAbsent = $true
        }
    }
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Envoie terminé","L'envoie de mail est terminé.")


    if ($StudentAbsent -eq $true) {
        $DataGrid.ItemsSource = $AbsentList
        $AbsentForm.ShowDialog() | Out-Null
    }

    } else {
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Introuvable","Fichier $StudentsFileName est introuvable.")
    }

    }
    else
    {
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Module manquant","Le module Import Excel est manquant.")
        $TabMailSender.Visibility = "Hidden"
        $TabMailEditor.Visibility = "Hidden"
        $TabModule.Visibility = "Visible"
        $Tab.SelectedIndex = "2"
    }
})


$FolderPath = New-Object System.Windows.Forms.FolderBrowserDialog
$BtnLocation.Add_Click({
    $FolderPath.ShowDialog()
    if($FolderPath.SelectedPath -ne "")
    {
        $LabelPathFileInfo.Content = "Path File Difined"
        $LabelPathFileInfo.Foreground = "#FF138E09"
    }
    $StudentsFileName = $Config.Config.StudentsFileName
    $Path = $FolderPath.SelectedPath
    if(Test-Path "$Path\$StudentsFileName"){
    $eleves = Import-Excel -Path "$Path\$StudentsFileName"
    $Badge.Badge = $eleves.Count
    } else{
        $Badge.Badge = 0
    }

})	


$ChangeSettings.Add_Click({
    $FlyOutContent.IsOpen = $true    
})

$HtmlWebBrowser.NavigateToString($htmlContent)
$HtmlWebBrowserAbsent.NavigateToString($htmlContentAbsent)

$Form.ShowDialog() | Out-Null



