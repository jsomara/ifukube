require 'singleton'
require 'yaml'

class Ifukube
  ####################################################################
  # Module constants
  ####################################################################
  CONFIG = "/etc/ifukube.yml"
  ####################################################################
  # Module class definitions
  ####################################################################
  class Config
    include Singleton
    attr_accessor :host,
                  :port,
                  :username,
                  :password
    def initialize
      begin
        config = YAML.load_file(Ifukube::CONFIG)
        @host = config["host"]
        @port= config["port"]
        @username = config["username"]
        @password = config["password"]
      rescue Errno::ENOENT
        $stderr.puts("The #{Ifukube::CONFIG} config file you specified was not found")
        exit
      rescue Errno::EACCES
        $stderr.puts("The #{Ifukube::CONFIG} config file you specified is not readable")
        exit
      end
    end
  end
end
