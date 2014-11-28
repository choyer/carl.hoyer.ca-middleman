
# pretty urls
activate :directory_indexes

###
# Markdown
###
set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
               :tables => true,
               :fenced_code_blocks => true,
               :autolink => true,
               :smartypants => true


# build report               
activate :build_reporter

###
# Sync to AWS and Cloudfront
###
activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = 'carl.hoyer.ca' # The name of the S3 bucket you are targetting. This is globally unique.
  s3_sync.region                     = 'us-east-1'     # The AWS region for your bucket.
  s3_sync.aws_access_key_id          = ENV['AWS_ACCESS_KEY']
  s3_sync.aws_secret_access_key      = ENV['AWS_SECRET']
  s3_sync.delete                     = true # We delete stray files by default.
  s3_sync.after_build                = true # We chain after the build step by default. This may not be your desired behavior...
  s3_sync.prefer_gzip                = false
  s3_sync.path_style                 = true
  s3_sync.reduced_redundancy_storage = false
  s3_sync.acl                        = 'public-read'
  s3_sync.encryption                 = false
  s3_sync.prefix                     = ''
  s3_sync.version_bucket             = false
end

 activate :cloudfront do |cf|
   cf.access_key_id = ENV['AWS_ACCESS_KEY']
   cf.secret_access_key = ENV['AWS_SECRET']
   cf.distribution_id = 'EELN0AZN02QRE'
   cf.filter = /\.html$/i
 end

 after_s3_sync do |files_by_status|
   invalidate files_by_status[:updated]
 end

###
# Blog
###
activate :blog do |blog|
  blog.layout             = "article"
  blog.taglink            = "meta/:tag.html"
  blog.tag_template       = "tag.html"
  blog.year_template      = "calendar.html"
  blog.default_extension  = ".markdown"
end

###
# Code hilighting via pygments
###
activate :syntax,
         :css_class => "syntax-highlight"

###
# Compass
###

# Susy grids in Compass
# First: gem install compass-susy-plugin
# require 'susy'

compass_config do |config|
  config.output_style = :compact
end

###
# Page options, layouts, aliases and proxies
###

page "/index.html", :layout => "global"
page "404.html", :layout => false, directory_index: false
page "/sitemap.xml", :layout => "sitemap.xml"
page "/feed.rss", :layout => "feed.rss"
page "/atom.xml", :layout => "atom.xml"
#page "/atom.json", :proxy => "/json_articles.json", :layout => false, :ignore => true do
#  @atom_article = ''
#end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
#helpers do
#
#end

# specify asset directories
set :js_dir, 'js'
set :css_dir, 'css'
set :images_dir, 'img'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  #activate :asset_hash
end
