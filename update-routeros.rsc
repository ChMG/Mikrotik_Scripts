/system package update
check-for-updates once
:delay 5s;
:if ( [get status] = "New version is available") do={ install }
