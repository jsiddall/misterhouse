
# Category=Internet
#
# This will take data fed to the speak_server port and speak it.
#
# This acts as an independent web server, so the password
# authentication used by the normal mh server is NOT used here.
# So, if you don't want strangers speaking to you, you will
# want to use the normal mh servers SET_VAR directive (see mh.html)
# to enable this same function, with password protection.
# 
# Note: The default mh.ini parms look like this:
#   server_speak_port=8082      # This is a speak port (code/Bruce/speak_server.pl)
#   server_speak_buffer=1       # This grabs a line of data per mh loop (faster than one character per mh loop)
# 
# Code html that looks like this (change localhost to your IP address if you want remote access).
#
# <FORM method="GET" ACTION="http://localhost:8082">Enter Text you want spoken over our sound system:<P>
# <textarea ROWS=10 COLS=70 name="text"></textarea><p>
# Press <input type="submit" value="Speak it!"> to send the command.
# </FORM>

#
# With the default mh install, edit mh/web/speak/speak.html and point ACTION to your IP 
# address (or localhost), then point your browser to:
#
#    http://localhost:8080/speak/index.html
#
# You can also create your own Eliza rules in the mh/data/eliza/ directory, then modify
# your mh/web/speak/speak.html radiobuttons to point to them.
#

use Eliza;
my ($chatbot, $chatbot_rule);

$speak_server  = new  Socket_Item(undef, undef, 'server_speak');
$internet_light= new X10_Item('F1');

my $speak_server_data;
if ($state = said $speak_server) {
    $speak_server_data = $state;
                            # Detect where the message is from
#   my ($name, $name_short) = net_domain_name('server_speak');
    net_domain_name_start 'server_speak', 'server_speak'; # Background DNS search
}
                                # This will be true when the DNS search started above finishes
if (my ($name, $name_short) = net_domain_name_done 'server_speak') {
    $name_short = 'local' if is_local_address $name;
    my $msg;
                                # Should allow for POST data 
                                # but GET will work OK for short messages
                                # Data looks like this:  GET /?message=hi&eliza=1 HTTP/1.1 ...
                                #                        GET /?internet_light=ON HTTP/1.1
                                #                        GET /?internet_light=ON/ HTTP/1.1
    if ($speak_server_data =~ /^GET /) {
                                # Format the message
        ($msg) = $speak_server_data =~ /message=([^\&\/ ]+)/i;
        $msg = html_unescape $1;
        $msg =~ s/[\r\n]/ /g;   # Drop CR and line feeds

                                # Check to see if this was an internet light request
        if ($speak_server_data =~ /internet_light=([^\/ ]+)/i) {
            $msg = "Internet light set to '$1'";
#           set_with_timer $internet_light $1, 60 unless $Save{sleeping_parents};
        }
                                # If textarea name="ELIZA", then call up the psychologist
                                # using the specified rule. 
        elsif ($speak_server_data =~ /eliza=1/i) {
#           print "db2 chatbot=$chatbot file=$chatbot_rule\n";
            if ($speak_server_data =~ /eliza_rule=([^\&\/ ]+)/ and $1 ne $chatbot_rule){
                $chatbot_rule = $1;
                undef $chatbot;
            }
            $chatbot_rule = 'doctor' unless $chatbot_rule;
#           print "db3 chatbot=$chatbot file=$chatbot_rule\n";
#           $chatbot = new Chatbot::Eliza "Eliza", "$config_parms{data_dir}/eliza/$chatbot_rule.txt" unless $chatbot;
            $chatbot = new Chatbot::Eliza "Eliza", "../data/eliza/$chatbot_rule.txt" unless $chatbot;

            my $response = $chatbot->transform($msg);
#           $msg = "$name_short said: $msg.\nEliza says: $response";
            my  $msg2  = "<voice required='Name=Microsoft Sam'\>$name_short said: ";
            $msg2 .= "<voice required='Name=Microsoft Mike'>$msg.</voice>\n";
            $msg2 .= "Eliza says: <voice required='gender=female'>$response.</voice>";
            print "db r=$response\n";
            $msg = $msg2;
        }
        else {
            $msg = "Internet message from $name_short: <voice required='gender=male'/>$msg" if $msg;
#           $msg = "Internet message: $msg" if $msg;
        }

        &speak(to_file => "$config_parms{data_dir}/speak_server.wav", text => $msg);

        my $html;
        ($html = $msg) =~ s/\n/\n<br>/g;
        $html .=  "\n<br><EMBED SRC='http://misterhouse.net:8080/data/speak_server.wav' WIDTH=144 HEIGHT=60 AUTOSTART='true'>\n";

        set $speak_server &html_page("", "<h3>The Message spoken:</h3>$html");

#        display($msg, 120, "Internet Message from $name") unless
#            $msg =~ /^Internet light set/;

        logit("$config_parms{data_dir}/logs/speak_server.$Year_Month_Now.log", "domain=$name text=$msg"); 

    }
                                # Allow for other program to post display/log data
    elsif ($speak_server_data =~ /^DATA /) {
        display($speak_server_data, 0, "Internet data from $name");
        logit("$config_parms{data_dir}/logs/speak_server.$Year_Month_Now.data.log", "domain=$name text=$msg"); 
    }
                                # Allow for other programs to send speak socket
                                # data directly (e.g. monitor_weblog)
    else {
        $msg = $speak_server_data;
    }

    stop $speak_server;     # Tell the client we got the message

    $msg = substr $msg, 0, 600;
    print "db ms=$msg\n";
    if ($config_parms{internet_speak_flag} eq 'all' or
        $config_parms{internet_speak_flag} eq 'some' and $speak_server_data =~ /^GET /) {
        speak voice => 'mike', text => $msg;
    }
    elsif ($msg and length $msg < 400) {
        print_log $msg unless $msg =~ /^sound_/;
    }
    
}


