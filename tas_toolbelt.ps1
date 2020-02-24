<#####################################################
TAS Toolbelt GUI - Helps with Intune/M365 Testing
1. Drive Mapping
######################################################>

###pre-requisites

 #load windows forms
 Add-Type -assembly System.Windows.Forms

###end pre-requisites

#define variables
 $result = 'Retry'
 $outcome = 'NotSet'
 $server = 'FPS2-TAS-VMP.tas.secl.com.au'
 $portToCheck = '445'

#Create GUI form
 $main_form = New-Object System.Windows.Forms.Form
 $main_form.Text ='my TAS Toolbelt'
 $main_form.Width = 420
 $main_form.Height = 300
 $main_form.AutoSize = $true

 #Add close button
  $ButtonClose = New-Object System.Windows.Forms.Button
  $ButtonClose.Location = New-Object System.Drawing.Size(280,200)
  $ButtonClose.Size = New-Object System.Drawing.Size(120,46)
  $ButtonClose.Text = "Close"
  #Button Colour
  $ButtonClose.BackColor = '#2C3E50'
  #Button Text Colour
  $ButtonClose.ForeColor = '#FFFFFF'
    #Other button settings
    #$ButtonClose.Cursor = [System.Windows.Forms.Cursors]::Hand
    #$ButtonClose.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
  $main_form.Controls.Add($ButtonClose)
  $ButtonClose.Add_Click({$main_form.close()}  )

  #Add label
  $Label = New-Object System.Windows.Forms.Label
  $Label.Text = "Map H: and N: Drives"
  $Label.Location  = New-Object System.Drawing.Point(10,40)
  $Label.AutoSize = $true
  $main_form.Controls.Add($Label)

  #Add button to map drives
  $ButtonDrives = New-Object System.Windows.Forms.Button
  $ButtonDrives.Location = New-Object System.Drawing.Size(280,30)
  $ButtonDrives.Size = New-Object System.Drawing.Size(120,46)
  $ButtonDrives.Text = "Map Drives"
  $main_form.Controls.Add($ButtonDrives)
  $ButtonDrives.Add_Click(
  {
   #Create list of Map drive leters 
   $driveMappingConfig=@()
   $driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "H"
    UNCPath= "\\fps2-tas-vmp.tas.secl.com.au\Data\User\Production\$env:USERNAME"
    Description="HomeDrive"
   }

   $driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "N"
    UNCPath= "\\fps2-tas-vmp.tas.secl.com.au\DATA"
    Description="TasDATA"
   }

   while($result -eq 'Retry'){
    try {
        #Tests for a specific port (CIFS/NBT) being open to the file server 
        $null = New-Object System.Net.Sockets.TCPClient -ArgumentList $server,$portToCheck
        #If port is open it sets the $outcome variable accordingly
        $outcome = 'PortOpen'
    }
    catch {
        #If port is closed it sets the $outcome variable accordingly
        $outcome = 'PortClosed'
    }

    #If the port is open... map the drive!
    if ($outcome -eq 'PortOpen'){
        #Map drives (FPS2-TAS-VMP.tas.secl.com.au)
        $driveMappingConfig.GetEnumerator() | ForEach-Object {
        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global
        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLEtter):").Self.Name=$PSItem.Description
        }

        #Change result status so that it doesn't loop infinetly
        $result = "Success"

    } 
    else{ 
        # show a MsgBox if error connecting 
        $result = [System.Windows.Forms.MessageBox]::Show('File Server Not Found. Connect to VPN or Company Network and retry.', 'Warning', 'Retry', 'Warning') 
    }   
   #end while loop 
   }

  #end button click
  })
$main_form.ShowDialog()
