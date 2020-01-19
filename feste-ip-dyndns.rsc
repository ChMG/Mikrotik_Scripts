# set host information
:local username "123456"
:local password "abcdefg"
:local hostname "hostname.feste-ip.net"
:local wildcard "no"

# set IPv6 configuration
:local updatev6 true
:local ipv6pool "DHCPv6-Pool"

# set IPv4 configuration
:local updatev4 true


# DO NOT CHANGE ANYTHING BELOW

# temp variables
:global dyndnsForceUpdate
:global previousIPv6
:global previousIPv4
:local urlpart1 ""
:local urlpart2 ""
:local update false

# print some debug info 
:log debug ("Update Feste-IP.net: username = $username")
:log debug ("Update Feste-IP.net: hostname = $hostname")
:log debug ("Update Feste-IP.net: previousIPv6 = $previousIPv6")
:log debug ("Update Feste-IP.net: previousIPv4 = $previousIPv4")

# process IPv6
:if (updatev6 = true) do={
    # get the current IPv6 address from check URL
    /tool fetch mode=http url=("http://v6.checkip.feste-ip.net/") dst-path="/festeip-dyndns-v6.fiptmp"
    :delay 1s
    :local resultv6 [/file get festeip-dyndns-v6.fiptmp contents]

    # parse the current IPv6 result
    :local startLocv6 [:find $resultv6 ": " -1]
    :set startLocv6 ($startLocv6 + 2)
    :local endLocv6 [:find $resultv6 "</body>" -1]
    :local currentIPv6 [:pick $resultv6 $startLocv6 $endLocv6]
    :log debug ("Update Feste-IP.net: currentIPv6 = $currentIPv6")

    # check if update is needed
    :if (($currentIPv6 != $previousIPv6) || ($dyndnsForceUpdate = true)) do={
        :set urlpart1 ("&myip=".$currentIPv6)
        :if ($ipv6pool != "") do={
            :local subnetv6 [/ipv6 pool used get [ find pool=$ipv6pool ] prefix]
            :set urlpart1 ($urlpart1."&subhostprefix=".$subnetv6)
        }
        :set previousIPv6 $currentIPv6
        :set update true
    }
}

# process IPv4
:if (updatev4 = true) do={
    # get the current IPv4 address from check URL
    /tool fetch mode=http url=("http://v4.checkip.feste-ip.net/") dst-path="/festeip-dyndns-v4.fiptmp"
    :delay 1s
    :local resultv4 [/file get festeip-dyndns-v4.fiptmp contents]

    # parse the current IPv4 result
    :local startLocv4 [:find $resultv4 ": " -1]
    :set startLocv4 ($startLocv4 + 2)
    :local endLocv4 [:find $resultv4 "</body>" -1]
    :local currentIPv4 [:pick $resultv4 $startLocv4 $endLocv4]
    :log debug ("Update Feste-IP.net: currentIPv4 = $currentIPv4")

    # check if update is needed
    :if (($currentIPv4 != $previousIPv4) || ($dyndnsForceUpdate = true)) do={
        if (update = true) do={
            :set urlpart2 ("&myip2=".$currentIPv4)
        } else {
            :set urlpart2 ("&myip=".$currentIPv4)
        }
        :set previousIPv4 $currentIPv4
        :set update true
    }
}

# do dyndns update if needed
:if ($update = true) do={
    :log info ("Update Feste-IP.net: Dyndns update needed")
    :set dyndnsForceUpdate false
    :local requesturl ("http://members.feste-ip.net/nic/update?system=dyndns&hostname=".$hostname.$urlpart1.$urlpart2)
    /tool fetch user=$username password=$password mode=http url=$requesturl dst-path="/festeip-dyndns-result.fiptmp"
    :delay 1s
    :local result [/file get festeip-dyndns-result.fiptmp contents]
    :log info ("Update Feste-IP.net: Dyndns Update Result: ".$result)
} else={
    :log debug ("Update Feste-IP.net: No dyndns update needed")
}

# cleanup
:delay 2s
/file remove [find type=".fiptmp file"]