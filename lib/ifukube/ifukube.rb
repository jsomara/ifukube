class Ifukube

  def initialize(config=nil)
    config ||= Ifukube::Config.instance
    @username = config.username
    @password = config.password
    @host = config.host
    @port = config.port
  end

  def get_bugs(bugs)
    rpc = Bugzilla::Rpc.new(@host)
    rpc.raw_get_bugs(@username, @password, bugs)
  end

  def search_bugs(search_hash)
    rpc = Bugzilla::Rpc.new(@host)
    rpc.search_bugs(@username, @password, search_hash)
  end
end
