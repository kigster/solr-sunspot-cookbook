if node['solr']['newrelic']['api_key'].to_s.empty?
  Chef::Log.info('no newrelic api_key set, skipping installation of newrelic.jar')
else
  Chef::Log.info('newrelic api_key set, installation of newrelic.jar')

  dir = ::File.dirname(node['solr']['newrelic']['jar'])

  directory "#{dir}/logs" do
    owner node['solr']['solr_user']
    mode 0755
    recursive true
  end

  remote_file node['solr']['newrelic']['jar'] do
    source node['solr']['newrelic']['remote_jar_file']
    mode '0744'
    checksum node['solr']['newrelic']['jar_checksum']
    not_if { node['solr']['newrelic']['remote_jar_file'].empty? }
  end

  Chef::Log.info("node['solr']['newrelic'] -> #{node['solr']['newrelic'].inspect}")

  template ::File.join(dir, 'newrelic.yml') do
    source 'newrelic.yml.erb'
    owner node['solr']['solr_user']
    mode 0644
    variables(newrelic: node['solr']['newrelic'])
  end
end
