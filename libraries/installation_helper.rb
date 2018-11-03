module Solr
  #
  # Helper methods when installing Solr
  #
  class InstallationHelper < Struct.new(:node, :master)
    def auto_commit_enabled?
      node['solr']['config']['auto_commit']['max_docs'] &&
        node['solr']['config']['auto_commit']['max_time']
    end

    def cache_directory
      case major_version
      when 3
        ::File.join(Chef::Config['file_cache_path'], "apache-solr-#{version}")
      when 4
        ::File.join(Chef::Config['file_cache_path'], "solr-#{version}")
      end
    end

    def example_directory
      ::File.join(cache_directory, 'example')
    end

    def log_config
      case major_version
      when 3
        ::File.join(solr_home, 'log.conf')
      when 4, 5
        ::File.join(solr_home, 'resources', 'log4j.properties')
      end
    end

    def log_config_source
      "solr#{major_version}/log.conf.erb"
    end

    def solr_config
      ::File.join(solr_home, solr_config_path)
    end

    def solr_config_source
      "solr#{major_version}/solrconfig.xml.erb"
    end

    def solr_home
      master ? node['solr']['master']['home'] : node['solr']['replica']['home']
    end

    def tarball
      ::File.join(Chef::Config['file_cache_path'], "solr-#{version}.tgz")
    end

    def use_cookbook_config?
      node['solr']['uses_default_config'] || !::File.exist?(solr_config)
    end

    def version
      node['solr']['version']
    end

    private

    def major_version
      version.split('.').first.to_i
    end

    def solr_config_path
      case major_version
      when 3
        'solr/conf/solrconfig.xml'
      when 4
        'solr/collection1/conf/solrconfig.xml'
      end
    end
  end
end
