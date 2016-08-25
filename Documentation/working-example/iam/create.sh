aws iam create-role --role-name KubernetesMaster --assume-role-policy-document file://master-role.json
aws iam put-role-policy --role-name KubernetesMaster --policy-name KubernetesMaster --policy-document file://master-policy.json
aws iam create-instance-profile --instance-profile-name KubernetesMaster
aws iam add-role-to-instance-profile --instance-profile-name KubernetesMaster --role-name KubernetesMaster

aws iam create-role --role-name KubernetesWorker --assume-role-policy-document file://worker-role.json
aws iam put-role-policy --role-name KubernetesWorker --policy-name KubernetesWorker --policy-document file://worker-policy.json
aws iam create-instance-profile --instance-profile-name KubernetesWorker
aws iam add-role-to-instance-profile --instance-profile-name KubernetesWorker --role-name KubernetesWorker
