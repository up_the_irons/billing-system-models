config = YAML.load(File.read(File.join(File.dirname(__FILE__), 'gpg.yml')))

$GPG_RECIPIENT = config['recipient']
