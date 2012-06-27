class mysql {
  package { "mysql-server":
    ensure => "installed",
    provider => "yum",
  }

  service { "mysqld":
    ensure => "running",
    require => Package["mysql-server"],
  }
}
