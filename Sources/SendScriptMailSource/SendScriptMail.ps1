
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null

[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\LoadingIndicators.WPF.dll')    | out-null


Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"


# Load xml
function LoadXml ($filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("mainform.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

$object = New-Object -comObject Shell.Application  


####################################
##### initialization
####################################

#HTML
$HtmlWebBrowser = $Form.Findname("HtmlWebBrowser")

#
$ChangeSettings  = $Form.Findname("ChangeSettings")
$FlyOutContent = $Form.Findname("FlyOutContent")

$ArcsStyle = $Form.Findname("ArcsStyle")

# Buttons and TextBox

$BtnSendMail = $Form.Findname("BtnSendMail")
$BtnLocation = $Form.Findname("BtnLocation")
$TxtBoxPath = $Form.Findname("TxtBoxPath")
$BtnInstallImportExcel = $Form.Findname("BtnInstallImportExcel")

# Label

$LabelImportExcel = $Form.Findname("LabelImportExcel")
$LabelPathFileInfo = $Form.Findname("LabelPathFileInfo")

#

$Tab = $Form.Findname("Tab")
$TabMailSender = $Form.Findname("TabMailSender")
$TabMailEditor = $Form.Findname("TabMailEditor")
$TabModule = $Form.Findname("TabModule")

# Default Mail Body

$text1 = "Veuillez trouver ci-joint votre TE"
$text2 = "corrigé et évalué 📝"
$text3 = "Je reste à votre dispotion pour toutes questions et/ou commentaires."
$text4 = "Avec mes cordiales salutations"




####################################
##### HTML 
####################################

$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<body>
<h2 contentEditable="true">$text1 <u>$ExamName</u> $text2<br /> <br /> $text3<br /> $text4</h2><style>h2 { color: #2F4F4F; font-family: 'Lato', sans-serif; font-size: 24px; font-weight: 30; line-height: 58px; margin: 0 0 58px; text-align: center; }</style>
</body>
</head>
</html>
"@

####################################
##### Buttons Actions
####################################

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

    if (Get-Module -ListAvailable -Name ImportExcel)
    {


        $ArcsStyle.IsActive = $true

        $Path = $FolderPath.SelectedPath

    if (Test-Path -Path "$Path\ListeEleve.xlsx") {

        # Var #
        $eleves = Import-Excel -Path "$Path\ListeEleve.xlsx"
        $ExamName = $TxtBoxPath.Text

        # Extraire le contenu modifiable du WebBrowser
        $contenuModifiable = $HtmlWebBrowser.Document.documentElement.getElementsByTagName('body') | ForEach-Object { $_.OuterHtml }
        $defaultemailbody = $contenuModifiable
        Write-Host "Contenu modifiable extrait :"
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
            $email.Subject = "Rendu du TE $ExamName"
            $email.HTMLBody = "$defaultemailbody"
            $email.Attachments.add("$Path\$CPEleve-$ExamName.pdf")
            $email.Send()
            $outlook.Quit()
            Write-Host "Email envoyé à $CPEleve" -ForegroundColor DarkGreen
        } else {
            Write-Host "Fichier PDF pour $CPEleve introuvable (Absent ?)" -ForegroundColor DarkRed
            [System.Windows.Forms.MessageBox]::Show("$CPEleve est absent",'Absence','Ok','Exclamation') # Message d'erreur
        }
    }
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Envoie terminé","L'envoie de mail est terminé.")
    $ArcsStyle.IsActive = $false
    } else {
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Introuvable","Fichier ListeEleve est introuvable.")
        $ArcsStyle.IsActive = $false
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
    $FolderPath.ShowDialog() # Affiche la page de dialogue pour la séléction du chemin
    if($FolderPath.SelectedPath -ne "") # Si le chemin = le chemin alors
    {
        $LabelPathFileInfo.Content = "Path File Difined"
        $LabelPathFileInfo.Foreground = "#FF138E09" # Couleur du text du label d'information de l'état du chemin en "vert"
    }   
})	


$ChangeSettings.Add_Click({
    $FlyOutContent.IsOpen = $true    
})

$HtmlWebBrowser.NavigateToString($htmlContent)

$Form.ShowDialog() | Out-Null