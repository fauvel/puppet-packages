class mongodb::role::arbiter (
  $port = 27018,
  $bind_ip = '0.0.0.0',
  $hostname = 'localhost',
  $repl_set,
  $repl_members,
  $options = { },
  $key_file_content = undef,
) {

  $defaults = {
    'nojournal' => true,
    'smallfiles' => true,
    'noprealloc' => true,
  }

  mongodb::core::mongod { 'arbiter':
    port             => $port,
    bind_ip          => $bind_ip,
    shard_server     => true,
    repl_set         => $repl_set,
    options          => merge($defaults, $options),
    key_file_content => $key_file_content,
  }

  mongodb_replset { $repl_set:
    ensure   => present,
    members  => $repl_members,
    arbiters => ["${hostname}:${port}"],
    require  => Mongodb::Core::Mongod['arbiter'],
  }

}
