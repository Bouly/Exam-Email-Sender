<#

.SYNOPSIS

Envoie automatique des TE des élèves pour les professeurs.

.DESCRIPTION

Envoie automatique des TE en Powershell et Windows Form.
Envoie le TE pour l'élève correspondant à la liste des élèves des professeurs.

.LINK

https://github.com/Bouly/Script-Send-Exam

#>

##############################################################################################################################
#                                               Chargement des classes et modules                                            #
##############################################################################################################################
# Chargement des classe l'interface GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-module ActiveDirectory

# .Net methods pour afficher/cacher la console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

##############################################################################################################################
#                                                              Variables                                                     #
##############################################################################################################################

# Config

            $text1 = "Veuillez trouver ci-joint votre TE <u>$ExamName</u> corrigé et évalué 📝."
            $text2 = "Je reste à votre dispotion pour toutes questions et/ou commentaires."
            $text3 = "Avec mes cordiales salutations"

$Debug = 0 # (0 = false | 1 = true) Pour l'affichage de la console

# 

$UserConnecter = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$EmailUser = Get-ADUser $UserConnecter -Properties EmailAddress | Select-Object -ExpandProperty EmailAddress


##############################################################################################################################
#                                                              Functions                                                     #
##############################################################################################################################

#Function d'affichage
function ModuleMissing_Visible { # Fonction qui rend visible les tools défini
    $LabelModuleCheck.Visible = $true
    $ButtonInstallModule.Visible = $true
    [System.Windows.Forms.MessageBox]::Show("Module ImportExcel est manquant, cliquer sur Install",'Information','Ok','warning') # Message informatif
}

function ModuleMissing_Invisible { # Fonction qui rend invisible les tools défini
    $LabelModuleCheck.Visible = $false
    $ButtonInstallModule.Visible = $false
}

function HideStartup { # Fonction qui rend invisible les tools défini
    $ReturnMainMenu.Visible = $false
}

function MainMenu_Visible {
    $TextBoxExamName.Visible = $true
    $LabelExamName.Visible = $true
    $LabelPathFile.Visible = $true
    $LabelPathFileInfo.Visible = $true
    $LabelModuleCheck.Visible = $false
    $PathBtn.Visible = $true
    $SendBtn.Visible = $true
    $ButtonInstallModule.Visible = $false
    $MailBtn.Visible = $true
    $OptionBtn.Visible = $true
    $ReturnMainMenu.Visible = $false
    $LabelTitle.Text = "Send Exam Script"
}

function OptionWindow_Visible { # Fonction qui rend invisible les tools défini
    $TextBoxExamName.Visible = $false
    $LabelExamName.Visible = $false
    $LabelPathFile.Visible = $false
    $LabelPathFileInfo.Visible = $false
    $LabelModuleCheck.Visible = $false
    $PathBtn.Visible = $false
    $SendBtn.Visible = $false
    $ButtonInstallModule.Visible = $false
    $MailBtn.Visible = $false
    $OptionBtn.Visible = $false
    $ReturnMainMenu.Visible = $true
    $LabelTitle.Text = "Option"


}

function MailWindow_Visible { # Fonction qui rend invisible les tools défini
    $TextBoxExamName.Visible = $false
    $LabelExamName.Visible = $false
    $LabelPathFile.Visible = $false
    $LabelPathFileInfo.Visible = $false
    $LabelModuleCheck.Visible = $false
    $PathBtn.Visible = $false
    $SendBtn.Visible = $false
    $ButtonInstallModule.Visible = $false
    $MailBtn.Visible = $false
    $OptionBtn.Visible = $false
    $ReturnMainMenu.Visible = $true
    $LabelTitle.Text = "Mail Editor"

    
}


function OptionWindow_Invisible { # Fonction qui rend invisible les tools défini

}


function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, $Debug)
}

##############################################################################################################################
#                                                          Window Settings                                                   #
##############################################################################################################################

# Création de la fenêtre pour contenir les éléments
$main_form                  = New-Object System.Windows.Forms.Form
# Le titre de la fenêtre
$main_form.Text             ='Send Exam Script'
# Largeur de la fenêtre
$main_form.Width            = 400
# Hauteur de la fenêtre
$main_form.Height           = 400
# Étire automatiquement la fenêtre
$main_form.AutoSize         = $true
# Centre la fênetre lors du lancement du script
$main_form.StartPosition= 'CenterScreen'
# Design de la fênetre
$main_form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
# Couleur du fond
$main_form.BackColor        = '38,36,49' 
# Icon du GUI
#$main_form.Icon             = [System.Drawing.Icon]::ExtractAssociatedIcon("$CurrentPath\logo.ico")
# Bloque la taille max et min
$main_form.minimumSize      = New-Object System.Drawing.Size(360,265) #360,265  585,365 
$main_form.maximumSize      = New-Object System.Drawing.Size(360,265)

