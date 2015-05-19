require_relative 'spec_helper'

describe 'Node' do
  it "has all the required files from cloud config" do
    expect(file('/opt/bin/wait4etcd.sh')).to be_a_file
    expect(file('/opt/bin/wait4ectdproxy.sh')).to be_a_file
    expect(file('/opt/bin/wait4apiserver.sh')).to be_a_file
  end

  it "has etcd2 service running" do
    wait_for(service('etcd2')).to be_running
  end

  it "has wait4etcd service running" do
    wait_for(service('wait4etcd')).to be_running
  end

  it "has flanneld service running" do
    wait_for(service('flanneld')).to be_running
  end

  it "has docker service running" do
    wait_for(service('docker')).to be_running
  end

  it "has wait4ectdproxy service running" do
    wait_for(service('wait4ectdproxy')).to be_running
  end

  it "has fleet service running" do
    wait_for(service('fleet')).to be_running
  end

  it "has wait4apiserver service running" do
    wait_for(service('wait4apiserver')).to be_running
  end

  it "has kube-proxy service running" do
    wait_for(service('kube-proxy')).to be_running
  end

  it "has kube-kubelet service running" do
    wait_for(service('kube-kubelet')).to be_running
  end
end