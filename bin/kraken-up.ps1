<#
  title           :kraken-up.ps1
  description     :use docker-machine to bring up a kraken cluster manager instance.
  author          :Samsung SDSRA
#>

Param(
  [string]$clustertype = "aws",
  [Parameter(Mandatory=$true)] 
  [string]$clustername = "", 
  [string]$dmopts = "",
  [Parameter(Mandatory=$true)] 
  [string]$dmname = ""
)

# kraken root folder
$krakenRoot = "$(split-path -parent $MyInvocation.MyCommand.Definition)\.."
. "$krakenRoot\bin\utils.ps1"

function setup_dockermachine {
  $dockermachineCommand = "docker-machine create $dmopts $dmname"
  inf "Starting docker-machine with:`n  '$dockermachineCommand'"

  Invoke-Expression $dockermachineCommand
}

If ($clustertype -eq "local") {
  error "local -clustertype is not supported"
  exit 1
}

If (!(Test-Path "$krakenRoot/terraform/$clustertype/$clustername/terraform.tfvars")) {
  error "$krakenRoot/terraform/$clustertype/$clustername/terraform.tfvars is not present."
  exit 1
}

# look for the docker machine specified 
Invoke-Expression "docker-machine ls -q | findstr -s '$dmname'"
If ($LASTEXITCODE -eq 0) {
  inf "Machine $dmname already exists."
} Else {
  If (!($dmopts)) {
    error "--dmopts not specified. Docker Machine option string is required unless machine $dmname already exists."
    exit 1
  }

  setup_dockermachine
}

Invoke-Expression "docker-machine.exe env --shell=powershell $dmname | Invoke-Expression"

# create the data volume container for state 
Invoke-Expression "docker inspect kraken_data" 
If ($LASTEXITCODE -eq 0) {
  inf "Data volume container kraken_data already exists."
} Else {
  inf "Creating data volume:`n  'docker create -v /kraken_data --name kraken_data busybox /bin/sh'"
  Invoke-Expression  "docker create -v /kraken_data --name kraken_data busybox /bin/sh"
}

# now build the docker container
$kraken_container_name = "kraken_cluster_$clustername"
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

inf "Building kraken container:`n  'docker build -t samsung_ag/kraken -f '$krakenRoot/bin/build/Dockerfile' '$krakenRoot' '"
Invoke-Expression "docker build -t samsung_ag/kraken -f '$krakenRoot/bin/build/Dockerfile' '$krakenRoot'"

# run cluster up
$command =  "docker run -d --name $kraken_container_name --volumes-from kraken_data samsung_ag/kraken bash -c " + 
            "`"/opt/kraken/terraform-up.sh --clustertype $clustertype --clustername $clustername`""

inf "Building kraken cluster:`n  '$command'"
Invoke-Expression $command

inf "Following docker logs now. Ctrl-C to cancel."
Invoke-Expression "docker logs --follow $kraken_container_name"
