<#
	title           :utils.ps1
	description     :utils
	author          :Samsung SDSRA
#>

function warn 
{
  param( [string]$Message )
  write-host "WARNING: $Message" -foregroundcolor "yellow"
}

function error 
{
  param( [string]$Message )
  write-host "ERROR: $Message" -foregroundcolor "red"
}

function inf 
{
  param( [string]$Message )
  write-host "$Message" -foregroundcolor "green"
}

function grep {
  $input | out-string -stream | select-string $args
}

function setup_dockermachine {
  $dockermachineCommand = "docker-machine create $dmopts $dmname"
  inf "Starting docker-machine with:`n  '$dockermachineCommand'"

  Invoke-Expression $dockermachineCommand
}

function follow 
{
  param( [string]$container )
  inf "Following docker logs now. Ctrl-C to cancel."
  Invoke-Expression "docker logs --follow $container"
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
    error "--dmopts not specified. Docker Machine option string is `
      required unless machine $dmname already exists."
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

$kraken_container_name = "kraken_cluster_$clustername"