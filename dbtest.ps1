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



# I defined a PSCustom Object for a User
$res = New-Object psobject -Property @{"name"="tore";"email"="l@2k.com";"phone"="+491234 56789";"clicks"="207"}
$oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$oMYSQLCommand.CommandText='
INSERT into `cookieclicker`.`results` (`name`,`email`,`clicks`,`phone`) VALUES("'+$res.name+'","'+$res.email+'","'+$res.phone+'","'+$res.clicks+'")'
$oMYSQLCommand.Connection = $oConnection
$iRowsAffected=$oMYSQLCommand.ExecuteNonQuery()

write-host "Done"
write-host $iRowsAffected



