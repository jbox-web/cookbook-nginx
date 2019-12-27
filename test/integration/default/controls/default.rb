# encoding: utf-8

title 'Test Nginx installation'

DISTROS = {
  '9'  => 'stretch',
  '10' => 'buster',
}

# Test Nginx package
describe package('nginx') do
  it { should be_installed }
end

distro = DISTROS[os[:release].to_s.split('.').first]

describe file('/etc/apt/sources.list.d/nginx-binary.list') do
  it { should exist }
  its('content') { should include %Q(deb      http://nginx.org/packages/mainline/debian #{distro} nginx)  }
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
  its('processes') { should include 'nginx' }
  its('protocols') { should include 'tcp' }
  its('addresses') { should include '0.0.0.0' }
end
