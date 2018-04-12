# coding: utf-8
require 'puppet/provider/package'
require 'net/http'
require 'xmlrpc/client'
require 'puppet/util/http_proxy'

Puppet::Type.type(:package).provide(:openstack_pip, :parent => :pip) do

  desc "Python packages via `pip` with mirrors."

  has_feature :installable, :uninstallable, :upgradeable, :versionable, :package_settings

  # Why do we do this?
  #
  #  To summarize, implementing self.instances in your provider means
  #  that you need to return an array of provider instances that have
  #  been discovered on the current system and all the current property
  #  values (we call these values the ‘is’ values for the properties,
  #  since each value IS the current value of the property on the
  #  system). It’s recommended to only implement self.instances if you
  #  can gather all resource property values in a reasonably ‘cheap’
  #  manner (i.e. a single system call, read from a single file, or some
  #  similar low-IO means). Implementing self.instances not only gives
  #  you the ability to run puppet resource (which also affords you a
  #  quick-and-dirty way of testing your provider without creating unit
  #  tests by simply running puppet resource in debug mode and checking
  #  the output), but it also allows the ‘resources’ resource to work its
  #  magic (If you’ve never heard of the ‘resources’ resource, check this
  #  link for more information on this terribly/awesomely named resource
  #  type).
  #
  # http://garylarizza.com/blog/2013/12/15/seriously-what-is-this-provider-doing/
  #
  # Because we have the package_settings "virtualenv" it doesn't
  # really make a lot of sense to gather "all" resources.  Since this
  # is just a caching method, override it from the base version (which
  # does a global "pip --list") to do nothing.
  def self.instances
    [ ]
  end

  def self.outdated
    @outdated ||= pip(['list', '--outdated'])
  end

  def latest
    outdated = self.class.outdated
    if outdated =~ /#{@resource[:name]}/
      latest = outdated.split("\n").select { |line|
        line =~ /#{@resource[:name]}/
      }.first.match('Latest: ([^\s)]*)')[1]
    else
      package_info = lazy_pip(['show', @resource[:name]])
      current = package_info.split("\n").select { |line|
        line =~ /^Version/
      }.first.split(': ')[1]
      latest = current
    end
    return latest
  end

  # This overrides the pip calls to prefix a virtualenv set within
  # package_settings, which is otherwise unsued for pip.
  # Unfortunately without patching puppet we can't define our own
  # resource names, which is why we overload package_settings.
  #
  def lazy_pip(*args)
    pip(*args)
  rescue NoMethodError => e
    if @resource[:package_settings]['virtualenv']
      pip_path = String(@resource[:package_settings]['virtualenv'] + "/pip")
      Puppet.debug("Using #{pip_path}")
      self.class.commands :pip => pip_path
    else
      # copied from parent class; see notes there
      if pathname = self.class.cmd.map { |c| which(c) }.find{ |c| c != nil }
        self.class.commands :pip => File.basename(pathname)
      end
    end
    pip(*args)
  end

end
