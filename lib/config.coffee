prompt = require 'prompt'
Database = require './db'

class Config extends Database

  filesDelete: (callback) ->
    console.log '==> '.cyan.bold + 'remove all media files from mediatidy'

    # get files total to display to user
    @dbBulkFileGetAll (array) =>
      console.log array.length + " files currently in the mediatidy database."

      prompt.message = "mediatidy".yellow
      prompt.delimiter = ": ".green
      prompt.properties =
        yesno:
          default: 'no'
          message: 'Delete all files from the mediatidy database?'
          required: true
          warning: "Must respond yes or no"
          validator: /y[es]*|n[o]?/

      # Start the prompt
      prompt.start()

      # get the simple yes or no property
      prompt.get ['yesno'], (err, result) =>
        if result.yesno.match(/yes/i)
          @dbBulkFileDelete =>
            console.log "All files removed from mediatidy..."
            callback()
        else
          console.log "No files were removed from mediatidy..."
          callback()

  pathsDelete: (callback) ->
    console.log '==> '.cyan.bold + 'remove all media paths from mediatidy'

    # get all paths
    @dbBulkPathGet '\'MEDIA\'', (array) =>

      # display paths to user
      arrayLength = array.length
      i = 0
      while i < arrayLength
        console.log "CURRENT PATH:".yellow, array[i].path
        i++

      prompt.message = "mediatidy".yellow
      prompt.delimiter = ": ".green
      prompt.properties =
        yesno:
          default: 'no'
          message: 'Delete all paths from mediatidy?'
          required: true
          warning: "Must respond yes or no"
          validator: /y[es]*|n[o]?/

      # Start the prompt
      prompt.start()

      # get the simple yes or no property
      prompt.get ['yesno'], (err, result) =>
        if result.yesno.match(/yes/i)
          @dbPathDelete '\'MEDIA\'', =>
            console.log "All media paths removed..."
            callback()
        else
          console.log "No media paths were removed..."
          callback()

  pathDropPromptYesNo: (callback) ->
    @dbBulkPathGet '\'MEDIA\'', (array) =>

      # display paths to user
      arrayLength = array.length
      i = 0
      while i < arrayLength
        console.log "CURRENT PATH:".yellow, array[i].path
        i++

      prompt.message = "mediatidy".yellow
      prompt.delimiter = ": ".green
      prompt.properties =
        yesno:
          default: 'no'
          message: 'Delete all media paths from mediatidy?'
          required: true
          warning: "Must respond yes or no"
          validator: /y[es]*|n[o]?/

      # Start the prompt
      prompt.start()

      # get the simple yes or no property
      prompt.get ['yesno'], (err, result) =>
        if result.yesno.match(/yes/i)
          @pathPromptAdd =>
            @pathPromptYesNo ->
              callback()
        else
          console.log "Finished adding paths..."
          callback()


  pathPrompt: (callback) ->
    console.log '==> '.cyan.bold + 'update paths to media files for mediatidy to tidy up!'
    @pathPromptYesNo =>
      callback()

  pathPromptAdd: (callback) ->
    prompt.message = "mediatidy".yellow
    prompt.delimiter = ": ".green
    prompt.properties =
      path:
        description: 'enter full path to media files (movies or tv shows)'
        message: 'enter path to media files'
        required: true

    prompt.start()
    prompt.get ['path'], (error, result) =>
      # remove trailing forward slash
      result.path = result.path.replace(/\/$/, "")
      @dbPathAdd result.path, 'MEDIA', ->
        callback()

  pathPromptYesNo: (callback) ->
    @dbBulkPathGet '\'MEDIA\'', (array) =>

      arrayLength = array.length
      i = 0
      while i < arrayLength
        console.log "CURRENT PATH:".yellow, array[i].path
        i++

      if arrayLength is 0
        @pathPromptAdd =>
          @pathPromptYesNo ->
            callback()
      else
        prompt.message = "mediatidy".yellow
        prompt.delimiter = ": ".green
        prompt.properties =
          yesno:
            default: 'no'
            message: 'Add another media path to mediatidy?'
            required: true
            warning: "Must respond yes or no"
            validator: /y[es]*|n[o]?/

        # Start the prompt
        prompt.start()

        # get the simple yes or no property
        prompt.get ['yesno'], (err, result) =>
          if result.yesno.match(/yes/i)
            @pathPromptAdd =>
              @pathPromptYesNo ->
                callback()
          else
            console.log "Finished adding paths..."
            callback()

  setup: (callback) ->
    @dbSetup ->
      callback()

module.exports = Config
