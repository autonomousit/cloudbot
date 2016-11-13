# Description:
#   Triggers a New Deployment in Azure via Powershell
#
# Commands:
#   hubot deploy <deploymentname> to <resourcegroup> - Deploys a pre-defined ARM Template in an Azure Resource Group

# Require the edge module
edge = require("edge")

# Build the PowerShell that will execute
executePowerShell = edge.func('ps', -> ###
  # Dot source the function
  . .\scripts\cloudbot-azuredeploy.ps1

  # Edge.js passes an object to PowerShell as a variable - $inputFromJS
  # This object is built in CoffeeScript on line 27 below
  New-CloudBotAzureDeployment -Template $inputFromJS.template -ResourceGroup $inputFromJS.resourceGroup -ServicePrincipal azure

###
)

module.exports = (robot) ->
  # Capture the user message using a regex capture
  # to find the name of the service
  robot.respond /deploy ([\w-]+) to ([\w-]+)/i, (msg) ->
    # Set the service name to a varaible
    template = msg.match[1]
    resourceGroup = msg.match[2]

    # Build an object to send to PowerShell
    psObject = {
      template: template,
      resourceGroup: resourceGroup,
    }

    # Build the PowerShell callback
    callPowerShell = (psObject, msg) ->
      executePowerShell psObject, (error,result) ->
        # If there are any errors that come from the CoffeeScript command
        if error
          msg.send ":fire: An error was thrown in Node.js/CoffeeScript"
          msg.send error
        else
          # Capture the PowerShell output and convert the
          # JSON that the function returned into a CoffeeScript object
          result = JSON.parse result[0]

          # Output the results into the Hubot log file so
          # we can see what happened - useful for troubleshooting
          console.log result

          # Check in our object if the command was a success
          # (checks the JSON returned from PowerShell)
          # If there is a success, prepend a check mark emoji
          # to the output from PowerShell.
          if result.Message is "Succeeded"
            # Build a string to send back to the channel and
            # include the output (this comes from the JSON output)
            msg.send ":beers: Deploying #{result.Template} to #{result.ResourceGroup} succeeded"
          # If there is a failure, prepend a warning emoji to
          # the output from PowerShell.
          else
            # Build a string to send back to the channel and
            #include the output (this comes from the JSON output)
            msg.send ":radioactive_sign: Deploying  #{result.DeploymentName} to #{result.ResourceGroup} failed. Provisioning State: #{result.Message}"

    # Acknowledge start of Deployment
    msg.send ":construction: Starting to deploy #{template} to #{resourceGroup}. This might take a while, I'll get back to you when it's done..."
    # Call PowerShell function
    callPowerShell psObject, msg
