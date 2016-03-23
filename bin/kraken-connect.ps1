<#
  title           :kraken-ssh.ps1
  description     :ssh to a remotely managed cluster node
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

New-Item -ItemType Directory -Force -Path "$krakenRoot\bin\clusters\$clustername\group_vars"
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/ssh_config `
  `"$krakenRoot\bin\clusters\$clustername\`""
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/hosts `
  `"$krakenRoot\bin\clusters\$clustername\`""
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/group_vars/cluster `
  `"$krakenRoot\bin\clusters\$clustername\group_vars\`""
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/group_vars/all `
  `"$krakenRoot\bin\clusters\$clustername\group_vars\`""
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/terraform.tfstate `
  `"$krakenRoot\bin\clusters\$clustername\`""
Invoke-Expression "docker cp $kraken_container_name`:/opt/kraken/terraform/$clustertype/$clustername/terraform.tfvars `
  `"$krakenRoot\bin\clusters\$clustername\`""
Invoke-Expression "docker cp kraken_data:/kraken_data/$clustername/kube_config `
  `"$krakenRoot\bin\clusters\$clustername\`""
Invoke-Expression "docker cp $kraken_container_name`:/root/.ssh/id_rsa `
  `"$krakenRoot\bin\clusters\$clustername\`""
Invoke-Expression "docker cp $kraken_container_name`:/root/.ssh/id_rsa.pub `
  `"$krakenRoot\bin\clusters\$clustername\`""

inf "Parameters for ssh:`n  docker-machine.exe env --shell=powershell $dmname`n  `
  docker run -it --volumes-from kraken_data samsung_ag/kraken:$clustername ssh -F /kraken_data/$clustername/ssh_config `
  <other ssh parameters> <node name>"
inf "Alternatively:"
inf "  Config file: $krakenRoot\bin\clusters\$clustername\ssh_config`n  SSH key: `
  $krakenRoot\bin\clusters\$clustername\id_rsa"

inf "`n`nParameters for ansible:`n   ansible-playbook --inventory-file $krakenRoot\bin\clusters\$clustername\hosts`n   `
  --extra-vars 'ansible_ssh_private_key_file=$krakenRoot\bin\clusters\$clustername\id_rsa ansible_ssh_key_checking=False'"

inf "`n`nParameters for terraform:`n   -state=$krakenRoot\bin\clusters\$clustername\terraform.tfstate`n   `
  -var-file=$krakenRoot\bin\clusters\$clustername\terraform.tfvars`n   -var 'cluster_name=$clustername'"

inf "`n`nTo control your cluster use:`n  kubectl `
  --kubeconfig=$krakenRoot\bin\clusters\$clustername\kube_config --cluster=$clustername <kubectl commands>"
