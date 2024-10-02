$apps =
ConvertTo-Json @(
    @{
        create_desktop_shortcut  = $true
        default_launch_container = "window"  
        url                      = "https://d-velop.personio.de/"
    }

#
#    @{
#        create_desktop_shortcut  = $true
#        default_launch_container = "window"  
#        url                      = "https://URL2/"
#    },
#    @{
#        create_desktop_shortcut  = $true
#        default_launch_container = "window"  
#        url                      = "https://URL3.com/"
#    }
) -Compress

$settings = 
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Edge"
    Value = $apps
    Name  = "WebAppInstallForceList"
} | group Path

foreach($setting in $settings){
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}
