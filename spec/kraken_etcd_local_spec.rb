require_relative 'spec_helper'

describe "ETCD node" do
  
  it "has early-docker service running" do
    wait_for(service('early-docker')).to be_running
  end
  it "has the configured docker socket" do
    wait_for(file('/var/run/early-docker.sock')).to be_a_socket 
  end
  it "has etcd2 service running" do
    wait_for(service('etcd2')).to be_running
  end
  it "has wait4etcdproxy service running" do
    wait_for(service('wait4etcdproxy')).to be_running
  end
end