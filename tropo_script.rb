########################################################################
#      Tropo script using Ruby and the Tropo Scripting API            #
#      The script receives a comma delimited string of phone          #
#      numbers from a Rails application and dials each number         #
#      using a seperate thread for concurrency. As people answer      #
#      the script asks if they would like to join the conference.     #
#      If the user says "one" or presses the 1 key on their phone,    #
#      they will be added to the conference id with the other         #
#      participants.                                                  #
########################################################################

# set conference options - no one is muted and DTMF tones can be heard
conferenceOptions = {
    :mute        => false,
    :playTones   => true
}
 
#Create conference ID based on timestamp for uniqueness
conferenceID = Time.new.strftime("%Y%H%M%S")

# Create an array to track threads
threads = []
  
# Loops through comma delimited string of phone numbers as an array and 
# creates a thread for each number to call and conference
$phones.split(",").each do |x| 

  # Spin up a thread for each call and conference leg
  threads << Thread.new do
    
    # Log the number we are calling
    log "@"*10 + "Calling " + x
    
    # Call the number (x) and setup onAnswer event for further processing
    call 'tel:+' + x, {
          :onAnswer => lambda { |event|
            
              # Log that the number dialed answered the call
              log "@"*10 + "Invitee answered join conference"
              
              # Set the new call object based on the event value
              newCall = event.value
              
              # Inform the person being called that this is a conference call and ask them to join
              newCall.say "You are being invited to join a conference call. "
              
              # Wait for the caller to say or press a single digit. Timeout in 15 seconds if nothing heard.
              newCall.ask "Press or say 1 to accept the call", {
                   :choices  => "[1 DIGITS]",
                   :timeout  => 15.0,
                   :onChoice => lambda { |invitee|

                      # This routine runs when a valid digit is spoken or pressed.
                      # Validity is determined by the value of choices
                      if invitee.value == "1"

                        # If the called party says or presses the 1 key play a beep MP3 sound file
                        newCall.say "http://conferencecaller.herokuapp.com/beep.mp3"
                        # Add the called party to the same conference as the other participants
                        newCall.conference(conferenceID, conferenceOptions)

                      else
                        
                        # The user said or pressed something other than "one". 
                        # Tell them good bye and then hangup
                        newCall.say "thats o.k. now they will probably talk about you."
                        newCall.hangup

                      end
                    }
              }
          }
      }
  end  
end 

# Join the array of threads together so the Tropo session stays alive until the last person has left the conference.
threads.each { |t| t.join }