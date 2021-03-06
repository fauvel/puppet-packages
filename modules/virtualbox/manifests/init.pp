class virtualbox {

  require 'apt'

  apt::source { 'virtualbox':
    entries => [
      "deb http://download.virtualbox.org/virtualbox/debian ${::facts['lsbdistcodename']} contrib non-free",
    ],
    keys    => {
      'virtualbox' => {
        key     => '98AB5139',
        key_url => 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc',
      },
      'virtualbox-2016' => {
        key     => '2980AECF',
        key_url => 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc',
      }
    }
  }
  ->

  package { 'virtualbox-5.0':
    ensure   => present,
    provider => 'apt',
  }

  package { 'dkms':
    ensure   => present,
    provider => 'apt',
  }

  file { '/usr/local/bin/deleteAllVirtualboxVms':
    ensure  => file,
    content => template("${module_name}/deleteAllVirtualboxVms.sh"),
    group   => '0',
    owner   => '0',
    mode    => '0755',
  }

}
