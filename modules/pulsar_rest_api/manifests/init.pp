class pulsar_rest_api (
  $version = latest,
  $port = 8080,

  $mongodb_host = 'localhost',
  $mongodb_port = 27017,
  $mongodb_db = 'pulsar-rest-api',

  $log_dir = '/var/log/pulsar-rest-api',

  $pulsar_repo = undef,
  $pulsar_branch = undef,

  $auth = undef,

  $ssl_key = undef,
  $ssl_pfx = undef,
  $ssl_cert = undef,
  $ssl_passphrase = undef
) {

  require 'pulsar'
  require 'nodejs'

  user { 'pulsar-rest-api':
    ensure     => present,
    system     => true,
    managehome => true,
    home       => '/home/pulsar-rest-api',
  }

  if $mongodb_host == 'localhost' {
    class { 'mongodb::role::standalone':
      hostname => $mongodb_host,
      port     => $mongodb_port,
    }
  }
  include 'pulsar_rest_api::service'

  file { '/etc/pulsar-rest-api':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0644',
  }

  file { '/etc/pulsar-rest-api/ssl':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0644',
  }

  if $ssl_key {
    $ssl_key_file = '/etc/pulsar-rest-api/ssl/cert.key'
    file { $ssl_key_file:
      ensure  => file,
      content => $ssl_key,
      owner   => 'pulsar-rest-api',
      group   => '0',
      mode    => '0440',
      before  => Package['pulsar-rest-api'],
      notify  => Service['pulsar-rest-api'],
    }
  }

  if $ssl_cert {
    $ssl_cert_file = '/etc/pulsar-rest-api/ssl/cert.pem'
    file { $ssl_cert_file:
      ensure  => file,
      content => $ssl_cert,
      owner   => 'pulsar-rest-api',
      group   => '0',
      mode    => '0440',
      before  => Package['pulsar-rest-api'],
      notify  => Service['pulsar-rest-api'],
    }
  }

  if $ssl_pfx {
    $ssl_pfx_file = '/etc/pulsar-rest-api/ssl/cert.pfx'
    file { $ssl_pfx_file:
      ensure  => file,
      content => $ssl_pfx,
      owner   => 'pulsar-rest-api',
      group   => '0',
      mode    => '0440',
      before  => Package['pulsar-rest-api'],
      notify  => Service['pulsar-rest-api'],
    }
  }

  if $ssl_passphrase {
    $ssl_passphrase_file = '/etc/pulsar-rest-api/ssl/passphrase'
    file { $ssl_passphrase_file:
      ensure  => file,
      content => $ssl_passphrase,
      owner   => '0',
      group   => '0',
      mode    => '0440',
      before  => Package['pulsar-rest-api'],
      notify  => Service['pulsar-rest-api'],
    }
  }

  file { '/etc/pulsar-rest-api/config.yml':
    ensure  => file,
    content => template('pulsar_rest_api/config.yml'),
    owner   => 'pulsar-rest-api',
    group   => '0',
    mode    => '0440',
    before  => Package['pulsar-rest-api'],
    notify  => Service['pulsar-rest-api'],
  }

  file { $log_dir:
    ensure  => directory,
    owner   => 'pulsar-rest-api',
    group   => 'pulsar-rest-api',
    mode    => '0644',
    before  => Package['pulsar-rest-api'],
  }


  file { '/etc/init.d/pulsar-rest-api':
    ensure  => file,
    content => template("${module_name}/init.sh"),
    owner   => '0',
    group   => '0',
    mode    => '0755',
    before  => Package['pulsar-rest-api'],
    notify  => Service['pulsar-rest-api'],
  }

  package { 'pulsar-rest-api':
    ensure   => $version,
    provider => 'npm',
    require  => Class['nodejs'],
  }

  helper::service { 'pulsar-rest-api':
    require => Package['pulsar-rest-api'],
  }

  logrotate::entry{ $module_name:
    content => template("${module_name}/logrotate")
  }

  @monit::entry { 'pulsar-rest-api':
    content => template("${module_name}/monit"),
    require => Service['pulsar-rest-api'],
  }
}
