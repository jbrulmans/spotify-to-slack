#!/bin/bash

# Get this token by:
# - Creating a Slack app https://api.slack.com/apps
# - Select Permissions > Scopes > User Token Scopes and add `users.profile:write`
# - Scroll up and select Install to Workspace under OAuth Tokens for Your Workspace
# - Copy User OAuth Token under OAuth Tokens for Your Workspace
TOKEN=""
EMOJI=":headphones:"
trap onexit INT

function reset() {
    echo 'Clearing status'
    JSON=$(echo '{}' | jq '.profile.status_text="" | .profile.status_emoji=""')
    curl -X POST --data "$JSON" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json; charset=utf-8" --silent -o /dev/null https://slack.com/api/users.profile.set | jq 'del(.profile)'
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
    SONG=$(osascript -e 'tell application "Spotify" to name of current track')
    ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track')
    echo $ARTIST - $SONG

    JSON=$(echo '{}' | jq --arg SONG "$SONG" --arg ARTIST "$ARTIST" --arg EMOJI "$EMOJI" '.profile.status_text=$ARTIST+" - "+$SONG | .profile.status_emoji=$EMOJI')


    curl -X POST --data "$JSON" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json; charset=utf-8" --silent -o /dev/null https://slack.com/api/users.profile.set | jq 'del(.profile)'
fi
