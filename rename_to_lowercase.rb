
# This script will lowercase the name of all files in the
# directory that is passed as a command line argument.
# The given directory must be an absolute path.

# Example execution:
# $ ruby rename_to_lowercase.rb "/Users/sealocal/documents"
#
# Example output:
# "eBay's Guide to Making McMillions.pdf" => "ebay's guide to making mcmillions.pdf"
#
require 'fileutils'

dir = ARGV[0]

Dir.chdir(dir)

Dir.foreach(dir) do |file_name|
  old_name = file_name
  new_name = old_name.downcase
  if !File.directory? old_name
    File.rename( old_name, new_name )
  end
end

