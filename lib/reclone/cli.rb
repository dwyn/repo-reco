require 'pathname'
# require 'git'

class Reclone::CLI
  @current_user = ""
  @current_user_repositories = []
  @clone_directory = ""

  def call
    exit unless up?
    log_in
    recloner   

    Octokit.auto_paginate = false
	end

  def up?
    Net::Ping::External.new("www.google.com").ping?
  end

  def directory_exists?(directory)
    Dir.exists?(directory)
  end

  def log_in
    # puts "Hello user"; sleep 1
    # puts "Please enter your user name."
    # username = gets.strip

    # puts "Awesome. Please enter your password."
    # user_password = gets.strip
    # # DO SOMETHING ABOUT BAD CREDENTIALS!!!
    # puts "Great. Now what directory would you like to clone to?"
    # puts "For example: /Users/user_name/user_repo_folder/"
    # @clone_directory = gets.strip

    client = Octokit::Client.new(:login: "dwyn", oauth_token: "dwyn@1618" )
    repos = client.repositories("dwyn", {sort: :pushed_at})
    binding.pry
    @current_user = client.user
    @current_user_repositories = repos
  end

# #repositories(user = nil, options = {}) ⇒ Array<Sawyer::Resource>
# Also known as: list_repositories, list_repos, repos

  
  def recloner
    ratelimit           = Octokit.ratelimit
    ratelimit_remaining = Octokit.rate_limit.remaining
    puts "Rate Limit Remaining: #{ratelimit_remaining} / #{ratelimit}"
    puts
    
    # temp_directory = ""
    repos = Octokit.repositories("dwyn", {sort: :pushed_at})
    binding.pry

    
    @current_user.all_repositories.each do |repository|

      temp_directory = "/Users/dwyn/Development/code/#{repository.name}"
      if directory_exists?(temp_directory)
        puts "The directory #{temp_directory} already exists"
        puts "...moving on"
        puts " "
        binding.pry
      else
        puts "#{repository.name} Cloned!" if Git.clone(repository.clone_url, repository.name, :path => temp_directory )
        # Git.clone(URI, NAME, :path => '/tmp/checkout') I cant believe even left myself an example!!!
      end 
      full_name = repository[:full_name]
      has_push_access = repository[:permissions][:push]
    
      access_type = if has_push_access
          "write"
        else
          "read-only"
        end

        # binding.pry

      puts "User has #{access_type} access to #{full_name}."
    end
    
    puts "good bye"

  end

end




# def clone(repository, name, opts = {})
# @path = opts[:path] || '.'
# clone_dir = opts[:path] ? File.join(@path, name) : name

# arr_opts = []
# arr_opts << "--bare" if opts[:bare]
# arr_opts << "-o" << opts[:remote] if opts[:remote]
# arr_opts << "--depth" << opts[:depth].to_i if opts[:depth] && opts[:depth].to_i > 0

# arr_opts << '--'
# arr_opts << repository
# arr_opts << clone_dir

# command('clone', arr_opts)

# opts[:bare] ? {:repository => clone_dir} : {:working_directory => clone_dir}
# end