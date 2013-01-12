class go::server {
  package { "unzip": ensure => "installed" }

  package { "go-server":
    ensure => "installed",
    source => "http://download01.thoughtworks.com/go/12.4/update/go-server-12.4.0-16089.noarch.rpm",
    provider => "rpm",
    require => [Class["jdk"], Package["unzip"]],
  }

  service { "go-server":
    ensure => "running",
    require => Package["go-server"],
  }

  file { "/etc/go/cruise-config.xml":
    ensure => "present",
    owner  => "go",
    group  => "go",
    source => "${work_dir}/modules/go/files/etc/go/cruise-config.xml",
    require => Package["go-server"],
  }
}
