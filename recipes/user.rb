

user node['solr']['user'] do
  group node['solr']['group']
  home node['solr']['paths']['home']
  shell '/bin/bash'
  supports manage_home: false
end
