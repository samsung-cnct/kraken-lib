<#
  title           :kraken-ssh.ps1
  description     :ssh to a remotely managed cluster node
  author          :Samsung SDSRA
#>

Param(
  [Parameter(Mandatory=$true)] 
  [string]$dmname = "",
  [Parameter(Mandatory=$true)]
  [string]$clustername = "",
  [string]$node = ""
)

# kraken root folder
$krakenRoot = "$(split-path -parent $MyInvocation.MyCommand.Definition)\.."
. "$krakenRoot\bin\utils.ps1"

$success = Invoke-Expression "docker-machine ls -q | out-string -stream | findstr -s '$dmname'"
If ($LASTEXITCODE -eq 0) {
  inf "Machine $dmname already exists."
} Else {
  error "Docker Machine $dmname does not exist."
  exit 1
}
Invoke-Expression "docker-machine.exe env --shell=powershell $dmname | Invoke-Expression"

$kraken_container_name = "kraken_cluster_$clustername"
New-Item -ItemType Directory -Force -Path "$krakenRoot\bin\clusters\$dmname\$clustername"
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/ssh_config `"clusters/$dmname/$clustername/ssh_config`""
Invoke-Expression "docker cp $kraken_container_name:/root/.ssh/id_rsa `"clusters/$dmname/id_rsa`""
Invoke-Expression "docker cp $kraken_container_name:/root/.ssh/id_rsa.pub `"clusters/$dmname/id_rsa.pub`""
inf "Parameters for ssh:`n  docker-machine.exe env --shell=powershell $dmname`n  docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F /kraken_data/$clustername/ssh_config <other ssh parameters> <node name>"
inf "Alternatively:"
inf "  Config file: /kraken_data/$clustername/ssh_config`n  SSH key: clusters/$dmname/id_rsa"

if (!$node) {
  inf "Specify SSH target to connect directly. I.e. master, etcd, node-001, etc."
  exit 0
}

Invoke-Expression "docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F /kraken_data/$clustername/ssh_config $node"