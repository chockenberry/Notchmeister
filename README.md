# Notchmeister
Notches Gone Wild!

https://blog.iconfactory.com/2021/12/notches-gone-wild/

#### Building

First, clone the project.

```bash
git clone https://github.com/chockenberry/Notchmeister.git
```

You can locally override the Xcode settings for code signing
by creating a `DeveloperSettings.xcconfig` file locally at the appropriate path.
This allows for a pristine project with code signing set up with the appropriate
developer ID and certificates, and for developer to be able to have local settings
without needing to check in anything into source control.

You can do this in one of two ways: using the included `setup.sh` script or by creating the folder structure and file manually.

##### Using `setup.sh`

- Open Terminal and `cd` into the Notchmeister directory. 
- Run this command to ensure you have execution rights for the script: `chmod +x setup.sh`
- Execute the script with the following command: `./setup.sh` and complete the answers.
