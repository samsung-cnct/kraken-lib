<#
  title           :kraken-ssh.ps1
  description     :ssh to a remotely managed cluster node
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
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/ansible.inventory `"clusters/$dmname/$clustername/ansible.inventory`""
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/terraform.tfstate `"clusters/$dmname/$clustername/terraform.tfstate`""
Invoke-Expression "docker cp $kraken_container_name`:/opt/kraken/terraform/$clustertype/$clustername/terraform.tfvars `"clusters/$dmname/$clustername/terraform.tfvars`""
Invoke-Expression "docker cp kraken_data:/kraken_data/kube_config `"clusters/$dmname/$clustername/kube_config`""
Invoke-Expression "docker cp $kraken_container_name`:/root/.ssh/id_rsa `"clusters/$dmname/$clustername/id_rsa`""
Invoke-Expression "docker cp $kraken_container_name`:/root/.ssh/id_rsa.pub `"clusters/$dmname/$clustername/id_rsa.pub`""

inf "Parameters for ssh:`n  docker-machine.exe env --shell=powershell $dmname`n  docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F /kraken_data/$clustername/ssh_config <other ssh parameters> <node name>"
inf "Alternatively:"
inf "  Config file: /kraken_data/$clustername/ssh_config`n  SSH key: clusters/$dmname/$clustername/id_rsa"

inf "`n`nParameters for ansible:`n   --inventory-file clusters/$dmname/$clustername/ansible.inventory`n   --private-key clusters/$dmname/$clustername/id_rsa"

inf "`n`nParameters for terraform:`n   -state=clusters/$dmname/$clustername/terraform.tfstate`n   -var-file=clusters/$dmname/$clustername/terraform.tfvars`n   -var 'cluster_name=$clustername'"

inf "`n`nTo control your cluster use:`n  kubectl --kubeconfig=clusters/$dmname/$clustername/kube_config --cluster=$clustername <kubectl commands>"
