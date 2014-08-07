# The purpose of this script is to visit each state on the NOAA Tide Predictions page,
# then collect names of groups so that xml files can be created for looking up
# regions and their related locations.

require 'json'
require 'selenium-webdriver'
require 'nokogiri'
require 'open-uri'
TIME_IN_SECONDS = 10
NOAA_FOLDER = "/Users/Home/Downloads/noaa_tide_predictions_xml_2014/"
FIRST_REGION = 0      #Zero-based index corresponding to list below - for looping
LAST_REGION = 0       #Zero-based index corresponding to list below - for looping
FIRST_STATE = 7       #Zero-based index corresponding to list below - for looping
LAST_STATE = 15       #Zero-based index corresponding to list below - for looping
FIRST_STATION = 0


# Visit the states page:

#=======East Coast (REGION = 0)===#==========Gulf Coast (REGION = 1)===#
# INDEX    STATE                  #  INDEX   STATE                     #
#   0      Maine                  #  #0      Alabama                   #
#   1      New Hamphsire          #  #1      Mississippi               #
#   2      Massachusetts          #  #2      Louisiana                 #
#   3      Rhode Island           #  #3      Texas                     #
#   4      Connecticut            #                                    #
#   5      New York               #==========West Coast (REGION = 2)===#
#   6      New Jersey             #  INDEX   STATE                     #
#   7      Delaware               #  #0      California                #
#   8      Pennsylvania           #  #1      Oregon                    #
#   9      Maryland               #  #2      Washington                #
#   10     Virginia               #  #3      Alaska                    #
#   11     Washington DC          #                                    #
#   12     North Carolina         #                                    #
#   13     South Carolina         #                                    #
#   14     Georgia                #                                    #
#   15     Florida                #                                    #
#======================================================================#

start_time = Time.now

def setup
  @driver = Selenium::WebDriver.for :chrome
  @base_url = "http://tidesandcurrents.noaa.gov/tide_predictions.html"
  @accept_next_alert = false
  @driver.manage.timeouts.implicit_wait = 30
  @verification_errors = []
end

def element_present?(how, what)
  @driver.find_element(how, what)
  true
rescue Selenium::WebDriver::Error::NoSuchElementError
  false
end

#This method checks for the ForeSee Survey JavaScript pop-up.
#If the method finds the pop-up, it clicks the "No, Thanks" button.
#<div id="fsrOverlay" class="fsrC" style="font-size: 12px; visibility: visible; display: block; width: 1050px; height: 658px; top: 0px; left: 0px;">...</div>
def foresee_check
  if element_present?(:css, "#fsrOverlay")
    puts "        I found the foresee dialog."
    no_thanks_button = @driver.find_element(:link_text, "No, thanks")
    puts "        I found the 'No, Thanks' button."
    no_thanks_button.click
    puts "        I just clicked the 'No, thanks' button."
  end
end

def teardown
  @driver.quit
end

# =================== #
# Informal Test Suite #
# =================== #

#This tests that the @main_table is still accessible by the xpath=====================================================
def test_no_changes_in_noaa_list_of_regions
  @main_table = @driver.find_elements(:xpath, "/html/body/div[4]/div[1]/div/div/div[2]/div[2]/table/tbody/tr/td")
  puts "I found the main table."

  @east_coast_table = @main_table[0]
  @gulf_coast_table = @main_table[1]
  @west_coast_table = @main_table[2]
  @pacific_table    = @main_table[3]
  @caribbean_table  = @main_table[4]
  puts "I found five <td>'s of the table, assumed to be: East, Gulf, West, Pacific, Caribbean."
end
#====================================================================================================================

def test_each_link_corresponds_to_a_state_name
  #Print out each of the state names, to see if we're finding the right links ==============
  east_coast_links  = @east_coast_table.find_elements(:css, "a")
  gulf_coast_links  = @gulf_coast_table.find_elements(:css, "a")
  west_coast_links  = @west_coast_table.find_elements(:css, "a")
  pacific_links     = @pacific_table.find_elements(:css, "a")
  caribbean_links   = @caribbean_table.find_elements(:css, "a")
  #==========================================================================================
end

all_state_names = []
regions_and_states_jagged_array = []
while all_state_names.size != 39
  #Open Chrome
  setup
  #Start off from the main page, displaying the @main_table.
  @driver.get(@base_url)
  #Check :xpath selectors
  test_no_changes_in_noaa_list_of_regions
  #Check state names found by the :css selector
  test_each_link_corresponds_to_a_state_name

  #===========================================================================
  regions_and_states_jagged_array[0] = @east_coast_table.text.split("\n") - [@east_coast_table.text.split("\n")[0]]
  regions_and_states_jagged_array[1] = @gulf_coast_table.text.split("\n") - [@gulf_coast_table.text.split("\n")[0]]
  regions_and_states_jagged_array[2] = @west_coast_table.text.split("\n") - [@west_coast_table.text.split("\n")[0]]
  regions_and_states_jagged_array[3] = @pacific_table.text.split("\n")    - [@pacific_table.text.split("\n")[0]]
  regions_and_states_jagged_array[4] = @caribbean_table.text.split("\n")  - [@caribbean_table.text.split("\n")[0]]
  #===========================================================================

  #This collects all of the state names into a single array ==================
  all_state_names += @east_coast_table.text.split("\n") - [@east_coast_table.text.split("\n")[0]]
  all_state_names += @gulf_coast_table.text.split("\n") - [@gulf_coast_table.text.split("\n")[0]]
  all_state_names += @west_coast_table.text.split("\n") - [@west_coast_table.text.split("\n")[0]]
  all_state_names += @pacific_table.text.split("\n")    - [@pacific_table.text.split("\n")[0]]
  all_state_names += @caribbean_table.text.split("\n")  - [@caribbean_table.text.split("\n")[0]]
  #===========================================================================

  teardown
