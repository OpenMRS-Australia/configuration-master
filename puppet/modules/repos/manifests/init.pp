class repos::centos5 {
  file { "/etc/yum.repos.d/centos5.repo":
    ensure => "present",
    owner  => "root",
    group  => "root",
    source => "${work_dir}/modules/repos/files/etc/yum.repos.d/centos5.repo"
  }

  exec { "install_repo_gpg":
    command => "/bin/rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5",
    require => File["/etc/yum.repos.d/centos5.repo"]
  }
}