class ssh (
  $permit_root_login = 'yes',
  $port = 22,
) {

  require 'apt'

  file { '/etc/ssh/ssh_config':
    ensure  => file,
    content => template("${module_name}/ssh_config"),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    before  => Package['ssh'],
  }

  file { '/etc/ssh/sshd_config':
    ensure  => file,
    content => template("${module_name}/sshd_config"),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    before  => Package['ssh'],
    notify  => Service['ssh'],
  }

  # Workaround for http://projects.puppetlabs.com/issues/2014
  file { '/etc/ssh/ssh_known_hosts':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  ->

  package { 'ssh':
    ensure   => installed,
    provider => 'apt',
    before   => Service['ssh'],
  }

  service { 'ssh':
    enable => true,
  }

  @ufw::application { 'OpenSSH':
    app_ports => "${port}/tcp",
  }
}
