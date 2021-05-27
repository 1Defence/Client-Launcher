# Launcher
Launch multiple accounts with their own settings files on RuneLite, you can do this normally with RuneLite by creating shortcuts with params but this is more for users who wish to have multiple different set-ups of account settings
E.G you can have different client setups specifically for each boss if you use a lot of alts.

# Setting the location of your client
**Run "Set Client Path.ahk" and browse for the RuneLite(.jar/.exe) file, the expected location below**
	
	%localappdata%\RuneLite
	

https://user-images.githubusercontent.com/63735241/118590762-12d3f400-b771-11eb-9e05-e84308a3cebc.mp4

# Setting the location of your .runelite
**Run "Set Settings Path.ahk" and browse for the .runelite folder, the expected location below**
	
	%userprofile%\.runelite

https://user-images.githubusercontent.com/63735241/118584267-9a673600-b764-11eb-85f9-41cfda14f611.mp4

# Creating a launcher

	Run "Launcher Creator.ahk" and follow the steps
	1. Choose the name of your Launcher
	2. Choose the number of clients you desire the launcher to run
	3. Optionally, select a settings file that your clients will be based off of prior to your changes
	By default all new settings files will be based off your original "settings.properties" file
	On the last step when asked for a file if you enter a specific properties file the specified file will be used as the base
	Simply enter nothing on the last step if you wish to use your standard settings file as the base
	
	
https://user-images.githubusercontent.com/63735241/118585022-1615b280-b766-11eb-9711-da70b21036ba.mp4

# Running a launcher

	Launchers are saved in the Launcher folder, simply run the launcher you've created
	On first run, settings files are created and all clients will be in the same location with the same base settings
	Simply move them change the settings as you see fit and they'll each save to their own settings files.
	Their settings files will be located at .runelite/Settings/LAUNCHERNAME;
	Example, file name is "Bandos", client count is 2;
	At ".runelite/Settings/Bandos/" There will be a "Settings_Bandos1.properties","Settings_Bandos2.properties"
	

https://user-images.githubusercontent.com/63735241/118586909-95f14c00-b769-11eb-905e-55b1668e5ec4.mp4

# Known Issues
	Upon running the client it seems like settings didn't save because a client appears in the center
	This is a RL issue, out of bounds clients are set to the center, avoid moving clients partially off screen to prevent this.
