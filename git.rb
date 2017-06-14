src_filename = 'git-2.9.3.tar.gz'
src_dir = 'git-2.9.3'
src = '2.9.3'
src_filepath = "#{Chef::Config[:file_cache_path]}/#{src_filename}"
extract_path = "#{ Chef::Config['file_cache_path']}/git"


remote_file "#{src_filepath}" do
        source "https://www.kernel.org/pub/software/scm/git/#{src_filename}"

end

bash 'install_git' do
        cwd ::File.dirname(src_filepath)
         code <<-EOH
          mkdir -p #{extract_path}
          tar xzf #{src_filename} -C #{extract_path}
          cd #{extract_path}/#{src_dir}
        sudo yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-devel
        sudo  make prefix=/usr/local/git all
         sudo  make prefix=/usr/local/git install
         sudo   echo 'export PATH=$PATH:/usr/local/git/bin' >> /etc/bashrc
         sudo  source /etc/bashrc
         sudo  ln -sf /usr/local/git/bin/git /usr/bin/git
        EOH
#only_if( "git --version|awk {'print $3'} != #{src}")
end
