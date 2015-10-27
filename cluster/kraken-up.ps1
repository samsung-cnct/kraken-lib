<#
  title           :kraken-up.ps1
  description     :use docker-machine to bring up a kraken cluster manager instance.
  author          :Samsung SDSRA
#>

Param(
  [string]$clustertype = "aws", 
  [string]$dmopts = "",
  [Parameter(Mandatory=$true)] 
  [string]$dmname = ""
)

# kraken root folder
$krakenRoot = "$(split-path -parent $MyInvocation.MyCommand.Definition)\.."
. "$krakenRoot\cluster\utils.ps1"

function setup_dockermachine {
  $dockermachineCommand = "docker-machine create $dmopts $dmname"
  inf "Starting docker-machine with:`n  '$dockermachineCommand'"

  Invoke-Expression $dockermachineCommand
}

If (!(Test-Path "$krakenRoot/terraform/$clustertype/terraform.tfvars")) {
  error "$krakenRoot/terraform/$clustertype/terraform.tfvars is not present."
  exit 1
}

If (!(Test-Path "$krakenRoot/terraform/$clustertype/Dockerfile")) {
  error "$krakenRoot/terraform/$clustertype/Dockerfile is not present."
  exit 1
}


# look for the docker machine specified 
$success = Invoke-Expression "docker-machine ls -q | grep $dmname;$?"

If ($success) {
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
$success = Invoke-Expression "docker inspect kraken_data;$?"
If ($success) {
  inf "Data volume container kraken_data already exists."
} Else {
  inf "Creating data volume:`n  'docker create -v /kraken_data --name kraken_data busybox /bin/sh'"
  Invoke-Expression  "docker create -v /kraken_data --name kraken_data busybox /bin/sh"
}

# now build the docker container
$success = Invoke-Expression "docker inspect kraken_cluster;$?"
If ($success) {
  $is_running = Invoke-Expression "docker inspect -f '{{ .State.Running }}' kraken_cluster"
  If ( $is_running -eq "true" ) {
    error "Cluster build already running:`n Run`n  'docker logs --follow kraken_cluster'`n to see logs."
    exit 1
  }

  inf "Removing old kraken_cluster container:`n   'docker rm -f kraken_cluster'"
  Invoke-Expression "docker rm -f kraken_cluster"
}

inf "Building kraken container:`n  'docker build -t samsung_ag/kraken -f '$krakenRoot/terraform/$clustertype/Dockerfile' '$krakenRoot' '"
Invoke-Expression "docker build -t samsung_ag/kraken -f '$krakenRoot/terraform/$clustertype/Dockerfile' '$krakenRoot'"

# run cluster up
$command =  "docker run -d --name kraken_cluster --volumes-from kraken_data samsung_ag/kraken bash -c " + 
            "`"terraform apply -input=false -state=/kraken_data/terraform.tfstate " +
            "-var-file=/opt/kraken/terraform/$clustertype/terraform.tfvars /opt/kraken/terraform/$clustertype && " +
            "cp /opt/kraken/terraform/$clustertype/rendered/ansible.inventory /kraken_data/ansible.inventory && " +
            "cp /root/.ssh/config_$clustertype /kraken_data/ssh_config && " +
            "cp /root/.kube/config /kraken_data/kube_config`""

inf "Building kraken cluster:`n  '$command'"
Invoke-Expression $command

inf "Following docker logs now. Ctrl-C to cancel."
Invoke-Expression "docker logs --follow kraken_cluster"
