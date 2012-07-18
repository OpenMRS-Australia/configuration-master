class go::agent {

  Class["Go::server"] -> Class["Go::agent"]

  package { ["rpm-build", "git"]: ensure => "installed" }

  package { "go-agent":
    ensure => "installed",
    source => "http://download01.thoughtworks.com/go/12.2.2/ga/go-agent-12.2.2-15235.noarch.rpm",
    provider => "rpm",
    require => Class["jdk"],
    notify => Service["go-agent"]
  }

  service { "go-agent":
    ensure => "running",
    require => Package["go-agent"]
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
    mode => 0600
  }
}