# Cache la console lors de l'affichage de la fenetre
$main_form.Add_Shown({
    $main_form.Activate()
    Hide-Console
})

##############################################################################################
#                                              Toolbox                                       #
##############################################################################################

###############################################################
#                            TextBox                          #
###############################################################

##########################
#   TextBox Exam Name  #
##########################

#Création du champ de text pour le nom du fichier
$TextBoxExamName          = New-Object System.windows.Forms.TextBox
#Location du champ de text
$TextBoxExamName.Location = New-Object System.Drawing.Size(10,132)
#Taille du champ de text
$TextBoxExamName.Size     = New-Object System.Drawing.Size(137,20)
#L'entrée du champ de text
$TextBoxExamName.Text     = ""
# Design du champ de text
$TextBoxExamName.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

###############################################################
#                            Label                            #
###############################################################

##########################
#   Label Title   #
##########################
#Création du label pour le nom de l'examen
$LabelTitle           = New-Object System.Windows.Forms.Label
#Location du label
$LabelTitle.Location  = New-Object System.Drawing.Size(0,10)
#Taille du label
$LabelTitle.Size      = New-Object System.Drawing.Size(350,40)
#Text du Label
$LabelTitle.Text      = "Exam Sender Script"
#Police et taille du text du label
$LabelTitle.Font      = [System.Drawing.Font]::new("Berlin Sans FB Light", 16)
#Couleur du label
$LabelTitle.ForeColor = "White"
#Allignement du label
$LabelTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

##########################
#   Label Color BG Menu   #
##########################
#Création du label pour le nom de l'examen
$LabelColorMenu           = New-Object System.Windows.Forms.Label
#Location du label
$LabelColorMenu.Location  = New-Object System.Drawing.Size(0,50)
#Taille du label
$LabelColorMenu.Size      = New-Object System.Drawing.Size(360,40)
#Text du Label
$LabelColorMenu.Text      = ""
#Couleur du label
$LabelColorMenu.BackColor = "153, 152, 246"


##########################
#   Label Exam Name   #
##########################
#Création du label pour le nom de l'examen
$LabelExamName           = New-Object System.Windows.Forms.Label
#Location du label
$LabelExamName.Location  = New-Object System.Drawing.Size(6,112)
#Taille du label
$LabelExamName.Size      = New-Object System.Drawing.Size(150,20)
#Text du Label
$LabelExamName.Text      = "Exam Name"
#Police et taille du text du label
$LabelExamName.Font      = [System.Drawing.Font]::new("Verdana", 12)
#Couleur du label
$LabelExamName.ForeColor = "243, 244, 247"

##########################
#   Label Path File  #
##########################
#Création du label pour le chemin
$LabelPathFile          = New-Object System.Windows.Forms.Label
#Location du label
$LabelPathFile.Location = New-Object System.Drawing.Size(196,112)
#Taille du label
$LabelPathFile.Size     = New-Object System.Drawing.Size(150,20)
#Text du label
$LabelPathFile.Text     = "Path File"
#Police et taille du label
$LabelPathFile.Font      = [System.Drawing.Font]::new("Verdana", 12)
#Couleur du text
$LabelPathFile.ForeColor= "243, 244, 247"


##########################
#    Label Path File Info   #
##########################
#Création du label pour informé l'état du chemin
$LabelPathFileInfo                 = New-Object System.Windows.Forms.Label
#Location du label
$LabelPathFileInfo.Location        = New-Object System.Drawing.Size(195, 185)
#Taille du label
$LabelPathFileInfo.Size            = New-Object System.Drawing.Size(193,20)
#Text du label
$LabelPathFileInfo.Text            = "Path File Undifined"
#Couleur du text
$LabelPathFileInfo.ForeColor       = "178, 34, 34"
#Police et taille du label
$LabelPathFileInfo.Font            = "Bahnschrift, 10"