end

state_number = FIRST_STATE

#The outer each iterator loops through each of the five regions======================================================================
(FIRST_REGION .. LAST_REGION).each do |region_index|

  STDERR.print "Looping through the "
  case region_index
  when 0
    STDERR.print "East Coast"
  when 1
    STDERR.print "Gulf Coast"
  when 2
    STDERR.print "West Coast"
  when 3
    STDERR.print "Pacific"
  when 4
    STDERR.print "Caribbean"
  else
    STDERR.print "This should not be the case!"
  end
  STDERR.puts " states."


  state_names = regions_and_states_jagged_array[region_index]
  (FIRST_STATE .. LAST_STATE).each do |state_index|
    #Open Chrome
    setup
    #Start off from the main page, displaying the @main_table.
    @driver.get(@base_url)

    #Find the main table, and the next region table, and then the <a> links for the region.
    @main_table = @driver.find_elements(:xpath, "/html/body/div[4]/div[1]/div/div/div[2]/div[2]/table/tbody/tr/td")
    region_table = @main_table[region_index]
    state_links = region_table.find_elements(:css, "a")

    total_states = 0
    fixes = 0
    while total_states != 39 && fixes < 10
      (0 .. 4).each do |i|
        total_states += @main_table[i].find_elements(:css, "a").size
      end
      break if total_states == 39
      puts "Fix the state_links array!"
      state_links = region_table.find_elements(:css, "a")
      fixes += 1
    end

    state_name = state_links[state_index].text
    state_href = state_links[state_index].attribute("href")
    state_number += 1

    #Navigate to the state by clicking on the name of the state.
    puts "BEGIN STATE ##{state_number}:"
    puts "    The page title is: #{@driver.title}."
    puts "    I will click on #{state_name} via href = #{state_href}"

    begin
      state_links[state_index].click
    rescue Selenium::WebDriver::Error::UnknownError => e
      #Check for the Foresee dialog, and clear it. Then, click the name of the state.
      puts "    The ForeSee dialog blocked my click!"
      puts "      Error type: #{e.class}"
      puts "      Error message: #{e.message}"
      foresee_check
      puts "      I cleared the ForeSee dialog! Let's keep going."
      retry
    end
    puts "    I clicked on #{state_name} and the page title is: '#{@driver.title}'."
    foresee_check

    Dir.mkdir("./states") if !Dir.exist?("./states/")
    Dir.mkdir("./states/" + state_name) if !Dir.exist?("./states/" + state_name)
    Dir.chdir("./states/" + state_name) do
      html_doc = Nokogiri::HTML(open(state_href))
      table = html_doc.xpath('//table/tr/td[1]')

      STDERR.puts "Processing nodes... "

      region_number = 0
      sub_region_number = 0
      table.each_with_index do |node, index|
        STDERR.puts "Start:  Node ##{index} | #{node.name} | #{node['id']} | #{node['name']} | #{node['class']} | #{node.text}"
        if node['class'] == 'grphdr1'
          node.name = 'REGION'
          region_number += 1
          node['id'] = "region-#{region_number}"
          node['name'] = node.text.gsub('&nbsp', '').strip
          node.content = nil
        end

        if node['class'] == 'grphdr2'
          node.name = 'SUB_REGION'
          sub_region_number += 1
          node['id'] = "sub_region-#{sub_region_number}"
        end

        if node['class'] == 'stationname'
          node.name = 'LOCATION'
          node['class'] += " region-#{region_number}"
          node['class'] += " sub_region-#{sub_region_number}" unless sub_region_number == 0
          node.content = node.css('a').text
        end
        STDERR.puts "Finish: Node ##{index} | #{node.name} | #{node['id']} | #{node['name']} | #{node['class']} | #{node.text}"
      end

      STDERR.puts "... finished."
      STDERR.puts "Saving to region files... "


      table.each do |node|
        if node.name == 'REGION'
          STDERR.puts "    Create #{node['name']}.xml file ..."
          matching_region_class = node['id'].split.last
          file_content = node
          file_content << table.css("LOCATION.#{matching_region_class}")

          f = File.new("#{node['name']}.xml", "w")
          f.puts('<?xml version="1.0" encoding="ISO-8859-1" ?>')
          f.puts file_content
          f.close
          STDERR.puts "    ... saved file."
        end
      end

      file_content = table.css("LOCATION.region-0")
      if file_content.size > 0
        STDERR.puts "    Create #{state_name}.xml file ..."
        f = File.new("#{state_name}.xml", "w")
        f.puts('<?xml version="1.0" encoding="ISO-8859-1" ?>')
        f.puts('<REGION name="' + state_name + '">')
        f.puts file_content
        f.puts('</REGION>')
        f.close
        STDERR.puts "    ... saved file."
      end

      STDERR.puts "... finished."
    end

    teardown
    sleep(10)
  end
end
#===================================================================================================================================

stop_time = Time.now

puts "Start time: #{start_time}"
puts "Stop time: #{stop_time}"
puts "Elapsed time: #{(stop_time - start_time)/60} minutes."








