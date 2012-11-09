require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
begin
  require 'rubygems'
  require 'rubygems/package_task'
rescue Exception
  nil
end

# Determine the current version of the software

CLOBBER.include('pkg')

SRC_RB = FileList['lib/**/*.rb']

# The default task is run if rake is given no explicit arguments.

desc "Default Task"
task :default => :test_all

# Test Tasks ---------------------------------------------------------

Rake::TestTask.new("test_units") do |t|
  t.test_files = FileList['test/lib/*.rb', 'test/*.rb']
  t.verbose = false
end

# ====================================================================
# Create a task that will package the Rake software into distributable
# gem files.

PKG_FILES = FileList[
  'etc/**/*.yml',
  'lib/**/*.rb',
  'scripts/**/*.rb'
]

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|

    #### Basic information.

    s.name = 'ifukube'
    s.version = `rpm -q --qf "%{version}" --specfile rubygem-ifukube.spec`
    s.summary = "Bugzilla tool"
    s.description = %{\
Simple library for querying bugzilla
}
    s.homepage = "http://www.redhat.com"
    s.files = PKG_FILES.to_a
    s.require_path = 'lib'

    s.test_files = PKG_FILES.select { |fn| fn =~ /^test\/test/ }

    s.has_rdoc = true
    s.author = "Jordan OMara"
    s.email = "jomara@redhat.com"

  end

  namespace 'ifukube' do
    Gem::PackageTask.new(spec) do |t|
      t.need_tar = true
    end
  end

  task :package => ['ifukube:package']
end
