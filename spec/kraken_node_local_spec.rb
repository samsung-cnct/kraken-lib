require_relative 'spec_helper'

describe 'Node' do
  it "has etcd2 service running" do
    wait_for(service('etcd2')).to be_running
  end
end