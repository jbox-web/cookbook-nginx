resource_name :nginx_exporter
provides :nginx_exporter

property :nginx_retries,           String, default: '5'
property :nginx_retry_interval,    String, default: '5s'
property :nginx_scrape_uri,        String, default: 'http://127.0.0.1:9000/nginx-status'
property :nginx_ssl_ca_cert,       String
property :nginx_ssl_client_cert,   String
property :nginx_ssl_client_key,    String
property :nginx_ssl_verify,        [true,  false],  default: false
property :nginx_timeout,           String, default: '5s'
property :prometheus_const_labels, String
property :web_listen_address,      String, default: '0.0.0.0:9113'
property :web_telemetry_path,      String
property :user,                    String, default: 'nginx_exporter'

action :install do
  node.default['prometheus_exporters']['nginx']['enabled'] = true

  options = "-nginx.retries=#{new_resource.nginx_retries}"
  options += " -nginx.retry-interval=#{new_resource.nginx_retry_interval}"
  options += " -nginx.scrape-uri=#{new_resource.nginx_scrape_uri}"
  options += " -nginx.ssl-ca-cert=#{new_resource.nginx_ssl_ca_cert}" if new_resource.nginx_ssl_ca_cert
  options += " -nginx.ssl-client-cert=#{new_resource.nginx_ssl_client_cert}" if new_resource.nginx_ssl_client_cert
  options += " -nginx.ssl-client-key=#{new_resource.nginx_ssl_client_key}" if new_resource.nginx_ssl_client_key
  options += ' -nginx.ssl-verify' if new_resource.nginx_ssl_verify
  options += " -nginx.timeout=#{new_resource.nginx_timeout}"
  options += " -prometheus.const-labels=#{new_resource.prometheus_const_labels}" if new_resource.prometheus_const_labels
  options += " -web.listen-address=#{new_resource.web_listen_address}"
  options += " -web.telemetry-path=#{new_resource.web_telemetry_path}" if new_resource.web_telemetry_path

  service_name = "prometheus-nginx-exporter-#{new_resource.name}"

  # Create exporter user
  directory '/var/lib/prometheus'
  user 'nginx_exporter' do
    home        '/var/lib/prometheus/nginx_exporter'
    shell       '/usr/sbin/nologin'
    manage_home true
  end

  # Create exporters parent dir
  directory '/opt/prometheus'

  # Create nginx exporter parent dir
  directory "/opt/prometheus/nginx_exporter-v#{node['prometheus_exporters']['nginx']['version']}" do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  # Download binary
  remote_file 'nginx_exporter' do
    path "#{Chef::Config[:file_cache_path]}/nginx_exporter.tar.gz"
    owner 'root'
    group 'root'
    mode '0644'
    source node['prometheus_exporters']['nginx']['url']
    checksum node['prometheus_exporters']['nginx']['checksum']
    notifies :restart, "service[#{service_name}]"
  end

  bash 'untar_nginx_exporter' do
    code "tar -xzf #{Chef::Config[:file_cache_path]}/nginx_exporter.tar.gz -C /opt/prometheus/nginx_exporter-v#{node['prometheus_exporters']['nginx']['version']}"
    action :nothing
    subscribes :run, 'remote_file[nginx_exporter]', :immediately
  end

  bash 'fix_owner_nginx_exporter' do
    code "chown -R root\: /opt/prometheus/nginx_exporter-v#{node['prometheus_exporters']['nginx']['version']}"
    action :nothing
    subscribes :run, 'bash[untar_nginx_exporter]', :immediately
  end

  link '/usr/local/bin/nginx_exporter' do
    to "/opt/prometheus/nginx_exporter-v#{node['prometheus_exporters']['nginx']['version']}/nginx-prometheus-exporter"
  end

  # Configure to run as a service
  service service_name do
    action :nothing
  end

  systemd_unit "#{service_name}.service" do
    content(
      'Unit' => {
        'Description' => 'Systemd unit for Prometheus Nginx Exporter',
        'After'       => 'network-online.target',
      },
      'Service' => {
        'Type'             => 'simple',
        'User'             => new_resource.user,
        'Group'            => new_resource.user,
        'ExecStart'        => "/usr/local/bin/nginx_exporter #{options}",
        'WorkingDirectory' => '/var/lib/prometheus/nginx_exporter',
        'Restart'          => 'on-failure',
        'RestartSec'       => '30s',
        'PIDFile'          => '/run/nginx_exporter.pid',
      },
      'Install' => {
        'WantedBy' => 'multi-user.target',
      },
    )
    notifies :restart, "service[#{service_name}]"
    action :create
  end
end

action :enable do
  action_install
  service "prometheus-nginx-exporter-#{new_resource.name}" do
    action :enable
  end
end

action :start do
  service "prometheus-nginx-exporter-#{new_resource.name}" do
    action :start
  end
end

action :disable do
  service "prometheus-nginx-exporter-#{new_resource.name}" do
    action :disable
  end
end

action :stop do
  service "prometheus-nginx-exporter-#{new_resource.name}" do
    action :stop
  end
end
