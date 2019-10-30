[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 

#Functions for handling output
function Write-Database{
    Param($name,$phone,$time)
    [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
    [string]$sMySQLUserName = 'root'
    [string]$sMySQLPW = ''
    [string]$sMySQLDB = 'cookieclicker'
    [string]$sMySQLHost = 'localhost'
    [string]$sConnectionString = "server="+$sMySQLHost+";port=3306;uid=" + $sMySQLUserName + ";pwd=" + $sMySQLPW + ";database="+$sMySQLDB


    $oConnection = New-Object MySql.Data.MySqlClient.MySqlConnection($sConnectionString)
    $Error.Clear()
    try
    {
        $oConnection.Open()
    }
    catch
    {
        write-warning ("Could not open a connection to Database $sMySQLDB on Host $sMySQLHost. Error: "+$Error[0].ToString())
    }
    $res = New-Object psobject -Property @{"name"=$name;"phone"=$phone;"time"=$time}
    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    $oMYSQLCommand.CommandText='
    INSERT into `cookieclicker`.`results` (`name`,`phone`,`time`) VALUES("'+$res.name+'","'+$res.phone +'","'+$res.time+'")'
    $oMYSQLCommand.Connection = $oConnection
    $iRowsAffected=$oMYSQLCommand.ExecuteNonQuery()

    write-host "Wrote $iRowsAffected rows to database."
}

$main_form = New-Object system.Windows.Forms.Form
$main_form.Text ='Cookie Clicker'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true

$label_count = New-Object Windows.Forms.Label
$label_count.Text = "Antall klikk: " + $click_count
$label_count.AutoSize = $True
$label_count.Location=New-Object System.Drawing.Point(300,14)

$label_time = New-Object Windows.Forms.Label
$label_time.Text = "Tid: " + $time_remaining
$label_time.AutoSize = $True
$label_time.Location=New-Object System.Drawing.Point(300,34)

$label_name = New-Object Windows.Forms.Label
$label_name.Text = "Navn:"
$label_name.Location=New-Object System.Drawing.Point(300,54)
$label_name.AutoSize = $True

$textbox_name = New-Object Windows.Forms.TextBox
$textbox_name.Text = ""
$textbox_name.Location=New-Object System.Drawing.Point(340,52)

$label_phone = New-Object Windows.Forms.Label
$label_phone.Text = "Tlf:"
$label_phone.Location=New-Object System.Drawing.Point(300,72)
$label_phone.AutoSize = $True

$textbox_phone = New-Object Windows.Forms.TextBox
$textbox_phone.Text = ""
$textbox_phone.Location=New-Object System.Drawing.Point(340,72)

$button = new-object Windows.Forms.Button
$button.Size = New-Object System.Drawing.Size(300,266)
$button.Image = [System.Drawing.Bitmap]::Fromfile('C:\users\arjoa013\desktop\git\cookieclicker\cookie_transparent.jpg')

$click_count = 0
$game_started = $False
$stopwatch = 0
$max_clicks = 100

$button.Add_Click({
    if ($game_started -eq $False){
        $script:stopwatch =  [system.diagnostics.stopwatch]::StartNew()
        $script:game_started = $True
        
    }
    $script:click_count++
    #continue game
    $totalSecs =  [math]::Round($stopwatch.Elapsed.TotalSeconds,3)
    $label_count.Text = "Antall klikk: " + $click_count
    $label_time.Text = "Tid: " + $totalSecs + " sekunder"
    if ($script:click_count -ige $max_clicks){
        #end game
        
        $end_time = [math]::Round($stopwatch.Elapsed.TotalSeconds,3)
        $end_message = "Finished! Total time: " + $end_time + " seconds."
        $choice = [System.Windows.MessageBox]::Show($end_message,'Game input','YesNoCancel','Error')
        Write-Database $textbox_name.Text $textbox_phone.Text $end_time

        
    }else{
        
        
    }
    #Write-Database("Petter Jonassen", "99290414",$click_count)
    #Start-Job StartTimer
    
    #write-host($totalSecs)
    #$label_time.Text = $totalSecs
})

$main_form.controls.add($label_count)
$main_form.controls.add($label_time)

$main_form.controls.add($button)
$main_form.controls.add($label_name)
$main_form.controls.add($textbox_name)

$main_form.controls.add($label_phone)
$main_form.controls.add($textbox_phone)

$main_form.ShowDialog()

