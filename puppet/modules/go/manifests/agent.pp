class go::agent {

  Class["Go::server"] -> Class["Go::agent"]

  package { ["rpm-build", "git"]: ensure => "installed" }

  package { "go-agent":
    ensure => "installed",
    source => "http://download01.thoughtworks.com/go/12.4/update/go-agent-12.4.0-16089.noarch.rpm",
    provider => "rpm",
    require => Class["jdk"],
    notify => Service["go-agent"],
  }

  service { "go-agent":
    ensure => "running",
    require => [Package["go-agent"], File["/var/go/.bash_profile"]],
  }

  file { "/var/go/.bash_profile":
    ensure => present,
    owner => "go",
    group => "go",
    source => "${work_dir}/modules/go/files/var/go/_bash_profile",
    require => Package["go-agent"],
    notify => Service["go-agent"]
  }

  file { "/var/go/.ssh":
    ensure => directory,
    owner => "go",
    group => "go",
  }

  file { "/var/go/.ssh/config":
    source => "${work_dir}/modules/go/files/var/go/_ssh/config",
    owner => "go",
    group => "go",
    mode => 0600,
  }
}
