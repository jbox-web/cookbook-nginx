# Default Nginx config
default['nginx']['server']['config']['worker_processes']             = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1
default['nginx']['server']['config']['include']                      = '/etc/nginx/modules-enabled/*.conf'
default['nginx']['server']['config']['pid']                          = '/run/nginx.pid'
default['nginx']['server']['config']['user']                         = 'www-data'
default['nginx']['server']['config']['events']                       = {}
default['nginx']['server']['config']['events']['worker_connections'] = 1024
default['nginx']['server']['config']['http']                         = {}
default['nginx']['server']['config']['http']['access_log']           = 'off'
default['nginx']['server']['config']['http']['error_log']            = '/var/log/nginx/error.log'
default['nginx']['server']['config']['http']['server_tokens']        = 'off'
default['nginx']['server']['config']['http']['default_type']         = 'application/octet-stream'
default['nginx']['server']['config']['http']['sendfile']             = 'on'
default['nginx']['server']['config']['http']['tcp_nopush']           = 'on'
default['nginx']['server']['config']['http']['tcp_nodelay']          = 'on'
default['nginx']['server']['config']['http']['keepalive_timeout']    = 10
default['nginx']['server']['config']['http']['client_max_body_size'] = '1m'
default['nginx']['server']['config']['http']['gzip']                 = 'on'
default['nginx']['server']['config']['http']['gzip_disable']         = 'msie6'
default['nginx']['server']['config']['http']['gzip_vary']            = 'on'
default['nginx']['server']['config']['http']['gzip_proxied']         = 'any'
default['nginx']['server']['config']['http']['gzip_comp_level']      = 6
default['nginx']['server']['config']['http']['gzip_http_version']    = 1.1
default['nginx']['server']['config']['http']['gzip_min_length']      = 1000
default['nginx']['server']['config']['http']['gzip_buffers']         = '16 8k'
default['nginx']['server']['config']['http']['gzip_types']           = %w[
  text/plain
  text/css
  text/xml
  text/mathml
  text/javascript
  application/x-json
  application/x-javascript
  application/json
  application/javascript
  application/xml
  application/rss+xml
  application/atom+xml
  application/xhtml+xml
  image/svg+xml
].join(' ')
default['nginx']['server']['config']['http']['include']              = %w[
  /etc/nginx/mime.types
  /etc/nginx/conf.d/*.conf
  /etc/nginx/sites-enabled/*.conf
]
