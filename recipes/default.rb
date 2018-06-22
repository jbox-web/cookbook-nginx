# Install Debian Backports repository
apt_repository 'stretch-backports-binary' do
  uri          'http://ftp.fr.debian.org/debian'
  components   ['main', 'contrib', 'non-free']
  distribution 'stretch-backports'
end

# Install Nginx
package 'nginx' do
  default_release 'stretch-backports'
end

# Install Nginx configuration
template '/etc/nginx/nginx.conf' do
  source    'nginx.conf.erb'
  variables config: node[:nginx][:server][:config]
end

# Restart Nginx when config is changed
service 'nginx' do
  subscribes :restart, 'template[/etc/nginx/nginx.conf]', :immediately
end
