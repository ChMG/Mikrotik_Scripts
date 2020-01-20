:local emailAddress "mail@test.de"

/system package update
set channel=current
check-for-updates once
:delay 1s;
:if ( [get status] = "New version is available") do={
:log info "A new software update is available. Sending email..."
/tool e-mail send to="$emailAddress" subject="[$[/system identity get name]] Software Update Available" body="A new update ($[/system package update get latest-version]) is available for your MikroTik device"
}
