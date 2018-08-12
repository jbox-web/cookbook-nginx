# Install GPG
package 'dirmngr'

# Install Nginx repository
apt_repository 'stretch-nginx-binary' do
  uri          'http://nginx.org/packages/mainline/debian'
  key          'http://nginx.org/keys/nginx_signing.key'
  components   ['nginx']
  distribution 'stretch'
end

# Install Nginx
package 'nginx'

# Install Nginx configuration
template '/etc/nginx/nginx.conf' do
  source    'nginx.conf.erb'
  variables config: node[:nginx][:server][:config]
end

# Configure logrotate
cookbook_file '/etc/logrotate.d/nginx' do
  source 'logrotate/nginx'
end

# Create Nginx log archive dir
directory '/var/log/OLD_LOGS/nginx' do
  recursive true
end

# Restart Nginx when config is changed
service 'nginx' do
  subscribes :restart, 'template[/etc/nginx/nginx.conf]', :immediately
end
