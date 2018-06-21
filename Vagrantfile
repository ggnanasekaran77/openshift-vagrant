BOX_IMAGE = "centos/7"
NODE_COUNT = 2
WORKSPACE = "/tmp/openshift"
Vagrant.configure("2") do |config|

  (1..NODE_COUNT).each do |i|
    config.vm.define "node#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.hostname = "node#{i}.example.com"
      subconfig.vm.network :private_network, ip: "192.168.33.#{i + 15}"
      subconfig.vm.provider "virtualbox" do |v|
        v.memory = 1024
    end
      subconfig.ssh.forward_agent = true
    end
  end

  config.vm.define "master" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "master.example.com"
    subconfig.vm.network :private_network, ip: "192.168.33.15"
    subconfig.vm.provider "virtualbox" do |v|
  		v.memory = 2048
	end
    subconfig.ssh.forward_agent = true
  end

  config.vm.provision "file", source: "hosts", destination: "/tmp/hosts"
  config.vm.provision "file", source: "ssh", destination: "/home/vagrant/.ssh"
  config.vm.provision "shell", inline: <<-SHELL
  	sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  	systemctl restart sshd.service
  	yum update -y
  	yum install -y  wget git zile nano net-tools docker-1.13.1\
				bind-utils iptables-services \
				bridge-utils bash-completion \
				kexec-tools sos psacct openssl-devel \
				httpd-tools NetworkManager \
				python-cryptography python2-pip python-devel  python-passlib \
				java-1.8.0-openjdk-headless "@Development Tools"
    yum -y install epel-release
    sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
    systemctl | grep "NetworkManager.*running" 
    if [ $? -eq 1 ]; then
      systemctl start NetworkManager
		  systemctl enable NetworkManager
    fi
    yum -y --enablerepo=epel install ansible pyOpenSSL
    systemctl restart docker
    systemctl enable docker
    chmod -R 600 /home/vagrant/.ssh/id_rsa
    chmod -R 644 /home/vagrant/.ssh/id_rsa.pub
    su - vagrant -c "sshpass -p vagrant ssh-copy-id $(hostname -I|awk '{print $2}')"
    touch /home/vagrant/.ssh/config
    grep "Host 192.168" /home/vagrant/.ssh/config || echo 'Host 192.168.*.*' >> /home/vagrant/.ssh/config
    grep "Host master" /home/vagrant/.ssh/config || echo 'Host master node1 node2 master.example.com node1.example.com node2.example.com' >> /home/vagrant/.ssh/config
    grep StrictHostKeyChecking /home/vagrant/.ssh/config || echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
    grep UserKnownHostsFile /home/vagrant/.ssh/config || echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config
    chmod -R 600 /home/vagrant/.ssh/config
    chown -R vagrant:vagrant /home/vagrant/.ssh
    cp /tmp/hosts /etc/hosts
    mkdir -p /tmp/openshift
    chown -R vagrant:vagrant /tmp/openshift
  SHELL
  config.vm.provision "file", source: "openshift", destination: "/tmp/openshift"
  config.vm.provision "shell", inline: "hostname|grep master && su - vagrant -c 'sh -x /tmp/openshift/install-openshift.sh' || echo Not executed"
end

