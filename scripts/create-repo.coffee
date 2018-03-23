# Description:
#   Coffeescript to create and protect repo in GitHub.
#
# Notes:
#   This is a great example script of how to take input from chat tool
#   and start a more native script outside of coffeescript
#   This example shows taking a command, and starting a shell script
#   and pushing its output back to the chat tool

# Start the listener
module.exports = (robot) ->

  #####################################
  # LOOP Look for create_repo command #
  #####################################
  # Look for the create_repo command and take the input as the repo name
  robot.respond /create_repo (.*)/i, (msg) ->
    # initialize the arguements array so we can pass arguements to script
    args = []
    # Read in the regex and remove all whitespace
    reponame = msg.match[1].replace /^\s+|\s+$/g, ""
    # Check to see if the reponame has any space chars inside of it
    # We cannot create a repo with spaces!
    spaceIndex = reponame.indexOf " "
    if spaceIndex != -1
      msg.send "Repository names cannot have spaces"
    else
      # Repo has no spaces, we need to set the variables to pass to script
      # Pushing the values into the arguements array
      args.push(reponame)
      args.push(process.env.GITHUB_API_TOKEN)
      args.push(process.env.BOT_NAME)
      args.push(process.env.BOT_EMAIL)
      # Instantiate child process to be able to create a subprocess
      {spawn} = require 'child_process'
      # Create new subprocess and have it run the script
      # This will start the script and pass it the arguements we have set above
      # This is basically running the command: ./create-and-protect-repo.sh "reponame" "GITHUB_API_TOKEN" "BOT_NAME" "BOT_EMAIL"
      cmd = spawn('/home/site/wwwroot/scripts/shell/create-and-protect-repo.sh', args)
      # Catch stdout and output into hubot's log
      cmd.stdout.on 'data', (data) ->
        # Print all output from the script running into the chat tool
        msg.send "```\n#{data.toString()}\n```"
        console.log data.toString().trim()
      # Catch stderr and output into hubot's log
      cmd.stderr.on 'data', (data) ->
        # Print all output from the script running into the chat tool
        console.log data.toString().trim()
        msg.send "```\n#{data.toString()}\n```"
