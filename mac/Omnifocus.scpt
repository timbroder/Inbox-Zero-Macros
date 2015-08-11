----------------------------------------
-- PROPERTIES TO BE AJUSTED --
----------------------------------------

-- Must be set for Outlook 2016 (15)
property localUser : "tbroder"

-- here we specify if we want the quick entry pane (1) or not (0)
property showQuickEntry : 1
-- if you dont want to have omnifocus be brought to the foreground, set this to 0, 
-- however, this will only take effect if showQuickEntry is 1
property bringOmnifocusToForeground : 0

-- set this to 0 if you dont want an email attachment
property attachMailToOFTask : 1

-- set this to
-- 0: for not putting the focus anywhere
-- 1: for putting the focus into the task name field
-- 2: for putting the focus in the project field
-- 3: for putting the focus into the context field
-- 4: for putting the focus into the due field
-- default: a reasonable default is 2 to set it to the project field
property focusSpecificField : 2

-- CAUTION: use at your own RISK, this will delete the original mail after it was transferred to OmniFocus
property deleteMailAfterProcessing : 0

-- configure mail post processing, if this is set to
-- 0: for not moving the mail (use 0 if you want to enable mail deletion as defined above)
-- 1: if you want to move the mail to a folder

property moveMailToFolder : 0

-- configure the target folder name to where the mail should be moved. Needs to exist first
property targetMailFolderName : "_ARCH"


tell application "Microsoft Outlook"
    -- display dialog "1" with icon 1
    -- get the currently selected message or messages
    set selectedMessages to current messages
    -- if there are no messages selected, warn the user and then quit
    if selectedMessages is {} then
        display dialog "Please select one or more messages first and then run this script." with icon 1
        return
    end if
    
    repeat with theMessage in selectedMessages
        
        set theName to subject of theMessage
        
        -- Check for a blank subject line, check provided by Peter as well as Paul
        if theName is missing value then
            set theName to "No Subject"
        end if
        -- End check
        
        set theContent to content of theMessage
        set theID to id of theMessage as string
        set theSender to sender of theMessage
        
        -- some messages dont have a sender name so lets make sure that we catch this error
        set theSenderAddress to "Unknown Sender"
        set theSenderName to "No Sender Name"
        try
            set theSenderName to name of theSender
        end try
        try
            set theSenderAddress to address of theSender
        end try
        
        set msgTime to time sent of theMessage
        set OmniFocusHeader to linefeed & linefeed & "From: " & theSenderName & " [" & theSenderAddress & "]" & return & "Date: " & msgTime & return & return
        
        -- here we try to spotlight-search for the Selected Outlook message using the unique Outlook Message ID
        -- and save the file name (including full path) to myMsgFile
        
        -- note that this does not work on my system since outlook is claiming that the msg is from a different identity, FFS
        --      set myShellCmd to "mdfind com_microsoft_outlook_recordID==" & theID
        --      set myMsgFile to the first item of paragraphs of (do shell script myShellCmd)
        
        -- set the path to a temp area on your HD to temporarily store the attachment to be loaded into OF
        set theFileName to "/Users/" & localUser & "/Library/Containers/com.microsoft.Outlook/Data/Documents/OutlookMsg" & theID & ".eml"

        if (attachMailToOFTask is 1) then
            tell application "OmniFocus"
                log "saving the file: " & theFileName
            end tell
            log theMessage
            save theMessage in theFileName
        end if
        
        -- here we convert the HTML of the Message Content to plain text to insert into the Note section
        -- update: fixed input encoding as suggested by @Andrew
        set myTxtContent to do shell script ("echo " & (quoted form of theContent) & " |textutil -format html -inputencoding UTF-8 -convert txt -stdin -stdout")
        
        set theTxtContent to OmniFocusHeader & linefeed & linefeed & myTxtContent
        
        
        tell application "OmniFocus"
            set theDoc to default document
            set theTask to theName
            set theNote to theTxtContent
            if (showQuickEntry is 1) then
                tell quick entry
                    set NewTask to make new inbox task with properties {name:theTask, note:theTxtContent}
                    if (attachMailToOFTask is 1) then
                        tell me to set theAttachment to (POSIX file theFileName)
                        
                        tell the note of NewTask
                            make new file attachment with properties {file name:theAttachment, embedded:true}
                        end tell
                    end if
                    if (bringOmnifocusToForeground is 1) then
                        activate
                    end if
                    open
                    tell application "System Events"
                        repeat focusSpecificField times
                            keystroke tab
                        end repeat
                    end tell
                end tell
            else
                -- we dont want the quick entry panel but the task will immediately show up in the inbox
                tell application "OmniFocus"
                    tell the first document
                        set NewTask to make new inbox task with properties {name:theTask, note:theTxtContent}
                        if (attachMailToOFTask is 1) then
                            tell the note of NewTask
                                make new file attachment with properties {file name:theFileName, embedded:true}
                            end tell
                        end if
                    end tell
                end tell
            end if
        end tell
        
        -- the message should be removed from Outlook after it gets sent to OF
        if (deleteMailAfterProcessing is 1) then
            delete theMessage
        end if
        if (moveMailToFolder is 1) then
            move theMessage to folder targetMailFolderName
        end if
        --      display dialog theTxtContent
    end repeat
end tell


-- bring OmniFocus to the front
-- thanks to tim @ omni for this one
-- does not seem to work with OmniFocus 2



on findAndReplace(tofind, toreplace, TheString)
    set ditd to text item delimiters
    set res to missing value
    set text item delimiters to tofind
    repeat with tis in text items of TheString
        if res is missing value then
            set res to tis
        else
            set res to res & toreplace & tis
        end if
    end repeat
    set text item delimiters to ditd
    return res
end findAndReplace


on write_error_log(this_error)
    set the error_log to "/Users/tbroder/Downloads/Script Error Log.txt"
    try
        open for access file the error_log with write permission
        write (this_error & return) to file the error_log starting at eof
        close access file the error_log
    on error
        try
            close access file the error_log
        end try
    end try
end write_error_log
