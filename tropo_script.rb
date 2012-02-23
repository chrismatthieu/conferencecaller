conferenceOptions = {
    :mute        => false,
    :playTones   => true,
    :leaveprompt => "beep"
}
 
#Create conference ID
conferenceID = Time.new.strftime("%Y%H%M%S")

threads = []
  
# spin up a thread for each call and conference leg
$phones.split(",").each do |x| 
  threads << Thread.new do
    #Call First Leg (User)
    log "@"*10 + "Calling " + x
    
    call 'tel:+' + x, {
          :onAnswer => lambda { |event|
              log "@"*10 + "Invitee answered join conference"
              newCall = event.value
              
              #announce caller
              newCall.say "You are being invited to join a conference call. "
              newCall.ask "Press or say 1 to accept the call", {
                   :choices  => "[1 DIGITS]",
                   :timeout  => 15.0,
                   :onChoice => lambda { |invitee|
                      if invitee.value == "1"
                        #add to conf
                        newCall.conference(conferenceID, conferenceOptions)
                      else
                        newCall.say "thats o.k. now they will probably talk about you."
                        newCall.hangup
                      end
                    }
              }
          }
      }
  end  
end 
  
conference(conferenceID, conferenceOptions)

threads.each { |t| t.join }