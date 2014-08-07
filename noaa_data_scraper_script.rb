require "json"
require "selenium-webdriver"
TIME_IN_SECONDS = 10
NOAA_FOLDER = "/Users/Home/Downloads/noaa_tide_predictions_xml_2014/"
FIRST_REGION = 2                        #Zero-based index corresponding to list below - for looping
LAST_REGION = 2                         #Zero-based index corresponding to list below - for looping
FIRST_STATE = 3                         #Zero-based index corresponding to list below - for looping
LAST_STATE = 3                          #Zero-based index corresponding to list below - for looping
FIRST_STATION = 475                     #Zero-based index.  Should always be zero, unless script fails in middle of station loop.


#=============================================================================================================================#
#=======East Coast (REGION = 0)==============#    #=======Gulf Coast (REGION = 1)=============================================#
# INDEX    STATE           DOWNLOADED        #      INDEX   STATE           DOWNLOADED                                        #
#   0      Maine           (105 out of 105)  #      #0      Alabama         (15 out of 15)                                    #
#   1      New Hamphsire   (13 out of 13)    #      #1      Mississippi     (18 out of 18)                                    #
#   2      Massachusetts   (84 out of 84)    #      #2      Louisiana       (61 out of 61)                                    #
#   3      Rhode Island    (32 out of 32)    #      #3      Texas           (38 out of 38)                                    #
#   4      Connecticut     (40 out of 40)    #                                                                                #
#   5      New York        (143 out of 143)  #      #=======West Coast (REGION = 2)===========================================#
#   6      New Jersey      (132 out of 132)  #      INDEX   STATE           DOWNLOADED                                        #
#   7      Delaware        (37 out of 37)    #      #0      California      (203 out of 204) #50 did not download             #
#   8      Pennsylvania    (29 out of 29)    #      #1      Oregon          (32 out of 32)                                    #
#   9      Maryland        (98 out of 98)    #      #2      Washington      (168 out of 168)                                  #
#   10     Virginia        (105 out of 105)  #      #3      Alaska          (525 out of 531) #469 thru #474 did not download  #
#   11     Washington DC   (28 out of 28)    #                                                                                #
#   12     North Carolina  (68 out of 68)    #                                                                                #
#   13     South Carolina  (248 out of 248)  #                                                                                #
#   14     Georgia         (98   out of 98)  #                                                                                #
#   15     Florida         (487  out of 487) #                                                                                #
#=============================================================================================================================#

start_time = Time.now

#Tweaking profile preferences
#For a list of prefs, see:
#http://src.chromium.org/svn/trunk/src/chrome/common/pref_names.cc
#Using chromedriver 2 (supported since selenium-webdriver 2.37):
prefs = {
  :download => {
    :prompt_for_download => false,
    :default_directory => NOAA_FOLDER
  }
}

def setup(prefs)
  @driver = Selenium::WebDriver.for :chrome, :switches => %w[--disable-improved-download-protection], :prefs => prefs
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

#This method finds the download buttons and clicks the button with value="Annual XML" using and index of 2 for the download_buttons array.
#Actual Button HTML:
#<input name="datatype" value="Annual PDF" class="noaatidebutton" ... style="cursor:hand;position:relative;" size="2" type="submit">
#<input name="datatype" value="Annual TXT" class="noaatidebutton" ... style="cursor:hand;position:relative;" size="2" type="submit">
#<input name="datatype" value="Annual XML" class="noaatidebutton" ... style="cursor:hand;position:relative;" size="2" type="submit">
def download_annual_xml
  #Find the buttons
  download_buttons = @driver.find_elements(:css, "table tr input.noaatidebutton")

  #Check for and clear the ForeSee dialog.
  foresee_check

  #Click the third download button (i.e. value="Annual XML")
  download_buttons[2].click

  #Wait for TIME_IN_SECONDS so that the XML link has time to run and download the file.
  sleep(TIME_IN_SECONDS)
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
  puts "Here are each of the East Coast states:"
  east_coast_links.each {|link_element| puts link_element.text}
  puts "Here are each of the Gulf Coast states:"
  gulf_coast_links.each {|link_element| puts link_element.text}
  puts "Here are each of the West Coast states:"
  west_coast_links.each {|link_element| puts link_element.text}
  puts "Here are each of the Pacific states:"
  pacific_links.each {|link_element| puts link_element.text}
  puts "Here are each of the Caribbean states:"
  caribbean_links.each {|link_element| puts link_element.text}
  #==========================================================================================
end

all_state_names = []
regions_and_states_jagged_array = []
while all_state_names.size != 39
  #Open Chrome
  setup(prefs)
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
total_number_of_stations_clicked = 0

