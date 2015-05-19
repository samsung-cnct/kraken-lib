require_relative 'spec_helper'

describe 'Master node' do
  
  it "has all the required files from cloud config" do
    expect(file('/opt/bin/download-deploy-kube-srv.sh')).to be_a_file
    expect(file('/opt/bin/wait4ectdproxy.sh')).to be_a_file
    expect(file('/opt/bin/wait4finalnode.sh')).to be_a_file
    expect(file('/opt/bin/wait4dns.sh')).to be_a_file
    expect(file('/opt/bin/flannelconfig.sh')).to be_a_file
    expect(file('/opt/bin/kube2sky.sh')).to be_a_file
    expect(file('/opt/bin/guestbook_example.sh')).to be_a_file
    expect(file('/opt/bin/influxdb_grafana.sh')).to be_a_file
    expect(file('/opt/bin/influxdb-grafana-pause.sh')).to be_a_file
    expect(file('/opt/bin/guestbook_example.sh')).to be_a_file
    expect(file('/opt/bin/guestbook_example.sh')).to be_a_file
  end

  it "has wait4etcd service running" do
    wait_for(service('wait4etcd')).to be_running
  end

  it "has etcd2 service running" do
    wait_for(service('etcd2')).to be_running
  end

  it "has wait4ectdproxy service running" do
    wait_for(service('wait4ectdproxy')).to be_running
  end

  it "has fleet service running" do
    wait_for(service('fleet')).to be_running
  end

  it "has flannelconfig service running" do
    wait_for(service('flannelconfig')).to be_running
  end

  it "has flanneld service running" do
    wait_for(service('flanneld')).to be_running
  end

  it "has docker service running" do
    wait_for(service('docker')).to be_running
  end

  it "has kube-apiserver service running" do
    wait_for(service('kube-apiserver')).to be_running
  end

  it "has kube-controller-manager service running" do
    wait_for(service('kube-controller-manager')).to be_running
  end

  it "has kube-scheduler service running" do
    wait_for(service('kube-scheduler')).to be_running
  end

  it "has kube-register service running" do
    wait_for(service('kube-register')).to be_running
  end

  it "has wait4finalnode service running" do
    wait_for(service('wait4finalnode')).to be_running
  end

  it "has download-deploy-kube-srv service running" do
    wait_for(service('download-deploy-kube-srv')).to be_running
  end

  it "has kube-skydns service running" do
    wait_for(service('kube-skydns')).to be_running
  end

  it "has guestbook-example service running" do
    wait_for(service('guestbook-example')).to be_running
  end

  it "has influxdb-grafana-pause service running" do
    wait_for(service('influxdb-grafana-pause')).to be_running
  end

  it "has influxdb-grafana service running" do
    wait_for(service('influxdb-grafana')).to be_running
  end  
end