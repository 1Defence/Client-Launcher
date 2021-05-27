# Client Launcher
Launch multiple accounts with their own ***unique settings files*** on RuneLite by running a single script<br/><br/>
This script builds on the base funcitonality runelite provides allowing you to pass seperate settings files to individual clients<br/>
With this launcher you can have different launchers for varying situations without needing to create 100 shortcuts/settings files manually.

https://user-images.githubusercontent.com/63735241/119376192-ae8dc480-bc89-11eb-844d-0ffd2c55ad99.mp4

# Requirements
* AHK Can be downloaded here : https://autohotkey.com/download/
* Remember client position setting ![image](https://user-images.githubusercontent.com/63735241/119899297-f1ad9900-bf10-11eb-90a7-09d7bcac65b9.png)
* Keep file hierarchy the same, some AHK scripts interact with eachother, functionality will be lost if files are moved; use the Buttons or Launcher Utilites script or shortcuts if you wish to access certain files easier.
* See [Known Issues](#known-issues)

# Download
![image](https://user-images.githubusercontent.com/63735241/119900454-8b297a80-bf12-11eb-9426-f20035bc15b2.png)
![image](https://user-images.githubusercontent.com/63735241/119900867-173ba200-bf13-11eb-995b-a6f616cbf318.png)


# Creating a launcher

Run ***Launcher Creator.ahk*** and follow the steps<br/>
* Choose the **name** of your Launcher<br/>
* Choose the **number** of clients you desire the launcher to run<br/>
* Choose the **base settings** location<br/>
If you play logged into the cloud, your settings location differs (%userprofile%/.runelite/profiles/EMAIL_NAME/settings.properties)<br/>
*Otherwise, select no*<br/>
By default if you select no leave the next input blank and you're finished.<br/><br/>
If you wish to use a different base settings file from a pre-existing launcher rather than leaving the input blank, input the name of the file and the program will find the path.<br/>
**Example:** you have a Bandos settings file you want to base off, you'd enter Bandos_1 or Bandos_2 etc and it would search for Settings_Bandos2 and use that as the base file.
	
https://user-images.githubusercontent.com/63735241/119378843-b6029d00-bc8c-11eb-9d55-cf9d3a7b923f.mp4

# Running a launcher
* Launchers are saved in the Launcher folder, simply run the launcher you've created<br/>
* On first run, settings files are created and all clients will be in the same location with the same base settings<br/>
* Simply move them change the settings as you see fit and they'll each save to their own settings files<br/>
* Their settings files will be located at .runelite/Settings/LAUNCHERNAME<br/>
* **Example:** file name is *Bandos*, client count is *2*<br/> at *%userprofile%/.runelite/settings/Bandos/* there will be two files ; *Settings_Bandos1.properties*,*Settings_Bandos2.properties*<br/>

# Changing the location of your client
Run ***Set Client Path.ahk*** and browse for the RuneLite(.jar/.exe) file, the expected location below
	
	%localappdata%\RuneLite

https://user-images.githubusercontent.com/63735241/119897914-17d23980-bf0f-11eb-86e3-e9870c41aa45.mp4

# Changing the location of your .runelite
Run ***Set Settings Path.ahk*** and browse for the .runelite folder, the expected location below
	
	%userprofile%\.runelite

https://user-images.githubusercontent.com/63735241/119897949-23bdfb80-bf0f-11eb-961b-9b6cc3824725.mp4

# Renaming an existing Launcher
Run ***Rename Launcher.ahk*** and browse the Launchers folder for the file you wish to rename
	
https://user-images.githubusercontent.com/63735241/119898452-ddb56780-bf0f-11eb-88a4-4dcddff237b0.mp4

# Deleting an existing Launcher
Run ***Delete Launcher.ahk*** and browse the Launchers folder for the file you wish to delete
	
https://user-images.githubusercontent.com/63735241/119898515-f45bbe80-bf0f-11eb-90c7-804365bd24b0.mp4

# Known Issues
* Upon running the client it seems like settings didn't save because a client appears in the center
This is a RL issue, out of bounds clients are set to the center, avoid moving clients partially off screen to prevent this.
* Logging in via cloud/email won't have the intended behaviour as a logged in file will only use the one settings file, you cannot be logged in and have this functionality, you can however take your log-in files settings you just won't be able to take advantage of the shared loot tracker.
If you do choose to login, that one account will only ever have its logged-in settings and ignore the custom settings file.
