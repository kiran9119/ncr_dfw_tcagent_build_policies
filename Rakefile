require 'rake/clean'
require 'rake/packagetask'

def product_name
  'ncr_dfw_tcagent_build'
end

def version
  Gem::Version.new(File.read("#{File.dirname(__FILE__)}/VERSION").delete!('"'))
end

policy_names = Dir.glob('policies/*.rb').map { |file| file.gsub(%r{policies/(.+)\.rb}, '\1') }

archive_directory = './artifacts'
package_name = "#{product_name}_policies"

task default: [:install]

namespace :test do
  desc 'cookstyle lint'
  task :lint do
    sh('cookstyle .')
  end
end

desc 'delete all policyfile locks and artifacts'
task :clean do
  File.delete('artifacts/deploy.sh') if File.exist?('artifacts/deploy.sh')
  Dir.glob('./artifacts/*').each { |f| File.delete(f) }
  Dir.glob('./policies/*.lock.json').each { |f| File.delete(f) }
  File.delete("artifacts/#{package_name}.*") if File.exist?("artifacts/#{package_name}.*")
end

namespace :utils do
  desc 'push updated version to Git'
  task :git_push_if_needed do
    gitlog = `git log origin/master`
    `git push --set-upstream origin master` unless gitlog.empty?
  end
end

namespace :release do
  begin
    require 'bump/tasks'
  rescue
    puts 'bump not present. skipping bump tasks'
  end

  desc 'install all policies'
  task install: [:clean, 'test:lint'] do
    policy_names.each do |policy|
      sh "chef install policies/#{policy}.rb"
    end
  end

  task :create_artifact_directory do
    mkdir archive_directory unless File.exist?(archive_directory)
  end

  desc "export all policies to #{archive_directory}"
  task export: [:create_artifact_directory, :install] do
    policy_names.each do |policy|
      puts "exporting the #{policy} policy, version #{version}"
      sh "chef export policies/#{policy}.rb . -a"
      FileUtils.mv(Dir.glob("./#{policy}*.tgz")[0], "#{archive_directory}/.")
      FileUtils.cp("./policies/#{policy}.lock.json", "#{archive_directory}/#{policy}.lock.json")
    end
  end

  task :push, [:policy_group] => [:export] do |_t, args|
    exception_msg = "please set the 'policy_group' task argument"
    throw exception_msg if args[:policy_group].nil?
    policy_names.each do |policy|
      sh "chef push-archive #{args[:policy_group]} #{archive_directory}/#{policy}.tgz"
    end
  end

  desc 'bundles the policy exports into a versioned zip file'
  task bundle: [:export] do
    require 'zip'

    zipfile_path = "artifacts/#{package_name}_#{version}.zip"
    FileUtils.rm zipfile_path if File.exist? zipfile_path
    archives = FileList['artifacts/*.tgz']
    locks = FileList['artifacts/*.lock.json']
    input_filenames = archives.concat locks
    input_filenames << 'rakefile'
    input_filenames << 'VERSION'
    Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, filename)
      end
    end
  end
end

task :deploy, [:policy_group] do |_t, args|
  raise 'A policy group is required' if args[:policy_group].nil?
  Dir.glob('artifacts/*-*.tgz').each do |archive|
    sh "chef push-archive #{args[:policy_group]} #{archive}"
  end
end
