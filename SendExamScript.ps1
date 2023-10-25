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
$TextBoxExamName.Location = New-Object System.Drawing.Size(10,40)
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
#   Label Exam Name   #
##########################
#Création du label pour le nom de l'examen
$LabelExamName           = New-Object System.Windows.Forms.Label
#Location du label
$LabelExamName.Location  = New-Object System.Drawing.Size(6,20)
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
$LabelPathFile.Location = New-Object System.Drawing.Size(196,20)
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
$LabelPathFileInfo.Location        = New-Object System.Drawing.Size(195, 80)
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
#   Button Output Loc    #
##########################
#Création du button pour la location du chemin'
$PathBtn            = New-Object System.Windows.Forms.Button
#Location du button
$PathBtn.Location   = New-Object System.Drawing.Size(196,40)
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

            $emailBody = "<html><body><h2>Veuillez trouver ci-joint votre TE <u>$ExamName</u> corrigé et évalué 📝.<br /> <br /> Je reste à votre dispotion pour toutes questions et/ou commentaires.<br /> Avec mes cordiales salutations</h2><style>h2 { color: #2F4F4F; font-family: 'Lato', sans-serif; font-size: 24px; font-weight: 30; line-height: 58px; margin: 0 0 58px; text-align: center; }</style></body></html>"
        
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
#TextBox
$TextBoxExamName
#Label
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
ModuleMissing_Invisible
$main_form.ShowDialog()