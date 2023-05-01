const String getMailAccount = '''tell application "Mail"
	
	
	get every account as list
	
	set numberOfAccounts to the length of the result
	
	
	if the numberOfAccounts is greater than 1 then
		
		set myfirstDialog to choose from list (get the name of every account as list) ¬
			with prompt "Select the account from which you want to send your emails actively."
		
		myfirstDialog
		
		set nameChosenAccount to the result
		
		set chosenAccount to the first account whose name is equal to nameChosenAccount
		
		log chosenAccount
		
		extractSenderID of me from the chosenAccount
		
		set senderID to the result
		
	else if the numberOfAccounts is equal to 1 then
		
		extractSenderID of me from (get the first account)
		
		set senderID to the result
		
	end if
	
end tell

to extractSenderID from aMailAccount
	
	tell application "Mail"
		
		set userFullName to the full name of aMailAccount
		
		set userMailAdress to the email addresses of aMailAccount
		
		set senderID to userFullName & " <" & userMailAdress & ">"
		
		
	end tell
	
	return senderID
	
end extractSenderID''';

String closeWindow(String fileName, String workingDirectory) => '''
	tell application "TextEdit"	
				try
					set the visible of (the first window whose name contains "$fileName") to false
					close (the first document whose name contains "$fileName") saving yes ¬
						saving in POSIX file ("$workingDirectory" & "/emails/" & "$fileName")
					quit
				on error
					log "error handeled"
					delay 0.1
					set the visible of (the first window whose name contains "$fileName") to false
					close (the first document whose name contains "$fileName") saving yes ¬
						saving in POSIX file ("$workingDirectory" & "/emails/" & "$fileName") 
					quit
				end try
			end tell
''';

String sendEmail({
  required String senderID,
  required List<String> toRecipients,
  required String subject,
  String? ccRecipient,
  String? bccRecipient,
  List<String> attachmentPaths = const [],
  String body = " ",
}) =>
    ''' 
tell application "Mail"
		set outgoingMessage to make new outgoing message with properties {visible:false}
		tell outgoingMessage
			${addToRecipients(toRecipients)}
      ${ccRecipient != null ? 'make new cc recipient at end of cc recipients with properties {address:"$ccRecipient"}' : ' '}
			${bccRecipient != null ? 'make new bcc recipient at end of bcc recipients with properties {address:"$bccRecipient"}' : ' '}
			set sender to "$senderID"
			set subject to "$subject"
			set content to "$body"
		end tell
    ${addAttachments(attachmentPaths)}
    send the outgoingMessage
	end tell

''';

String addToRecipients(List<String> toRecipients) {
  String code = "";
  for (var recipient in toRecipients) {
    code +=
        '''make new to recipient at end of to recipients with properties {address: "$recipient"} \n''';
  }
  return code;
}

String addAttachments(List<String> attachmentPaths) {
  String code = "tell outgoingMessage";
  for (var path in attachmentPaths) {
    code +=
        '''\n make new attachment with properties {file name:POSIX file "$path" as alias}''';
  }
  code += " \nend tell";
  return code;
}

void main() {
  print(sendEmail(
      senderID: "Philip",
      toRecipients: ["philipugk@gmail.com", "philip@testmail.com"],
      subject: "seeing if this works"));
}