#The outer each iterator loops through each of the five regions======================================================================
(FIRST_REGION .. LAST_REGION).each do |region_index|
  STDERR.puts "Loop status: @main_table[region_index]: #{@main_table[region_index]}"

  state_names = regions_and_states_jagged_array[region_index]
  (FIRST_STATE .. LAST_STATE).each do |state_index|
    #Set the download subdirectory
    prefs[:download][:default_directory] = NOAA_FOLDER + state_names[state_index]
    #Open Chrome
    setup(prefs)
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
    state_number += 1

    #Navigate to the state by clicking on the name of the state.
    puts "BEGIN STATE ##{state_number}:"
    puts "    The page title is: #{@driver.title}."
    puts "    I will click on #{state_name}."

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
    puts "    Save to: #{prefs[:download][:default_directory]}"

    #Find the <a> link elements corresponding to each station name
    station_links = @driver.find_elements(:xpath, "/html/body/div[4]/div[1]/div/div/div[2]/div[2]/table/tbody/tr/td/a")
    number_of_stations_found = 0
    #The station_links array is passed to an each iterator.
    #Each station_name and station_number is printed and the corresponding
    #station_links[station_index] element is clicked.
    (FIRST_STATION .. station_links.size - 1).each do |station_index|
      if number_of_stations_found < station_links.size
        number_of_stations_found = station_links.size
      end

      begin
        station_name = station_links[station_index].text
        station_number = 999999
        puts "        Begin station ##{station_number} (#{station_index + 1} out of #{station_links.size}): #{station_name}"
        #Get the station number (from the page title?).
        #station_number = @driver.title.substring(  ?   )
      rescue NoMethodError => e
        puts "There was a NoMethodError for station ##{station_number} out of #{station_links.size}."
        puts "#{e.class}: #{e.message}"
        puts "Let's try that again!"
        sleep(10)
        station_links = @driver.find_elements(:xpath, "/html/body/div[4]/div[1]/div/div/div[2]/div[2]/table/tbody/tr/td/a")
        retry
      rescue Exception => e
        puts "#{e.class}: #{e.message}"
      end

      begin
        station_links[station_index].click
      rescue Selenium::WebDriver::Error::ElementNotVisibleError => e
        #Check for the Foresee dialog, and clear it. Then, click the name of the station.
        puts "        The ForeSee dialog blocked my click!"
        puts "          Error type: #{e.class}"
        puts "          Error message: #{e.message}"
        foresee_check
        puts "         I cleared the ForeSee dialog! Let's keep going."
        retry
      rescue Selenium::WebDriver::Error::UnknownError => e
        #Check for the Foresee dialog, and clear it. Then, click the name of the station.
        puts "        The ForeSee dialog blocked my click!"
        puts "          Error type: #{e.class}"
        puts "          Error message: #{e.message}"
        foresee_check
        puts "         I cleared the ForeSee dialog! Let's keep going."
        retry
      end

      #===============================================================
      puts "        Station's page title: #{@driver.title}"
      #Find the buttons and download
      download_annual_xml
      puts "        End station   ##{station_number}: #{station_name}"
      #===============================================================

      total_number_of_stations_clicked += 1

      #Go back to the current state's page, which displays the station links
      @driver.navigate.back

      station_links = @driver.find_elements(:xpath, "/html/body/div[4]/div[1]/div/div/div[2]/div[2]/table/tbody/tr/td/a")
    end

    puts "END STATE ##{state_number}: #{state_name}: #{number_of_stations_found} stations were visited."

    #Navigate back to the main page
    #@driver.navigate.back
    #puts "        I went back to the main page."
    #sleep(3)

    #NO LONGER USED NOW THAT A NEW CHROME SESSION IS USED FOR EVERY ITERATION OF THE STATES LOOP
    #After navigating back to the main page, find the state links again with the concatenated version of the notation above.
    #This must be used inside the inner loop, or a StaleElementError will be thrown.
    #That is, the state_links array refers to elements that can be no longer referenced once navigating away from the main page.
    #state_links = @driver.find_elements(:xpath, "/html/body/div[4]/div[1]/div/div/div[2]/div[2]/table/tbody/tr/td")[region_index]
    #                     .find_elements(:css, "a")

    teardown
    sleep(10)
  end
end
#===================================================================================================================================


stop_time = Time.now

puts "Start time: #{start_time}"
puts "Stop time: #{stop_time}"
puts "Elapsed time: #{(stop_time - start_time)/60} minutes."


#Error Reports:

#Unavailable data:
#http://tidesandcurrents.noaa.gov/noaatidepredictions/NOAATidesFacade.jsp?Stationid=9413651




