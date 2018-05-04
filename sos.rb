class SOS

  require 'nokogiri'
  require 'selenium-webdriver'
  require 'simple-spreadsheet'
  #require 'C:\Ruby25-x64\CommonFunctions'
  driver = Selenium::WebDriver.for :chrome
  #driver.manage.timeouts.implicit_wait = 20
  #driver.manage.window.maximize
  #comment
  driver.get ("https://dev.surgicaloutcomesystem.com/portal/sessions/new")
  cf = CommonFunctions.new

  if cf.isElementPresent(driver,:xpath, cf.Obj("Login","Email","Value")) == true
    driver.find_element(:xpath, cf.Obj("Login","Email","Value")).send_keys("automation.assistant@mail.com")
    driver.find_element(:xpath, cf.Obj("Login","Password","Value")).send_keys("Password@2")
    driver.find_element(:xpath, cf.Obj("Login","Login","Value")).click
    sleep(1)
  end
  NoofPatients = 1
  for currentPatientNumber in 1..NoofPatients
    driver.find_element(:xpath, cf.Obj("Home","PatientsLink","Value")).click
    driver.find_element(:xpath, cf.Obj("Patients","EnrollPatient","Value")).click
    patientID = cf.TestData("Custom ID") + rand(100).to_s
    driver.find_element(:xpath, cf.Obj("New Patient","CustomID","Value")).send_keys ( patientID )
    myElement = driver.find_element(:xpath, cf.Obj("New Patient","Surgeon","Value"))
    if myElement.attribute("text") == "Automation Surgeon"
      puts "Default value is " + myElement.attribute("text")
    end
    parentElement = myElement.find_element(:xpath, '..')
    if parentElement.attribute("disabled") == "true"
      puts "Surgeon is disabled"
    else
      puts "Surgeon is enabled"
    end
    driver.find_element(:xpath, cf.Obj("New Patient","Email","Value")).send_keys (cf.TestData("Email"))
    driver.find_element(:xpath, cf.Obj("New Patient","Cell Phone","Value")).send_keys (cf.TestData("Cell Phone"))
    driver.find_element(:xpath, cf.Obj("New Patient","Date of Birth","Value")).click
    driver.find_element(:xpath, cf.Obj("New Patient","Date of Birth","Value")).send_keys (cf.TestData("Date of Birth"))
    Gender = driver.find_element(:xpath, cf.Obj("New Patient","Gender","Value"))
    GenderOptions = Gender.find_elements(:tag_name,"option")
    GenderOptions.each {|options|options.click if options.text == cf.TestData("Gender")}

    driver.find_element(:xpath, cf.Obj("New Patient","Race","Value")).click
    driver.find_element(:xpath, cf.Obj("New Patient","Race","Value")).send_keys (cf.TestData("Race"))
    sleep(2)
    if cf.isElementPresent(driver,:xpath, cf.Obj("New Patient","RaceOption","Value")) == true
      driver.find_element(:xpath, cf.Obj("New Patient","RaceOption","Value")).click
      sleep(2)
    end

    driver.find_element(:xpath, cf.Obj("New Patient","Ethnicity","Value")).send_keys (cf.TestData("Ethnicity"))
    driver.find_element(:xpath, cf.Obj("New Patient","Save Changes","Value")).click
    sleep(2)

    while cf.isElementPresent(driver, :xpath, cf.Obj("New Patient","Error Message","Value")) == true
      CustomIDField = driver.find_element(:xpath, cf.Obj("New Patient","CustomID","Value"))
      CustomIDField.clear
      patientID = cf.TestData("Custom ID") + rand(10000).to_s
      CustomIDField.send_keys ( patientID )
      driver.find_element(:xpath, cf.Obj("New Patient","Save Changes","Value")).click
      sleep(2)
    end

    StudyModules = driver.find_element(:xpath, cf.Obj("New Event","Study Module","Value"))
    StudyModulesOptions = StudyModules.find_elements(:tag_name,"option")
    StudyModulesOptions.each {|options|options.click if options.text == cf.TestData("Study Module")}
    driver.find_element(:xpath, cf.Obj("New Event","EnrollPatient","Value")).click
    cf.DataRows("Catalog")
    TotalRows = cf.DataRows("Catalog")
    x = 2
    oldcatalog = ""
    oldcatalogItem = ""
    for x in 2..TotalRows
      rData = cf.RowData("Catalog",x).split(":")
      catalog = rData[0]
      catalogItem = rData[1]
      if oldcatalog != catalog
        driver.find_element(:xpath, cf.Obj("Surgery","Catalog","Value").sub("TEST_DATA",catalog)).click
      end
      if oldcatalogItem != catalogItem
        driver.find_element(:xpath, cf.Obj("Surgery","Catalog Item","Value").sub("TEST_DATA",catalogItem)).click
      end
      #puts rData[2] + " : " + rData[3]
      cf.updateFieldValues(driver, rData[2],rData[3])
      oldcatalog = catalog
      oldcatalogItem = catalogItem
    end
    sleep(1)
    urlSplit = driver.current_url.split("/")
    driver.find_element(:xpath, cf.Obj("Surgery","UpdateEvent","Value").sub("EventID",urlSplit.last())).click
    currentPatientNumber = currentPatientNumber + 1
    puts "Patient with ID " + patientID + " is created"
    sleep(3)
  end
  driver.find_element(:xpath, cf.Obj("Common","Settings","Value")).click
  driver.find_element(:xpath, cf.Obj("Common","LogOut","Value")).click
  sleep (3)
=begin
  driver.close
  driver.quit
=end
end
