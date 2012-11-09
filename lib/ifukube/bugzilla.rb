require 'xmlrpc/client'

module Bugzilla
  class Rpc

    INCLUDE_FIELDS = [:alias,
                      :cf_pm_score,
                      :cf_qa_whiteboard,
                      :cf_release_notes,
                      :cf_verified,
                      :classification,
                      :component,
                      :flags,
                      :groups,
                      :id,
                      :keywords,
                      :last_change_time,
                      :priority,
                      :product,
                      :severity,
                      :status,
                      :summary]

    def initialize(host = nil, verify_ssl = true)
      @server = BugzillaConnection.new(host, verify_ssl)
      @proxy = @server.proxy('bugzilla')
    end

    class BugzillaConnection < XMLRPC::Client
      def initialize(host, verify_ssl = true)
        super(host, '/xmlrpc.cgi', port=nil, proxy_host=nil, proxy_port=nil, user=nil, password=nil, use_ssl=true, timeout=240)
        if verify_ssl
          @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          store = OpenSSL::X509::Store.new
          store.set_default_paths
          @http.cert_store = store
        end
      end
    end

    def raw_get_bugs(username, password, bug_list)
      @server.call('User.login', {'login' => username, 'password' => password})
      res = @server.call('Bug.get', { :ids => bug_list,
                           :include_fields => INCLUDE_FIELDS})
      res
    end

    def search_bugs(username, password, search_hash)
      search_hash['include_fields'] = INCLUDE_FIELDS
      @server.call('User.login', {'login' => username, 'password' => password})
      @server.call("Bug.search", search_hash)
    end

  end
end
