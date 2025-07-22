# monitor.pl - Main Network Health Monitoring Script
# This script performs server health checks and log analysis.

use strict;
use warnings;
use IO::Socket::INET;
use Net::SMTP;
use Cwd 'abs_path';
use File::Basename 'dirname';

# Use our custom configuration module.
# This makes sure we can find Config.pm even if the script is run from a different directory.
use lib dirname(abs_path($0));
use Config;

# --- Subroutines ---

# Subroutine to send an email alert.
# Arguments: $subject, $body
sub send_email_alert {
    my ($subject, $body) = @_;
    my %config = Config::get_config();

    # Check if email configuration is complete
    my $email_config = $config{email};
    if (!$email_config->{smtp_server} || $email_config->{smtp_server} eq 'smtp.example.com') {
        print "ALERT (Email not sent - configure Config.pm): $subject\n";
        return;
    }

    my $smtp = Net::SMTP->new($email_config->{smtp_server}, Timeout => 30, Debug => 0);

    unless ($smtp) {
        print "Error: Could not connect to SMTP server $email_config->{smtp_server}.\n";
        return;
    }

    $smtp->mail($email_config->{from});
    $smtp->to($email_config->{to});
    $smtp->data();
    $smtp->datasend("To: $email_config->{to}\n");
    $smtp->datasend("From: $email_config->{from}\n");
    $smtp->datasend("Subject: $subject\n");
    $smtp->datasend("\n");
    $smtp->datasend($body);
    $smtp->dataend();
    $smtp->quit;

    print "Alert email sent to $email_config->{to} with subject: $subject\n";
}

# Subroutine to check the status of a specific port on a server.
# Arguments: $host, $port
# Returns: 1 if up, 0 if down.
sub check_server {
    my ($host, $port) = @_;

    my $socket = IO::Socket::INET->new(
        PeerAddr => $host,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => 5
    );

    if ($socket) {
        close($socket);
        return 1; # Port is open
    } else {
        return 0; # Port is closed or host is unreachable
    }
}

# Subroutine to analyze a log file for specific patterns.
# Arguments: $log_file_path, @patterns
sub analyze_log {
    my ($log_file, @patterns) = @_;
    
    unless (-e $log_file) {
        print "Warning: Log file '$log_file' not found.\n";
        return;
    }

    open(my $fh, '<', $log_file) or do {
        print "Error: Could not open log file '$log_file': $!\n";
        return;
    };

    print "\n--- Analyzing Log File: $log_file ---\n";
    while (my $line = <$fh>) {
        foreach my $pattern (@patterns) {
            if ($line =~ /$pattern/i) { # Case-insensitive match
                print "Pattern Match Found: '$pattern' in line: $line";
                my $subject = "Log Alert: Pattern '$pattern' detected!";
                my $body = "A critical pattern was found in the log file '$log_file'.\n\n";
                $body .= "Pattern: $pattern\n";
                $body .= "Log Entry: $line\n";
                send_email_alert($subject, $body);
            }
        }
    }
    print "--- Log Analysis Complete ---\n";
    close($fh);
}


# --- Main Execution ---

print "Starting Network Health Monitor...\n";
my %config = Config::get_config();

# 1. Perform Server Health Checks
print "\n--- Performing Server Health Checks ---\n";
foreach my $server (@{$config{servers}}) {
    my $host = $server->{host};
    foreach my $port (@{$server->{ports}}) {
        print "Checking $host on port $port... ";
        if (check_server($host, $port)) {
            print "[ UP ]\n";
        } else {
            print "[ DOWN ]\n";
            my $subject = "Network Alert: Service Down on $host:$port";
            my $body = "The service on host '$host' at port '$port' is not responding.\n\n";
            $body .= "Please investigate immediately.\n";
            send_email_alert($subject, $body);
        }
    }
}
print "--- Health Checks Complete ---\n";

# 2. Perform Log Analysis
analyze_log($config{log_analysis}->{log_file}, @{$config{log_analysis}->{patterns}});

print "\nMonitoring cycle finished.\n";