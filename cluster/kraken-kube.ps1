<#
  title           :kraken-kube.ps1
  description     :get the remote kubectl config
  author          :Samsung SDSRA
#>

Param(
  [Parameter(Mandatory=$true)] 
  [string]$dmname = ""
)

# kraken root folder
$krakenRoot = "$(split-path -parent $MyInvocation.MyCommand.Definition)\.."
. "$krakenRoot\cluster\utils.ps1"

$success = Invoke-Expression "docker-machine ls -q | grep $dmname;$?"
If ($success) {
  inf "Machine $dmname already exists."
} Else {
  error "Docker Machine $dmname does not exist."
  exit 1
}

Invoke-Expression "docker-machine.exe env --shell=powershell $dmname | Invoke-Expression"

$is_running = Invoke-Expression "docker inspect -f '{{ .State.Running }}' kraken_cluster"
If ( $is_running -eq "true" ) {
  error "Cluster build already running:`n Run`n  'docker logs --follow kraken_cluster'`n to see logs."
  exit 1
}

New-Item -ItemType Directory -Force -Path "$krakenRoot\cluster\clusters\$dmname"
Invoke-Expression "docker cp kraken_data:/kraken_data/kube_config `"clusters/$dmname/kube_config`""

inf "To control your cluster use:'n  kubectl --kubeconfig=clusters/$dmname/kube_config --cluster=<cluster name> <kubectl commands>"