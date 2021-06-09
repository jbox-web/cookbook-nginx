# encoding: utf-8

title 'Test Nginx installation'

# Fetch Inspec inputs
debian_release = input('debian_release')
nginx_version  = input('nginx_version')

# Test Nginx package
describe package('nginx') do
  it { should be_installed }
  its('version') { should eq nginx_version }
end

describe file('/etc/apt/sources.list.d/nginx-binary.list') do
  it { should exist }
  its('content') { should include %Q(deb      http://nginx.org/packages/mainline/debian #{debian_release} nginx)  }
end

# Test Nginx config
describe file('/etc/nginx/nginx.conf') do
  it { should exist }
end

describe command('nginx -t -c /etc/nginx/nginx.conf') do
  its('stderr') { should include "nginx: the configuration file /etc/nginx/nginx.conf syntax is ok" }
end

# Test Nginx service
describe service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  its('processes') { should include 'nginx:' }
  its('protocols') { should include 'tcp' }
  its('addresses') { should include '0.0.0.0' }
end
