<#
  title           :kraken-up.ps1
  description     :use docker-machine to bring up a kraken cluster manager instance.
  author          :Samsung SDSRA
#>

Param(
  [string]$dmopts = "",
  [Parameter(Mandatory=$true)]
  [string]$clustertype = "",
  [Parameter(Mandatory=$true)]
  [string]$clustername = "",
  [Parameter(Mandatory=$true)]
  [string]$dmname = ""
)

# kraken root folder
$krakenRoot = "$(split-path -parent $MyInvocation.MyCommand.Definition)\.."
. "$krakenRoot\bin\utils.ps1"

# now build the docker container
Invoke-Expression "docker inspect $kraken_container_name"
If ($LASTEXITCODE -eq 0) {
  $is_running = Invoke-Expression "docker inspect -f '{{ .State.Running }}' $kraken_container_name"
  If ( $is_running -eq "true" ) {
    error "Cluster build already running:`n Run`n  'docker logs --follow $kraken_container_name'`n to see logs."
    exit 1
  }

  inf "Removing old kraken_cluster container:`n   'docker rm -f $kraken_container_name'"
  Invoke-Expression "docker rm -f $kraken_container_name"
}

inf "Building kraken container:`n  'docker build -t samsung_ag/kraken:$clustername -f '$krakenRoot/bin/build/Dockerfile' '$krakenRoot' '"
Invoke-Expression "docker build -t samsung_ag/kraken:$clustername -f '$krakenRoot/bin/build/Dockerfile' '$krakenRoot'"

# run cluster up
$command =  "docker run -d --name $kraken_container_name -v /var/run:/ansible --volumes-from kraken_data samsung_ag/kraken:$clustername bash -c " +
            "`"/opt/kraken/terraform-up.sh --clustertype $clustertype --clustername $clustername`""

inf "Building kraken cluster:`n  '$command'"
Invoke-Expression $command

follow $kraken_container_name
