$apps =
ConvertTo-Json @(
    @{
        create_desktop_shortcut  = $true
        default_launch_container = "window"  
        url                      = "https://d-velop.personio.de/"
    }

<<<<<<< HEAD

=======
>>>>>>> 667b6542abae497a715eb892490e137696d96709
#
#    @{
#        create_desktop_shortcut  = $true
#        default_launch_container = "window"  
#        url                      = "https://web.telegram.org/"
#    },
#    @{
#        create_desktop_shortcut  = $true
#        default_launch_container = "window"  
#        url                      = "https://open.spotify.com/"
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
<<<<<<< HEAD
}

#test
=======
}
>>>>>>> 667b6542abae497a715eb892490e137696d96709
