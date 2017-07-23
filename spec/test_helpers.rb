module TestHelpers
  def load_config(config)
    pwd = File.dirname(__FILE__)
    config = {:markup_dir => File.join(pwd, 'random-test-wiki')}
      .merge(config)
    # Write config file
    File.open(File.expand_path('../bin/app_config.yml', pwd), 'w') do |f|
      f.puts config.to_yaml
    end
  end
end
