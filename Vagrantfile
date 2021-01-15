Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/focal64"
    config.vm.hostname = "HAL 9000"
    config.disksize.size = "80GB"
    config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 2
        v.name = "HAL 9000"
    end
end