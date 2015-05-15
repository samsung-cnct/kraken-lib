describe package('httpd'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end