##########################
#   Label Module Check   #
##########################
#Création du label pour le nom du fichier
$LabelModuleCheck           = New-Object System.Windows.Forms.Label
#Location du label
$LabelModuleCheck.Location  = New-Object System.Drawing.Size(195,140)
#Taille du label
$LabelModuleCheck.Size      = New-Object System.Drawing.Size(195,32)
#Text du Label
$LabelModuleCheck.Text      = "Module ImportExcel non installé"
#Couleur du Label
$LabelModuleCheck.ForeColor = "178, 34, 34"
#Police et taille du label
$LabelModuleCheck.Font     = "Bahnschrift, 10"

###############################################################
#                            Button                           #
###############################################################


##########################
#    Button Retrun Main Menu    #
##########################
#Création du button pour la location du chemin'
$ReturnMainMenu            = New-Object System.Windows.Forms.Button
#Location du button
$ReturnMainMenu.Location   = New-Object System.Drawing.Size(15,60)
#Taille du button
$ReturnMainMenu.Size       = New-Object System.Drawing.Size(100,20)
#Text du button
$ReturnMainMenu.Text       = "Return"
#Police et taille
$ReturnMainMenu.Font      = "Bahnschrift, 10"
#Couleur
$ReturnMainMenu.BackColor = "38,36,49"
#Design
$ReturnMainMenu.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
#Couleur du text
$ReturnMainMenu.ForeColor = "243, 244, 247"
### Event click ###
$ReturnMainMenu.Add_Click({
    MainMenu_Visible
})

##########################
#    Button Menu Mail    #
##########################
#Création du button pour la location du chemin'
$MailBtn            = New-Object System.Windows.Forms.Button
#Location du button
$MailBtn.Location   = New-Object System.Drawing.Size(180,60)
#Taille du button
$MailBtn.Size       = New-Object System.Drawing.Size(137,20)
#Text du button
$MailBtn.Text       = "Mail Editor"
#Police et taille
$MailBtn.Font      = "Bahnschrift, 10"
#Couleur
$MailBtn.BackColor = "38,36,49"
#Design
$MailBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
#Couleur du text
$MailBtn.ForeColor = "243, 244, 247"
### Event click ###
$MailBtn.Add_Click({
    MailWindow_Visible
})

##########################
#    Button Menu Option    #
##########################
#Création du button pour la location du chemin'
$OptionBtn            = New-Object System.Windows.Forms.Button
#Location du button
$OptionBtn.Location   = New-Object System.Drawing.Size(25,60)
#Taille du button
$OptionBtn.Size       = New-Object System.Drawing.Size(137,20)
#Text du button
$OptionBtn.Text       = "Option"
#Police et taille
$OptionBtn.Font      = "Bahnschrift, 10"
#Couleur
$OptionBtn.BackColor = "38,36,49"
#Design
$OptionBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
#Couleur du text
$OptionBtn.ForeColor = "243, 244, 247"
### Event click ###
$OptionBtn.Add_Click({
    OptionWindow_Visible
})

##########################
# Button Install Module  #
##########################
#Création du button pour l'installation du module manquant
$ButtonInstallModule             = New-Object System.Windows.Forms.Button
#Location du button
$ButtonInstallModule.Location    = New-Object System.Drawing.Size(196,180)
#Taille du button
$ButtonInstallModule.Size        = New-Object System.Drawing.Size(75,23)
#Text du button
$ButtonInstallModule.Text        = "Install"
#Couleur du text
$ButtonInstallModule.BackColor   = "153, 152, 246"
#Couleur du text
$ButtonInstallModule.ForeColor   = "243, 244, 247"
#Taille et police du text
$ButtonInstallModule.Font        = "Bahnschrift, 10"
#Design Style
$ButtonInstallModule.FlatStyle   = [System.Windows.Forms.FlatStyle]::Flat
# Event click
$ButtonInstallModule.Add_Click({ #Quand le button cliqué
    Install-Module ImportExcel -AllowClobber -Force -Confirm:$false # Installation du module ImportExcel -AllowClobber(Persmission) -Force(Focer l'installation)
    [System.Windows.Forms.MessageBox]::Show("Le module ImportExcel a bien était Installé",'Module installé','Ok','Information') #Message informatif
    ModuleMissing_Invisible # Cacher la partie Installation du module
})

