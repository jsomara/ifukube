require 'xmlrpc/client'

module Bugzilla
  #
  # The Bugzilla server gives us times in Boston time, aka US/Eastern, aka -0500.
  # Need to deal with that when reconciling bugs
  #
  BUGZILLA_TIMEZONE = "-0500"

  class Rpc
    attr_reader :last_call_time
    attr_reader :server

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

    CLOSE_COMMENT = <<END_OF_STRING
Since the problem described in this bug report should be
resolved in a recent advisory, it has been closed with a
resolution of ERRATA.

For information on the advisory, and where to find the updated
files, follow the link below.

If the solution does not work for you, open a new bug report.

END_OF_STRING

    class RPCBug
      attr_accessor :flags

      def initialize(bug_hash)
        @hash = bug_hash
        @flags = ''
        unless @hash['flags'].blank?
          @flags = @hash['flags'].collect {|f| f['name'] + f['status']}.join(', ')
        end
      end

      # Bz's will send times formatted like this: "2011-10-07 12:17:14". ActiveRecord will,
      # by default, treat that as UTC, which is wrong. To parse the time correctly we need to
      # append the timezone offset, eg "2011-10-07 12:17:14 -0500", and use Time.zone.parse.
      def changeddate
        rpcdate = @hash['last_change_time']
        return nil unless rpcdate
        Time.zone.parse("#{rpcdate.to_time} #{BUGZILLA_TIMEZONE}")
      end

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

    class BugzillaError < RuntimeError
      def initialize(msg)
        super(msg)
      end
    end

    def self.get_connection(unique = true)
      if Rails.env.test?
        return TestRpc.new
      end

      return Rpc.new if unique
      @@rpc ||= Rpc.new
    end

    def initialize(host = BUGZILLA_SERVER, verify_ssl = true)
      @server = BugzillaConnection.new(host, verify_ssl)
      @proxy = @server.proxy('bugzilla')
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

    def mark_bug_on_qa(bug, errata)
      return unless bug.automatic_modified_to_on_qa?
      Rails.logger.debug "Moving bug #{bug.id} to ON_QA for errata #{errata.id} " + "- #{errata.fulladvisory}"

      bz_comment = "Bug report changed to ON_QA status by Errata System.\n"
      bz_comment += "A QE request has been submitted for advisory #{errata.fulladvisory}\n"
      bz_comment += "http://errata.devel.redhat.com/errata/show/#{errata.id}"

      if changeStatus(bug.id, 'ON_QA', bz_comment)
        bug = Bug.find(bug.bug_id)
        bug.bug_status = 'ON_QA'
        bug.was_marked_on_qa = 1
        bug.save
      end
    end

    def log_rpc_failure(error)
      Rails.logger.error "Bugzilla RPC error: " + error.message
      Rails.logger.error error.backtrace.join("\n")
    end
  end
end
