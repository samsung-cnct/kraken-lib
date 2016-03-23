<#
  title           :kraken-down.ps1
  description     :use docker-machine to dbring down a kraken cluster manager instance.
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

# shut down cluster
Invoke-Expression "docker inspect $kraken_container_name"
If ($LASTEXITCODE -eq 0) {
  inf "Removing old kraken_cluster container:`n   'docker rm -f $kraken_container_name'"
  Invoke-Expression "docker rm -f $kraken_container_name"
}

$success = Invoke-Expression "docker inspect kraken_data"
If ($LASTEXITCODE -ne 0) {
   warn "No terraform state available. Cluster is either not running, or `
    kraken_data container has been removed."
   exit 0
}

$command = 	"docker run -d --name $kraken_container_name --volumes-from kraken_data " +
			"samsung_ag/kraken:$clustername bash -c `"/opt/kraken/terraform-down.sh --clustertype $clustertype " +
      "--clustername $clustername`""

inf "Tearing down kraken cluster:`n  '$command'"
Invoke-Expression $command

follow $kraken_container_name