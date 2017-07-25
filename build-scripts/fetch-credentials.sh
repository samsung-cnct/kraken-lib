#  this script fetches all credentials to support the building of a k2 cluster
#  for now this includes:
#   - an ssh key pair
#   - aws credentials file
#  
#  Needed:
#   - gcloud service account file

#  we will use the IAM role of a kubelet to fetch this information from s3
set -x

#  ssh keys
mkdir ~/.ssh/
aws s3 cp --recursive s3://sundry-automata/keys/common-tools-jenkins/ ~/.ssh/
chmod 600 ~/.ssh/id_rsa

#  aws configs
mkdir ~/.aws/
aws s3 cp --recursive s3://sundry-automata/credentials/common-tools-jenkins/aws/ ~/.aws/

#  gcloud configs
mkdir -p ~/.config/gcloud/
aws s3 cp s3://sundry-automata/credentials/common-tools-jenkins/gke/patrickRobot.json ~/.config/gcloud/
