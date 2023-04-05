#!/bin/bash

APIKEY="From Here https://api.slack.com/custom-integrations/legacy-tokens"
EMOJI="headphones"
trap onexit INT

function reset() {
    echo 'Clearing status'
    curl -s -d "payload=$json" "https://slack.com/api/users.profile.set?token="$APIKEY"&profile=%7B%22status_text%22%3A%22%22%2C%22status_emoji%22%3A%22%22%7D"
}

function onexit() {
    echo 'Exitting'
    reset
    exit
}


state=$(osascript -e 'tell application "Spotify" to player state')

date
echo "Spotify: "$state

if [[ "$state" != "playing" ]]; then
    reset
else
    SONG=$(osascript -e 'tell application "Spotify" to artist of current track & " - " & name of current track')
    URLSONG=$(echo "$SONG" | perl -MURI::Escape -ne 'chomp;print uri_escape($_),"\n"')
    echo $SONG

    curl -s -d "payload=$json" "https://slack.com/api/users.profile.set?token="$APIKEY"&profile=%7B%22status_text%22%3A%22"$URLSONG"%22%2C%22status_emoji%22%3A%22%3A$EMOJI%3A%22%7D"
fi