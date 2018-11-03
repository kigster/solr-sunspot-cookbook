module Solr
  class ServiceHelper < Struct.new(:node)

    def start_command
      [
        'nohup',
        config['java_executable'],
        config['jvm_flags'],
        memory_flags,
        replica_flags,
        master_flags,
        jetty_flags,
        newrelic_flags,
        '-jar start.jar &'
      ].compact.join(' ')
    end

    def working_directory
      return replica_config['home'] if replica?
      master_config['home']
    end

    def replica?
      config['service_name'] == 'solr-replica'
    end

    private

    def jetty_flags
      ip = node['privateaddress'] if config['only_bind_private_ip']
      ip = '127.0.0.1' if config['bind_localhost']
      [].tap do |flags|
        flags << "-Djetty.host=#{ip}" if ip
        flags << "-Djetty.home=#{working_directory}"
      end.join(' ')
    end

    def memory_flags
      xms = config['memory']['xms']
      xmx = config['memory']['xmx']
      [].tap do |flags|
        flags << "-Xms#{xms}" if xms
        flags << "-Xmx#{xmx}" if xmx
      end.join(' ')
    end

    def master_flags
      return nil if replica?
      [].tap do |cmd|
        cmd << "-Djetty.port=#{master_config['port']}"
        cmd << "-Djava.util.logging.config.file=#{master_config['home']}/log.conf"
        cmd << "-Dsolr.data.dir=#{master_config['home']}/solr/data"
      end.join(' ')
    end

    def newrelic_flags
      return nil if config['newrelic']['api_key'].to_s.empty?
      "-javaagent:#{config['newrelic']['jar']} " \
      "-Dnewrelic.environment=#{config['newrelic']['environment']}"
    end

    def replica_flags
      return nil unless replica?
      [].tap do |cmd|
        cmd << "-Dreplication.url=http://#{solr_master_ip}:#{master_config['port']}/solr/replication"
        cmd << "-Djetty.port=#{replica_config['port']}"
        cmd << "-Djava.util.logging.config.file=#{replica_config['home']}/log.conf"
        cmd << "-Dsolr.data.dir=#{replica_config['home']}/solr/data"
      end.join(' ')
    end

    def master_config
      config['master']
    end

    def replica_config
      config['replica']
    end

    def config
      node['solr']
    end

    def solr_master_ip
      search_string = config['replica']['solr_master']
      ip_attr = config['replica']['master_ip_attribute']
      hosts = partial_search_in_env('node', search_string, keys: { 'address' => [ip_attr] }) # ~FC003
      hosts.first['address']
    end
  end
end
