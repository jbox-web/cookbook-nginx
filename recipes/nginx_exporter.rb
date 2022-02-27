if node['prometheus_exporters']['nginx']['install']
  nginx_exporter 'main' do
    action %i(install enable start)
  end
end
