# Resource for the solr Chef provider
#
# solr 'solr' do
#   version '5.4.0'
#   solr_home '/var/solr/solr5'
#   port 8985
#   hostname 'solr.prod'
#   heap_size '1g'
#   jvm_params '-Xdebug'
#   newrelic_jar '/var/solr/solr5/newrelic/newrelic.jar'
# end
#
def initialize(name, run_context = nil)
  super
  @resource_name = :solr
  @action = :install
  @allowed_actions = [:install, :enable, :restart]
end

## Attributes

def name(arg = nil)
  set_or_return(:name, arg, kind_of: String)
end

s

def version(arg = nil)
  set_or_return(:version, arg, kind_of: String, required: true)
end

def solr_home(arg = nil)
  set_or_return(:solr_home, arg, kind_of: String, required: true)
end

def port(arg = nil)
  set_or_return(:port, arg, kind_of: Integer, default: 8983)
end

def hostname(arg = nil)
  set_or_return(:hostname, arg, kind_of: String, default: node['hostname'])
end

def heap_size(arg = nil)
  set_or_return(:heap_size, arg, kind_of: String, default: '512m')
end

def java_home(arg = nil)
  set_or_return(:java_home, arg, kind_of: String, required: true)
end

def jvm_params(arg = nil)
  set_or_return(:jvm_params, arg, kind_of: String)
end

def newrelic_jar(arg = nil)
  set_or_return(:newrelic_jar, arg, kind_of: String)
end

## Helpers

def install_dir
  '/opt/solr-%s' % version
end

def local_tar_file
  '%s/solr-%s.tgz' % [
    Chef::Config['file_cache_path'],
    version
  ]
end

def log_config_file
  ::File.join(solr_home, log_config_file_name)
end

def log_config_source
  "solr#{major_version}/log.conf.erb"
end

def log_dir
  '/var/log/solr'
end

def major_version
  version.split('.').first.to_i
end

def provider
  Chef::Provider::Solr
end

def remote_tar_file
  '%s/%s/solr-%s.tgz' % [
    node['solr']['mirror'],
    version,
    version
  ]
end

def service_environment
  {
    'PATH' => node['paths']['bin_path'],
    'JAVA_HOME' => java_home,
    'LC_ALL' => 'en_US.UTF-8',
    'LANG' => 'en_US.UTF-8',
    'SOLR_INCLUDE' => solr_include
  }.tap do |environment|
    environment['SOLR_OPTS'] = "-javaagent:#{newrelic_jar}" if newrelic_jar
  end
end

def solr_include
  '%s/solr.in.sh' % solr_home
end

def start_command
  'bin/solr start -h %{config/hostname} -p %{config/port} -s %{config/solr_home} -a "%{config/jvm_params}"'
end

def stop_command
  'bin/solr stop -p %{config/port}'
end


load_current_resource do
  @current_resource ||= new_resource.class.new(new_resource.name)
end

action :install do
  run_dependencies
  download_solr_tar
  create_user
  ensure_solr_directories
  extract_tar_file
  configure_logging
  configure_solr
  configure_service
  update_converge_status
end

action :enable do
  new_resource.notifies_immediately(:enable, solr_service)
  new_resource.updated_by_last_action(true)
end

action :restart do
  new_resource.notifies_immediately(:restart, solr_service)
  new_resource.updated_by_last_action(true)
end

private

def configure_logging
  action = template(new_resource.log_config_file) do
    source new_resource.log_config_source
    cookbook 'solr'
    owner user
    mode '0644'
    variables 'logname' => new_resource.name
  end
  action.run_action(:create)
  included_resources << action
end

def configure_service
  action = smf(new_resource.name) do
    user 'solr'
    start_command new_resource.start_command
    stop_command new_resource.stop_command
    start_timeout 300
    stop_timeout 60
    environment new_resource.service_environment
    property_groups({
        'config' => {
          'hostname' => new_resource.hostname,
          'port' => new_resource.port,
          'solr_home' => new_resource.solr_home,
          'jvm_params' => new_resource.jvm_params
        }
      })
    working_directory new_resource.install_dir
  end
  action.run_action(:install)
  included_resources << action
end

def configure_solr
  action = template('%s/solr.xml' % new_resource.solr_home) do
    source 'solr%s/solr.xml.erb' % new_resource.major_version
    cookbook 'solr'
    owner 'root'
    mode 0644
  end
  action.run_action(:create)
  included_resources << action

  action = template(new_resource.solr_include) do
    source 'solr%s/solr.in.sh.erb' % new_resource.major_version
    cookbook 'solr'
    owner 'root'
    mode 0644
    variables 'heap_size' => new_resource.heap_size,
              'solr_home' => new_resource.solr_home
  end
  action.run_action(:create)
  included_resources << action
end

def create_user
  user 'solr' do
    home node['solr']['solr_home']
    shell '/bin/bash'
    supports manage_home: false
  end.run_action(:create)
end

def download_solr_tar
  remote_file(new_resource.local_tar_file) do
    source new_resource.remote_tar_file
  end.run_action(:create)
end

def ensure_solr_directories
  [new_resource.install_dir,
    new_resource.solr_home,
    new_resource.log_dir,
    node['solr']['solr_home']
  ].each do |directory|
    action = directory(directory) do
      owner 'solr'
      mode 0755
      recursive true
    end
    action.run_action(:create)
    included_resources << action
  end
end

def extract_tar_file
  action = execute('extract solr %s tar file' % new_resource.version) do
    command 'tar xzf %s' % new_resource.local_tar_file
    cwd '/opt'
    user 'solr'
    not_if 'test -d %s/bin' % new_resource.install_dir
  end
  action.run_action(:run)
  included_resources << action
end

def included_resources
  @included_resources ||= []
end

def run_dependencies
  run_context.include_recipe 'paths'
  run_context.include_recipe 'smf'
  run_context.include_recipe 'java'
end

def solr_service
  begin
    run_context.resource_collection.find(service: new_resource.name)
  rescue Chef::Exceptions::ResourceNotFound
    service new_resource.name do
      supports reload: true, restart: true, status: true
    end
  end
end

def update_converge_status
  new_resource.updated_by_last_action(true) if included_resources.any? { |r| r.updated_by_last_action? }
end

private

def log_config_file_name
  return 'log4j.properties' if major_version >= 4
  'log.conf'
end
