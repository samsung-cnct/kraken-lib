<#
  title           :kraken-down.ps1
  description     :use docker-machine to dbring down a kraken cluster manager instance.
  author          :Samsung SDSRA
#>

Param(
  [string]$clustertype = "aws", 
  [Parameter(Mandatory=$true)] 
  [string]$dmname = "",
  [Parameter(Mandatory=$true)] 
  [string]$clustername = ""
)

# kraken root folder
$krakenRoot = "$(split-path -parent $MyInvocation.MyCommand.Definition)\.."
. "$krakenRoot\cluster\utils.ps1"

# look for the docker machine specified 
Invoke-Expression "docker-machine ls -q | out-string -stream | findstr -s '$dmname'"

If ($LASTEXITCODE -eq 0) {
  inf "Machine $dmname already exists."
} Else {
  error "Docker Machine $dmname does not exist."
  exit 1
}

Invoke-Expression "docker-machine.exe env --shell=powershell $dmname | Invoke-Expression"

# shut down cluster
Invoke-Expression "docker inspect kraken_cluster"
If ($LASTEXITCODE -eq 0) {
  inf "Removing old kraken_cluster container:`n   'docker rm -f kraken_cluster'"
  Invoke-Expression "docker rm -f kraken_cluster"
}

$success = Invoke-Expression "docker inspect kraken_data"
If ($LASTEXITCODE -ne 0) {
   warn "No terraform state available. Cluster is either not running, or kraken_data container has been removed."
   exit 0
}

$command = 	"docker run -d --name kraken_cluster --volumes-from kraken_data " +  
			"samsung_ag/kraken bash -c `"until terraform destroy -force -input=false -var-file=/opt/kraken/terraform/$clustertype/terraform.tfvars " +
			"-state=/kraken_data/$clustername/terraform.tfstate /opt/kraken/terraform/$clustertype; do echo 'Retrying...'; sleep 5; done`""

inf "Tearing down kraken cluster:`n  '$command'"
Invoke-Expression $command

inf "Following docker logs now. Ctrl-C to cancel."
Invoke-Expression "docker logs --follow kraken_cluster"