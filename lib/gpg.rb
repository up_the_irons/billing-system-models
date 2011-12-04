config = YAML.load(File.read(File.join(File.dirname(__FILE__), 'gpg.yml')))

$GPG = config['gpg'] || '/usr/bin/gpg'
$GPG_HOMEDIR = config['homedir'] || '~/.gnupg'
$GPG_RECIPIENT = config['recipient']
