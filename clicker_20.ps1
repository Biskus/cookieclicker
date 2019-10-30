[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 

$max_clicks = 100
$click_count = 0
$game_started = $False
$stopwatch = 0

#Functions for handling output
function Write-Database{
    Param($name,$phone,$time)
    
    [string]$sMySQLUserName = 'root'
    [string]$sMySQLPW = ''
    [string]$sMySQLDB = 'cookieclicker'
    [string]$sMySQLHost = 'localhost'
    [string]$sConnectionString = "server="+$sMySQLHost+";port=3306;uid=" + $sMySQLUserName + ";pwd=" + $sMySQLPW + ";database="+$sMySQLDB
    
        $oConnection = New-Object MySql.Data.MySqlClient.MySqlConnection($sConnectionString)
    $Error.Clear()
    
    try{
        $oConnection.Open()
    }
    catch{
        write-warning ("Failed opening $sMySQLDB on Host $sMySQLHost. Error: "+$Error[0].ToString())
    }

    #$res = New-Object psobject -Property @{"name"=$name;"phone"=$phone;"time"=$time}
    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    $oMYSQLCommand.CommandText='
    INSERT into `cookieclicker`.`results` (`name`,`phone`,`time`) VALUES("'+$name+'","'+$phone +'","'+$time+'")'
    $oMYSQLCommand.Connection = $oConnection
    $iRowsAffected=$oMYSQLCommand.ExecuteNonQuery()

    write-host "Wrote $iRowsAffected rows to database."
    write-host "Inserted " $name $phone $time "into database."
    write-host "Finished"
}

$main_form = New-Object system.Windows.Forms.Form
$main_form.Text ='Cookie Clicker'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true
$main_form.BackgroundImage = [system.drawing.image]::FromFile("C:\Users\arjoa013\Desktop\git\cookieclicker\img\cookie_background.jpg")
$main_form.BackgroundImageLayout = "Stretch"

#adding icon to form
$iconBase64 = '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'
$iconBytes = [Convert]::FromBase64String($iconBase64)
$stream = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length);
$iconImage = [System.Drawing.Image]::FromStream($stream, $true)
$main_form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())


$label_count = New-Object Windows.Forms.Label
$label_count.Text = "Antall klikk: " + $click_count
$label_count.AutoSize = $True
$label_count.Location=New-Object System.Drawing.Point(400,14)

$label_time = New-Object Windows.Forms.Label
$label_time.Text = "Tid: " + $time_remaining
$label_time.AutoSize = $True
$label_time.Location=New-Object System.Drawing.Point(400,34)

$label_name = New-Object Windows.Forms.Label
$label_name.Text = "Navn:"
$label_name.Location=New-Object System.Drawing.Point(400,54)
$label_name.AutoSize = $True

$textbox_name = New-Object Windows.Forms.TextBox
$textbox_name.Text = ""
$textbox_name.Location=New-Object System.Drawing.Point(440,52)

$label_phone = New-Object Windows.Forms.Label
$label_phone.Text = "Tlf:"
$label_phone.Location=New-Object System.Drawing.Point(400,72)
$label_phone.AutoSize = $True

$textbox_phone = New-Object Windows.Forms.TextBox
$textbox_phone.Text = ""
$textbox_phone.Location=New-Object System.Drawing.Point(440,72)

$button = new-object Windows.Forms.Button
$button.Location=New-Object System.Drawing.Point(90,72)
$button.Image = [System.Drawing.Bitmap]::Fromfile('C:\users\arjoa013\desktop\git\cookieclicker\img\cookie_button_smaller.png')
$button.Size = New-Object System.Drawing.Size(170,170)
#$button.FlatStyle = Windows.Forms.FlatStyle.Flat
#$button.BackColor = Color.Transparent

$button.Add_Click({
    if ($game_started -eq $False){
        $form_valid = $False

        #todo: check form input name phone
        #alert & force user to input before starting

        if ($form_valid){
            
        }

        $script:stopwatch =  [system.diagnostics.stopwatch]::StartNew()
        $script:game_started = $True
    }

    $script:click_count++

    $totalSecs =  [math]::Round($stopwatch.Elapsed.TotalSeconds,5)
    $label_count.Text = "Antall klikk: " + $click_count
    $label_time.Text = "Tid: " + $totalSecs + " sekunder"

    if ($script:click_count -ige $max_clicks){#end game
        $end_message = "Finished! Total time: " + $totalSecs + " seconds."
        $choice = [System.Windows.MessageBox]::Show($end_message,'Game over','Ok')
        Write-Database $textbox_name.Text $textbox_phone.Text $totalSecs
    }else{
        #play sound
    }
})

$main_form.controls.add($label_count)
$main_form.controls.add($label_time)
$main_form.controls.add($button)
$main_form.controls.add($label_name)
$main_form.controls.add($textbox_name)
$main_form.controls.add($label_phone)
$main_form.controls.add($textbox_phone)

$main_form.ShowDialog()

