#Method to create timeStamp as our conferenceID
def get_conference_id()
    timeVar  = Time.new
    returnValue = timeVar.strftime("%Y%H%M%S")
    return returnValue
end
 
conferenceOptions={
    :mute=>false,
    :playTones=>true,
    :leaveprompt=>"beep"
}
 
begin
 
  #Create conference ID
  conferenceID = get_conference_id()
 
  # $phones passed in from Rails app
  phonestring = $phones
  numbers = phonestring.split(",")
  
  # spin up a thread for each call and conference leg
  numbers.each do |x| 
    
    Thread.new do
      #Call First Leg (User)
      log "@"*5 + "Calling " + x
      
      # event = call "tel:+" + numbers[count]
      call 'tel:+' + x, {
            :onAnswer=>lambda{|event|
                log "@"*5+"Invitee answered join conference"
                newCall = event.value
                
                #announce caller
                newCall.say "You are being invited to join a conference call. "
                newCall.ask "Press or say 1 to accept the call", {
                     :choices => "[1 DIGITS]",
                     :timeout => 15.0,
                     :onChoice => lambda { |invitee|
                        if invitee.value == "1"
                          #add to conf
                          newCall.conference(conferenceID,conferenceOptions)
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
  
  # conference(conferenceID,conferenceOptions)
  sleep 60
 
end