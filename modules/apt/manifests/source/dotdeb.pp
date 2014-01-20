class apt::source::dotdeb {

  helper::fail_on_os { "OS Version check $title": }

  apt::source {'dotdeb':
    entries => [
    "deb http://packages.dotdeb.org ${lsbdistcodename} all",
    "deb-src http://packages.dotdeb.org ${lsbdistcodename} all",
    ],
    keys => {
      'dotdeb' => {
        'key' => '89DF5277',
        'key_url' => 'http://www.dotdeb.org/dotdeb.gpg',
      }
    },
    require => Helper::Fail_on_os[ "OS Version check $title" ],
  }
}
