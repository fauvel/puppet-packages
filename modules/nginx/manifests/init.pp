# Class: nginx
#
# This module manages NGINX.
#
# Parameters:
#
# There are no default parameters for this class. All module parameters are managed
# via the nginx::params class
#
# Actions:
#
# Requires:
#  puppetlabs-stdlib - https://github.com/puppetlabs/puppetlabs-stdlib
#
#  Packaged NGINX
#    - RHEL: EPEL or custom package
#    - Debian/Ubuntu: Default Install or custom package
#    - SuSE: Default Install or custom package
#
#  stdlib
#    - puppetlabs-stdlib module >= 0.1.6
#    - plugin sync enabled to obtain the anchor type
#
# Sample Usage:
#
# The module works with sensible defaults:
#
# node default {
#   include nginx
# }
class nginx (
  $daemon_user            = $nginx::params::nx_daemon_user,
  $worker_processes       = $nginx::params::nx_worker_processes,
  $worker_connections     = $nginx::params::nx_worker_connections,
  $worker_rlimit_nofile   = $nginx::params::nx_worker_rlimit_nofile,
  $proxy_set_header       = $nginx::params::nx_proxy_set_header,
  $keepalive_timeout      = $nginx::params::nx_keepalive_timeout,
  $confd_purge            = $nginx::params::nx_confd_purge,
  $configtest_enable      = $nginx::params::nx_configtest_enable,
  $server_tokens          = $nginx::params::nx_server_tokens,
  $send_timeout           = $nginx::params::nx_send_timeout,
  $limit_conn_zone        = $nginx::params::nx_limit_conn_zone,
  $client_max_body_size   = $nginx::params::nx_client_max_body_size,
  $client_body_timeout    = $nginx::params::nx_client_body_timeout,
  $client_header_timeout  = $nginx::params::nx_client_header_timeout,
  $error_log              = $nginx::params::nx_error_log,
  $access_log             = $nginx::params::nx_access_log,
  $service_restart        = $nginx::params::nx_service_restrart,

) inherits nginx::params {

  include stdlib

  class { 'nginx::package':
    notify => Class['nginx::service'],
  }

  class { 'nginx::config':
    daemon_user           => $daemon_user,
    worker_processes 	  => $worker_processes,
    worker_connections 	  => $worker_connections,
    worker_rlimit_nofile  => $worker_rlimit_nofile,
    proxy_set_header 	  => $proxy_set_header,
    keepalive_timeout 	  => $keepalive_timeout,
    confd_purge           => $confd_purge,
    server_tokens         => $server_tokens,
    send_timeout          => $send_timeout,
    limit_conn_zone       => $limit_conn_zone,
    client_max_body_size  => $client_max_body_size,
    client_body_timeout   => $client_body_timeout,
    client_header_timeout => $client_header_timeout,
    error_log             => $error_log,
    access_log            => $access_log,
    require 		=> Class['nginx::package'],
    notify  		=> Class['nginx::service'],
  }

  class { 'nginx::service': 
    configtest_enable => $configtest_enable,
    service_restart => $service_restart,
  }

  monit::entry {'nginx':
    content => template('nginx/monit/nginx'),
    require => Service['nginx'],
  }

  # Allow the end user to establish relationships to the "main" class
  # and preserve the relationship to the implementation classes through
  # a transitive relationship to the composite class.
  anchor{ 'nginx::begin':
    before => Class['nginx::package'],
    notify => Class['nginx::service'],
  }
  anchor { 'nginx::end':
    require => Class['nginx::service'],
  }
}
