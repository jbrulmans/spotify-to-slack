# spotify-to-slack

A script that shows your spotify song playing to your slack status via a MacOS Launch Agent based on [jgamblin](https://gist.github.com/jgamblin)'s code snippet.

## Usage

The script is meant to be run as a daemon with the MacOS Launch Agent so it can be run with an interval. The script will periodically check if Spotify is playing a song or not and if it is, report it to the Slack API as a Slack status. If it's not playing anything anymore, it will automatically report an empty status again to Slack.

## Installation

### 1. **perl** setup

Run the following commands in order to install the `perl` requisites

```bash
perl -MCPAN -e shell
```

```perl
install URI::Escape
```

Then exit out of `perl`

```perl
exit
```

### 2. Permissions

Make sure the script and the directory have the necessary permissions to run.

```bash
chmod -R 755 spotify-to-slack/
```

### 3. Setting the necessary variables

Set the `APIKEY` and `EMOJI` variables in the `spotify-to-slack.sh` script.

For `APIKEY`, you can use an old *legacy* slack token that you might still have generated [here](https://api.slack.com/legacy/custom-integrations/legacy-tokens). Otherwise you will need to generate a new Slack API token via a new Slack app [here](https://api.slack.com/apps).

For `EMOJI`, you can use whatever emoji is available on slack **or** on your custom slack environment. Just simply enter the slack emoji name without the leading and trailing `:`. E.g. the default emoji is `"headphones"` (🎧).

Now if you run the script with

```bash
sh spotify-to-slack.sh
```

it should set your current song playing as your slack status (only once for now though)



### 4. Set up launch agent

You can have this run automatically on your mac using the native launchd system:

Drop the following `plist` into `~/Library/LaunchAgents/com.user.spotify-to-slack.plist`. The filename must match the string under Label, replace `/PATH/TO/SCRIPT.sh` with an actual path to the .sh script above.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.user.spotify-to-slack</string>
        <key>ProgramArguments</key>
        <array>
            <string>/Users/jbrulmans/src/spotify-to-slack/spotify-to-slack.sh</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>StartInterval</key>
        <integer>60</integer>
        <key>StandardErrorPath</key>
        <string>/Users/jbrulmans/src/spotify-to-slack/.logs/error.log</string>
        <key>StandardOutPath</key>
        <string>/Users/jbrulmans/src/spotify-to-slack/.logs/output.log</string>
    </dict>
</plist>
```

Then, register this daemon with launchd by running:

```bash
launchctl load ~/Library/LaunchAgents/com.user.spotify-to-slack.plist
```

Start it by either logging out and back in or running:

```bash
launchctl start com.user.spotify-to-slack
```

Finally, make sure the status of the loaded agent is `0`. If it show any different number, look up the error code and check what might have gone wrong.

```bash
$ launchctl list | grep 'com.user.spotify-to-slack'
-	0	com.user.slack-spotify
```

## Run the script **without** Launch Control

