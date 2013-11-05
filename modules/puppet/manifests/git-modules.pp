define puppet::git-modules ($source, $version = 'master') {

  require 'git'
  include 'puppet::common'

  $path = "/etc/puppet/repos/${name}"
  $pathEscaped = shellquote($path)
  $versionCommand = "\$(git rev-list ${version} -1)"
  $updateCommand = "cd ${pathEscaped} && git fetch --quiet origin && git fetch --quiet --tags origin && git checkout --quiet ${versionCommand}"
  notify{$updateCommand:}

  exec {"puppet repo ${name}":
    command => "git clone ${source} ${pathEscaped}",
    path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    creates => $path,
    require => Package['git'],
    notify => Exec['/etc/puppet/conf.d/main-modulepath'],
  }
  ->

  cron {"cron git-modules-update ${name}":
    command => $updateCommand,
    user    => 'root',
  }
  ~>

  exec {$updateCommand:
    path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    provider => shell,
    refreshonly => true,
  }
}
