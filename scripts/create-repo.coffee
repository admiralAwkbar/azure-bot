module.exports = (robot) ->


  ########
  # LOOP #
  ########
  robot.respond /create_repo (.*)/i, (msg) ->
    args = []
    reponame = msg.match[1].replace /^\s+|\s+$/g, ""
    spaceIndex = reponame.indexOf " "
    if spaceIndex != -1
      msg.send "Repository names cannot have spaces"
    else
      apikey = process.env.GITHUB_API_TOKEN

      console.log "apikey = #{apikey}"

      args.push(reponame + " " + apikey)
      # Instantiate child process to be able to create a subprocess
      {spawn} = require 'child_process'
      # Create new subprocess and have it run the script
      cmd = spawn("/home/site/wwwroot/scripts/shell/create-and-protect-repo.sh #{reponame} #{apikey}")
      # Catch stdout and output into hubot's log
      cmd.stdout.on 'data', (data) ->
        msg.send "```\n#{data.toString()}\n```"
        console.log data.toString().trim()
      # Catch stderr and output into hubot's log
      cmd.stderr.on 'data', (data) ->
        console.log data.toString().trim()
        msg.send "```\n#{data.toString()}\n```"
