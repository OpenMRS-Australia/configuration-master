class buildserver {
  include jdk
  include go::server
  include go::agent
  include repos::centos5
  include xserver
  include firefox
}

include buildserver
