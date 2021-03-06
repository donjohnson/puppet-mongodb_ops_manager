# Class: mongodb_ops_manager::application_db
#
# install mongodb for ops manager (mms on premise) application.
#
#
class mongodb_ops_manager::application_db(
  $logpath     = '/var/log/mongodb/mongodb.log',
  $dbpath      = '/var/lib/mongodb',
  $dbparent    = '/data',
  $port        = 27017,
#  $repo_location = undef,
  $version  = undef,)
{

  if !defined(Class['epel']) {
    class { 'epel': }
  }

  if $operatingsystemrelease =~ /^7.*/ {
    file {'/etc/tmpfiles.d/mongod.conf':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => 'D /var/run/mongodb 0755 mongod mongod -',
      require => Class['epel']
    }
  }

  class { '::mongodb::globals':
    manage_package_repo => true,
    server_package_name => 'mongodb-org',
    bind_ip             => ['0.0.0.0'],
    version             => $version,
#    repo_location       => $repo_location,
    require             => Class['epel']
  }

  class {'::mongodb::server':
    auth    => false,
    verbose => true,
    logpath => $logpath,
    dbpath  => $dbpath,
    port    => $port,
    require => Class['::mongodb::globals']
  }

  class {'::mongodb::client':
    require => Class['::mongodb::server']
  }
}
