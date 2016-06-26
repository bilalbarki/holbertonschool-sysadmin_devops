from fabric.api import *

# the user to use for the remote commands
env.user = 'admin'
# the server where the commands are executed
env.hosts = ['158.69.92.163']
# custom directory for the ssh key
env.key_filename = '~/.ssh_holberton/id_rsa_holberton'
#file/folder name
name = 'Micro-Blog-Project'
#remote code directory
remote_dir = '/var/www'

def pack(local_dir = '~/github'):
    # create a tarball from local source folder
    local('tar czf %s.tar.gz -C %s %s' % (name, local_dir, name))

def deploy():
    # upload the source tarball to the temporary folder on the server
    put('%s.tar.gz' % name, '/tmp/%s.tar.gz' % name)
    with cd('/tmp'):
        #if the folder with the name of "name" already exists, delete it first
        run('rm -rf %s' % name)
        # extract tar.gz
        run('tar -xzf /tmp/%s.tar.gz' % name)
    with cd(remote_dir):
        # delete previous website folder and move the new folder in its place
        run('sudo rm -rf %s' % name)
        run('sudo mv /tmp/%s ./' % name)
        # remove temporary files
        run('rm -rf /tmp/%s /tmp/%s.tar.gz' % (name, name))
    local('rm -f %s.tar.gz' % name)
    
# turn maintenance mode on
def maintenance_on():
    with cd('%s/%s' % (remote_dir, name)):
        run('touch maintenance.enable')

# turn maintenance mode off
def maintenance_off():
    with cd('%s/%s' % (remote_dir, name)):
        run('rm -f maintenance.enable')
