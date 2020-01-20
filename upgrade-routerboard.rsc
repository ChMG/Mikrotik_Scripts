:log info "Checking firmware...";
/system routerboard
:if ([get current-firmware] != [get upgrade-firmware]) do={
     :log info "Updating firmware ($[get current-firmware] --> $[get upgrade-firmware])";
     upgrade;
     #  Automatic restart
     :delay 5s;
     /system reboot
} else={
     :log info "No update. ($[get current-firmware] = $[get upgrade-firmware])";
}