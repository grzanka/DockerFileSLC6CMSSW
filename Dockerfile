FROM centos:centos6

MAINTAINER Leszek Grzanka <grzanka@agh.edu.pl>

ADD RPM-GPG-KEY-cern /etc/pki/rpm-gpg/RPM-GPG-KEY-cern
ADD HEP_OSlibs.repo /etc/yum.repos.d/HEP_OSlibs.repo

# Ruby
RUN yum -y update; yum clean all
RUN yum -y install rubygems ruby-devel gcc; yum clean all

# Ruby 193 tricks
RUN yum -y install centos-release-scl; yum clean all
RUN yum -y install ruby193 ruby193-ruby-devel; yum clean all
RUN echo "export PATH=\${PATH}:/opt/rh/ruby193/root/usr/local/bin" | tee -a /opt/rh/ruby193/enable
RUN source /opt/rh/ruby193/enable
RUN cp /opt/rh/ruby193/enable /etc/profile.d/ruby193.sh

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN /bin/bash --login -c "gem install puppet"
RUN /bin/bash --login -c "gem install librarian-puppet -v 1.0.9"

# Libraries
RUN yum install -y vim wget git sudo HEP_OSlibs_SL6 e2fsprogs; yum clean all
ADD Puppetfile /

RUN useradd cmsbuild && install -o cmsbuild -d /opt/cmsbuild
RUN /bin/bash --login -c "librarian-puppet install"

RUN mkdir -p /opt/cms
RUN chown -R cmsbuild:cmsbuild /opt/cms

RUN echo "cmsbuild ALL=(ALL) ALL" >> /etc/sudoers


CMD /bin/bash
