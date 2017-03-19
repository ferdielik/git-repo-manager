require 'yaml'
require 'optparse'

$config = YAML.load_file(ARGV[0])

class String
  # colorization
  def colorize(color_code) "\e[#{color_code}m#{self}\e[0m" end

  def red; colorize(31); end
  def green; colorize(32); end
  def blue; colorize(34); end
  def light_blue; colorize(36); end
end

def mkdir_if_not_exist(name)
  unless File.directory?(name)
    Dir.mkdir name
  end
end

def clone_repo(url)
  cmd = "git clone #{url}"
  system(cmd)
end

class Repo
  attr_accessor :parents, :url

  def initialize(parents, url)
    @parents, @url = parents, url
  end

  def repo_name
    @url.split('/').last.sub('.git', '')
  end

  def parents_text
    r=''
    @parents.each do |fol|
      r+=fol + ' > '
    end
    r
  end

  def run_git_command(command)
    parents.each do |parent|
      Dir.chdir(parent)
    end

    st = 'git -C ' + Dir.pwd + '/' + repo_name + ' ' + command
    system(st)
    parents.length > 0
    s=0
    while s < parents.length do
      Dir.chdir('..')
      s+=1
    end
  end
end

def get_all(conf, parent)
  repos = []
  conf.each do |key, value|
    if key.is_a? String and value.nil?
      repos.push(Repo::new(parent, key))
      # puts "#{parent} -- > #{key}"
    end

    if value.is_a? Array
      test= parent.clone
      test.push(key)
      get_all(value, test).each do |sub|
        repos.push(sub)
      end

    elsif key.is_a? Hash
      get_all(key, parent).each do |sub|
        repos.push(sub)
      end
    end
  end
  repos
end


def dry_run(repos)
  repos.each do |k|
    puts "#{k.parents_text.green} --> #{k.url}"
  end
end

def download(repos)
  repos.each do |repo|
    puts repo.parents
    repo.parents.each do |parent|
      mkdir_if_not_exist(parent)
      Dir.chdir(parent)
    end
    clone_repo(repo.url)
    repo.parents.length > 0
    s=0
    while s < repo.parents.length do
      Dir.chdir('..')
      s+=1
    end
  end
end

def reset_all(repos)
  repos.each do |repo|
    puts repo.parents_text.green + repo.repo_name.green
    repo.run_git_command 'add .'
    repo.run_git_command 'reset --hard'
    repo.run_git_command 'pull'
    puts 'reset done.'.green
  end
end

def update(repos)
  repos.each do |repo|
    puts repo.parents_text.green + repo.repo_name.green
    repo.run_git_command 'pull'
    puts
  end
end

all_repos = get_all($config['repos'], [])
Dir.chdir($config['root_file'])

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: main.rb <properties> [options]'

  opts.on('', '--dry-run', 'Dry Run') do
    dry_run(all_repos)
  end

  opts.on('-d', '--download-repositories', 'Download Repositories') do
    download(all_repos)
  end

  opts.on('-r', '--reset-repositories', 'Reset Repositories') do
    reset_all(all_repos)
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!
# test(all_repos)