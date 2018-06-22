# encoding: utf-8

title 'Test Nginx installation'

describe package('nginx') do
  it { should be_installed }
end

describe file('/etc/nginx/nginx.conf') do
  it { should exist }
end

describe service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  its('processes') { should include 'nginx' }
  its('protocols') { should include 'tcp' }
  its('addresses') { should include '0.0.0.0' }
end
