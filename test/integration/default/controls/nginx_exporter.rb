# Test Prometheus nginx_exporter service
describe service('prometheus-nginx-exporter-main') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(9113) do
  its('processes') { should include 'nginx_exporter' }
  its('protocols') { should include 'tcp6' }
  its('addresses') { should include '::' }
end
