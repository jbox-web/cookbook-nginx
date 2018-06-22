# encoding: utf-8

title 'Test Nginx installation'

# Test Nginx package
describe package('nginx') do
  it { should be_installed }
end

# Test Nginx config
describe file('/etc/nginx/nginx.conf') do
  it { should exist }
end

output = """
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
"""

describe command('nginx -t -c /etc/nginx/nginx.conf') do
  its('stderr') { should eq output.lstrip }
end

# Test Nginx service
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