##########################
#   Button Path Loc    #
##########################
#Création du button pour la location du chemin'
$PathBtn            = New-Object System.Windows.Forms.Button
#Location du button
$PathBtn.Location   = New-Object System.Drawing.Size(196,132)
#Taille du button
$PathBtn.Size       = New-Object System.Drawing.Size(137,20)
#Text du button
$PathBtn.Text       = "Location"
#Police et taille
$PathBtn.Font      = "Bahnschrift, 10"
#Couleur
$PathBtn.BackColor = "153, 152, 246"
#Design
$PathBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
#Couleur du text
$PathBtn.ForeColor = "243, 244, 247"
#Création du dialogue pour la séléction du chemin
$FolderPath = New-Object System.Windows.Forms.FolderBrowserDialog
### Event click ###
$PathBtn.Add_Click({
    $FolderPath.ShowDialog() # Affiche la page de dialogue pour la séléction du chemin
    if($FolderPath.SelectedPath -eq $FolderPath.SelectedPath) # Si le chemin = le chemin alors
    {
        #$LabelPathFileInfo.Text = $FolderPath.SelectedPath # Le label d'information de l'état du chemin = Le chemin choisi
        $LabelPathFileInfo.Text = "Path File Difined"
        $LabelPathFileInfo.ForeColor = "153, 152, 246" # Couleur du text du label d'information de l'état du chemin en "vert"
    }   
})

##########################
#    Button Send   #
##########################
#Création du button pour l'envoie des mails
$SendBtn              = New-Object System.Windows.Forms.Button
#Location du button
$SendBtn.Location     = New-Object System.Drawing.Size(10,180)
#Taille du button
$SendBtn.Size         = New-Object System.Drawing.Size(75,23)
#Text du button
$SendBtn.Text         = "Send"
#Police et taille du text
$SendBtn.Font      = "Bahnschrift, 10"
#Couleur
$SendBtn.BackColor = "153, 152, 246"
#Design
$SendBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
#Couleur du text
$SendBtn.ForeColor = "243, 244, 247"
### Event click ###
$SendBtn.Add_Click({

# Module ImportExcel Check #
        if (Get-Module -ListAvailable -Name ImportExcel)  # On va chercher "ImporterExcel" dans liste tout les modules installé
        { 

# Var #
    $Path = $FolderPath.SelectedPath

    $eleves = Import-Excel -Path "$Path\ListeEleve.xlsx"

    $ExamName = $TextBoxExamName.Text

# Boucle #
        foreach ($eleve in $eleves){

            $CPEleve = $eleve._login
            $EmailEleve = $eleve._EnvoiMail

            $emailBody = "<html><body><h2>$text1<br /> <br /> $text2<br /> $text3</h2><style>h2 { color: #2F4F4F; font-family: 'Lato', sans-serif; font-size: 24px; font-weight: 30; line-height: 58px; margin: 0 0 58px; text-align: center; }</style></body></html>"
        
            #Verif PDF
            $cheminPdf = "C:\Users\cp-20ahb\Desktop\ScriptSendTE\$CPEleve-$ExamName.pdf"
            if (Test-Path $cheminPdf) {
                # Envoyer mail
                Send-MailMessage -From "$EmailUser" -To "$EmailEleve" -Subject "Rendu du TE $ExamName" -Body "$emailBody" -BodyAsHtml -DeliveryNotificationOption OnSuccess, OnFailure -Priority High -SmtpServer gw-ict-netlab.cpjb.ch -Attachments "C:\Users\cp-20ahb\Desktop\ScriptSendTE\$CPEleve-$ExamName.pdf" -Encoding ([System.Text.Encoding]::UTF8)
                Write-Host "Email envoyé à $CPEleve" -ForegroundColor DarkGreen
            } else {
                Write-Host "Fichier PDF pour $CPEleve introuvable (Absent ?)" -ForegroundColor DarkRed
                #[System.Windows.Forms.MessageBox]::Show("$CPEleve est absent",'Error','Ok','Error') # Message d'erreur
            }
        }
        } 
        else 
        { # Sinon
            ModuleMissing_Visible #  On affiche la partie de l'installation du module
        }
})



##############################################################################################
#                                              Control ToolBox                               #
##############################################################################################
# Déclare les variables du ToolBox pour les afficher

$main_form.controls.AddRange(@(
#Menu
$ReturnMainMenu
$MailBtn
$OptionBtn
$LabelColorMenu
#TextBox
$TextBoxExamName
#Label
$LabelTitle
$LabelPathFile
$LabelExamName
$LabelPathFileInfo
$LabelModuleCheck
#Button
$PathBtn
$SendBtn
$ButtonInstallModule

#Combobox
))
HideStartup
ModuleMissing_Invisible
$main_form.ShowDialog()