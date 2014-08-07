require 'fileutils'

state_name = ARGV[0]
src_dir = '/Users/Home/rails_projects/tide_data_rails/app/xml/2013/'
dest_dir = '/Users/Home/rails_projects/tide_data_rails/app/xml/2014/'

Dir.foreach(src_dir) do |state_name|
  src = src_dir + state_name + '/regions'
  dest = dest_dir + state_name + '/regions'

  if state_name != "." && state_name != ".." && state_name != ".DS_Store"
    FileUtils.mkdir_p dest
    FileUtils.copy_entry src, dest, :force => true, :verbose => true
  end
end
