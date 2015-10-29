<#
  title           :kraken-ansible.ps1
  description     :get the remote ansible inventory and ssh keys
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
Invoke-Expression "docker cp kraken_data:/kraken_data/ansible.inventory `"clusters/$dmname/ansible.inventory`""
Invoke-Expression "docker cp kraken_cluster:/root/.ssh/id_rsa `"clusters/$dmname/id_rsa`""
Invoke-Expression "docker cp kraken_cluster:/root/.ssh/id_rsa.pub `"clusters/$dmname/id_rsa.pub`""

inf "Parameters for ansible:`n   --inventory-file $krakenRoot\clusters\$dmname\ansible.inventory`n   --private-key $krakenRoot\clusters\$dmname\id_rsa"